import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:coka/api/conversation.dart';
import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/appbar_widget.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http_parser/http_parser.dart';
import 'package:coka/components/member_selection_dialog.dart';

// ============================================================================
// ENUMS & CONSTANTS
// ============================================================================

enum MessagePosition { Single, FirstInReply, MiddleInReply, LastInReply }

// ============================================================================
// MAIN WIDGET
// ============================================================================

class ChatConvPage extends StatefulWidget {
  final String? personName,
      personId,
      personAvatar,
      convId,
      provider,
      pageName,
      pageAvatar,
      assignId,
      assignName,
      assignAvatar;

  const ChatConvPage(
      {super.key,
      this.personName,
      this.personAvatar,
      this.convId,
      this.provider,
      this.pageName,
      this.pageAvatar,
      this.personId,
      this.assignId,
      this.assignName,
      this.assignAvatar});

  @override
  State<ChatConvPage> createState() => _ChatConvPageState();
}

class _ChatConvPageState extends State<ChatConvPage> {
  // ============================================================================
  // CONTROLLERS & STATE VARIABLES
  // ============================================================================

  final chatController = TextEditingController();
  final homeController = Get.put(HomeController());
  final ImagePicker _imagePicker = ImagePicker();
  final ScrollController sc = ScrollController();
  final ConvApi _convApi = ConvApi();

  late StreamSubscription onChangedListener;
  StreamSubscription<DatabaseEvent>? conversationSubscription;

  var isLastMessage = false;
  var isConvFetching = false;
  var isConvEmpty = false;
  var convList = [];
  var offset = 0;
  // Queue lưu temp message ids để xoá khi nhận message thật
  final List<String> _tempMessageIds = [];

  // Conversation details for AppBar
  String? _conversationPersonName;
  String? _conversationPersonAvatar;
  String? _conversationPageName;
  String? _conversationPageAvatar;
  String? _conversationAssignId;
  String? _conversationAssignName;
  String? _conversationAssignAvatar;

  // ============================================================================
  // LIFECYCLE METHODS
  // ============================================================================

  @override
  void initState() {
    super.initState();
    chatController.addListener(_onTextChanged);
    _initializeChat();
    _setupScrollListener();
    _setupFirebaseListener();
    _loadConversationDetails();
  }

  @override
  void dispose() {
    onChangedListener.cancel();
    conversationSubscription?.cancel();
    chatController.removeListener(_onTextChanged);
    chatController.dispose();
    sc.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // Cập nhật UI khi nội dung thay đổi để ẩn/hiện nút ảnh/tệp
    if (mounted) setState(() {});
  }

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  void _initializeChat() {
    onRefresh();
    ConvApi().setRead(widget.convId).then(
          (value) => homeController.fetchConvUnread(),
        );
  }

  Future<void> _loadConversationDetails() async {
    try {
      final response = await _convApi.getConversationDetail(widget.convId);
      if (response != null && response['code'] == 0) {
        final content = response['content'];
        if (mounted) {
          setState(() {
            _conversationPersonName = content['personName'];
            _conversationPersonAvatar = content['personAvatar'];
            _conversationPageName = content['pageName'];
            _conversationPageAvatar = content['pageAvatar'];
            _conversationAssignId = content['assignTo'];
            _conversationAssignName = content['assignName'];
            _conversationAssignAvatar = content['assignAvatar'];
          });
        }
      }
    } catch (e) {
      print('Error loading conversation details: $e');
    }
  }

  void _setupScrollListener() {
    sc.addListener(() async {
      if (sc.position.pixels >= sc.position.maxScrollExtent &&
          convList.isNotEmpty &&
          !isConvFetching &&
          !isLastMessage) {
        offset += 20;
        setState(() => isConvFetching = true);
        await fetchConvList();
        setState(() => isConvFetching = false);
      }
    });
  }

  void _setupFirebaseListener() {
    getOData().then((value) {
      final oId = jsonDecode(value)["id"];
      final ref = FirebaseDatabase.instance.ref(
        'root/OrganizationId: $oId/CreateOrUpdateConversation',
      );

      onChangedListener = ref.onValue.listen((event) {
        final data = (event.snapshot.value ?? {}) as Map;
        log("Data changed: ${data.toString()}");

        final dataMess = data["ConversationId: ${widget.convId}"];
        if (dataMess != null && dataMess["ConversationId"] == widget.convId) {
          String? attachmentTypel, attachmentUrl, attachmentName;
          if (dataMess["Attachments"] != null) {
            final attachments = jsonDecode(dataMess["Attachments"]);
            if (attachments.isNotEmpty) {
              final attachment = attachments.first;
              attachmentTypel = attachment["type"];
              attachmentUrl = attachment["payload"]["url"];
              // attachmentName = attachment["Name"];
            }
          }
          // Xoá temp message (nếu có) trước khi thêm message thật
          _removeFirstTempMessageIfAny();
          addMessage(
            dataMess["Message"],
            dataMess["To"],
            dataMess["ToName"],
            attachmentType: attachmentTypel,
            attachmentUrl: attachmentUrl,
            attachmentName: attachmentName,
          );
        }
      });
    });
  }

  // ============================================================================
  // DATA FETCHING
  // ============================================================================

  Future<void> onRefresh() async {
    setState(() {
      isConvFetching = true;
      convList.clear();
      offset = 0;
    });

    await fetchConvList();
    setState(() => isConvFetching = false);
  }

  Future<void> fetchConvList() async {
    final res = await ConvApi().getConvList(widget.convId, offset);

    if (isSuccessStatus(res["code"])) {
      convList.addAll(res["content"]);

      if (convList.isEmpty) {
        isConvEmpty = true;
      } else {
        isLastMessage = convList.length >= res["metadata"]["total"];
        isConvEmpty = false;
      }
    } else {
      errorAlert(title: "Lỗi", desc: res["message"]);
    }
  }

  // ============================================================================
  // MESSAGE HANDLING
  // ============================================================================

  void addMessage(
    // Cho phép message có thể là null
    String? message,
    String? to,
    String? toName, {
    String? attachmentType,
    String? attachmentUrl,
    String? attachmentName,
  }) {
    // --- BẮT ĐẦU NÂNG CẤP ---

    // 1. Xác định nội dung tin nhắn cuối cùng
    String finalMessage = message ?? ''; // Đảm bảo message không bị null

    // Nếu không có nội dung văn bản nhưng có file đính kèm,
    // hãy tạo nội dung mặc định.
    // if (finalMessage.trim().isEmpty && attachmentType != null) {
    //   if (attachmentType == 'image') {
    //     finalMessage = "[Ảnh]";
    //   } else {
    //     // Có thể mở rộng cho các loại file khác nếu cần
    //     finalMessage = "[Tệp đính kèm]";
    //   }
    // }

    // --- KẾT THÚC NÂNG CẤP ---

    final newMessage = <String, dynamic>{
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "to": to,
      "toName": toName,
      // 2. Sử dụng nội dung đã được xử lý
      "message": finalMessage,
      "isGpt": false,
      "type": "MESSAGE",
      "status": 1,
    };

    if (attachmentType != null && attachmentUrl != null) {
      log("Adding attachment - Type: $attachmentType, URL: $attachmentUrl");
      newMessage["attachments"] = jsonEncode([
        {
          "type": attachmentType,
          "payload": {
            "url": attachmentUrl,
            "name": attachmentName ?? "attachment",
          }
        }
      ]);
    }

    // Thêm item vào đầu danh sách và cập nhật UI (không thay đổi)
    setState(() => convList.insert(0, newMessage));
  }

  // Thêm message tạm thời, trả về tempId để quản lý xoá sau này
  String addTempMessage(
    String? message,
    String? to,
    String? toName, {
    String? attachmentType,
    String? attachmentUrl,
    String? localPath,
    String? attachmentName,
  }) {
    final String tempId = "temp_${DateTime.now().microsecondsSinceEpoch}";
    final tempMessage = <String, dynamic>{
      "tempId": tempId,
      "isTemp": true,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "to": to,
      "toName": toName,
      "message": message ?? '',
      "isGpt": false,
      "type": "MESSAGE",
      "status": 0,
    };

    if (attachmentType != null) {
      tempMessage["attachments"] = jsonEncode([
        {
          "type": attachmentType,
          "payload": {
            "url": attachmentUrl, // có thể null khi đang upload
            "localPath": localPath, // đường dẫn tạm để preview
            "name": attachmentName ?? "attachment",
          }
        }
      ]);
    }

    setState(() {
      convList.insert(0, tempMessage);
      _tempMessageIds.add(tempId);
    });

    return tempId;
  }

  void _removeTempMessageById(String tempId) {
    final idx = convList.indexWhere(
        (m) => m is Map && m["isTemp"] == true && m["tempId"] == tempId);
    if (idx != -1) {
      setState(() {
        convList.removeAt(idx);
        _tempMessageIds.remove(tempId);
      });
    }
  }

  void _removeFirstTempMessageIfAny() {
    if (_tempMessageIds.isEmpty) return;
    // Chỉ xoá temp message đang ở trạng thái gửi (status == 0)
    final int idx = convList.indexWhere((m) =>
        m is Map &&
        m["isTemp"] == true &&
        (m["status"] == 0 || m["status"] == null));
    if (idx != -1) {
      final String? tempId = convList[idx]["tempId"] as String?;
      if (tempId != null) {
        _removeTempMessageById(tempId);
      }
    }
  }

  void _markTempMessageError(String tempId, {String? errorMessage}) {
    final idx = convList.indexWhere(
        (m) => m is Map && m["isTemp"] == true && m["tempId"] == tempId);
    if (idx != -1) {
      setState(() {
        convList[idx]["status"] = -1; // lỗi
        if (errorMessage != null && errorMessage.isNotEmpty) {
          convList[idx]["error"] = errorMessage;
        }
      });
    }
  }

  Future<void> sendMessage() async {
    final messageText = chatController.text;
    if (messageText.isEmpty) return;

    final tempId = addTempMessage(
      messageText,
      widget.personId,
      widget.personName,
    );
    chatController.clear();

    final res = await ConvApi().sendConv({
      "conversationId": widget.convId,
      "message": messageText,
    });

    if (!isSuccessStatus(res["code"])) {
      errorAlert(title: "Lỗi", desc: res["message"]);
      _markTempMessageError(tempId, errorMessage: res["message"]?.toString());
    }
  }

  // ============================================================================
  // FILE & IMAGE HANDLING
  // ============================================================================

  Future<void> onPickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image == null) return;

      final mediaType = _getMediaType(image.name);
      await _sendAttachment(image.path, image.name, mediaType, isImage: true);
    } catch (e) {
      log(e.toString());
      errorAlert(title: "Lỗi", desc: e.toString());
    }
  }

  Future<void> onPickFileFromDevice() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
      );
      if (result == null) return;

      final file = result.files.single;
      if (file.path == null) {
        errorAlert(title: "Lỗi", desc: "Không đọc được đường dẫn tệp");
        return;
      }

      final ext = (file.extension ?? '').toLowerCase();
      final isImage = ['png', 'jpg', 'jpeg', 'gif', 'webp'].contains(ext);
      final mediaType = isImage ? _getMediaTypeFromExt(ext) : null;

      await _sendAttachment(
        file.path!,
        file.name,
        mediaType,
        isImage: isImage,
      );
    } catch (e) {
      errorAlert(title: "Lỗi", desc: e.toString());
    }
  }

  MediaType _getMediaType(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    return _getMediaTypeFromExt(ext);
  }

  MediaType _getMediaTypeFromExt(String ext) {
    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'jpeg');
    }
  }

  Future<void> _sendAttachment(
    String path,
    String filename,
    MediaType? mediaType, {
    required bool isImage,
  }) async {
    final multipart = await dio.MultipartFile.fromFile(
      path,
      filename: filename,
      contentType: mediaType,
    );

    // Tạo temp message trước
    final tempId = addTempMessage(
      chatController.text.isNotEmpty
          ? chatController.text
          : "${isImage ? '[Ảnh]' : '[Tệp]'} $filename",
      widget.personId,
      widget.personName,
      attachmentType: isImage ? "image" : "file",
      attachmentUrl: null,
      localPath: isImage ? path : null,
      attachmentName: filename,
    );

    final res = await ConvApi().sendConvAttachment(
      conversationId: widget.convId!,
      message: chatController.text.isNotEmpty ? chatController.text : null,
      attachment: multipart,
    );

    if (!isSuccessStatus(res["code"])) {
      errorAlert(title: "Lỗi", desc: res["message"]);
      _markTempMessageError(tempId, errorMessage: res["message"]?.toString());
      return;
    }

    // Không thêm message thật ở đây; sẽ nhận qua Firebase
    // (đính kèm URL nếu cần thiết có thể được dùng sau này)
    // final attachmentUrl = _extractAttachmentUrl(res);
    // final messageText = chatController.text.isNotEmpty
    //     ? chatController.text
    //     : "${isImage ? '[Ảnh]' : '[Tệp]'} $filename";

    chatController.clear();
  }

  // (Optional) Previously used to extract attachment URL from API response.
  // Kept here commented for future needs.
  // String? _extractAttachmentUrl(Map res) { ... }

  // ============================================================================
  // UI BUILDERS - IMAGE WIDGETS
  // ============================================================================

  Widget _buildSmartImageWidget(String imageUrl) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: Get.width * 0.6,
        maxHeight: Get.height * 0.3,
        minHeight: 100,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildImagePlaceholder(),
          errorWidget: (context, url, error) => _buildImageError(url),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text(
              'Đang tải ảnh...',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageError(String url) {
    return Container(
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image, color: Colors.grey, size: 32),
          const SizedBox(height: 8),
          const Text(
            'Không thể tải ảnh',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            'URL: $url',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showImageViewer(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: _buildImageViewerAppBar(),
          body: _buildImageViewerBody(imageUrl),
        ),
      ),
    );
  }

  AppBar _buildImageViewerAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Text(
        'Xem ảnh',
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.download, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tính năng tải xuống đang phát triển'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildImageViewerBody(String imageUrl) {
    return Center(
      child: InteractiveViewer(
        panEnabled: true,
        boundaryMargin: const EdgeInsets.all(20),
        minScale: 0.5,
        maxScale: 4.0,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          placeholder: (context, url) => _buildViewerPlaceholder(),
          errorWidget: (context, url, error) => _buildViewerError(url),
        ),
      ),
    );
  }

  Widget _buildViewerPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Đang tải ảnh...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildViewerError(String url) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image, color: Colors.white, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Không thể tải ảnh',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vui lòng kiểm tra kết nối mạng',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'URL: $url',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // UI BUILDERS - MESSAGE WIDGETS
  // ============================================================================

  Widget _buildMessageContent(Map convData) {
    final message = convData["message"];
    final attachmentData = _parseAttachments(convData["attachments"]);

    if (attachmentData["type"] == 'image') {
      final String? imageUrl = attachmentData["url"];
      final String? localPath = attachmentData["localPath"];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        return GestureDetector(
          onTap: () => _showImageViewer(imageUrl),
          child: _buildSmartImageWidget(imageUrl),
        );
      }
      if (localPath != null &&
          localPath.isNotEmpty &&
          File(localPath).existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(localPath),
            fit: BoxFit.cover,
            width: Get.width * 0.6,
            height: Get.height * 0.3,
            errorBuilder: (context, error, stack) =>
                _buildImageError(localPath),
          ),
        );
      }
    }

    if (attachmentData["url"] != null) {
      return _buildFileAttachment(message, attachmentData["url"]!);
    }

    if (message == null) return Container();

    return Text(
      message,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
    );
  }

  Map<String, String?> _parseAttachments(dynamic raw) {
    try {
      if (raw != null && raw.toString().trim().isNotEmpty) {
        final List list = jsonDecode(raw);
        if (list.isNotEmpty) {
          final Map att = list.first as Map;
          return {
            "type": att["type"]?.toString(),
            "url": att["payload"]?["url"]?.toString(),
            "localPath": att["payload"]?["localPath"]?.toString(),
          };
        }
      }
    } catch (e) {
      log("Error parsing attachments: $e");
    }
    return {"type": null, "url": null, "localPath": null};
  }

  Widget _buildFileAttachment(String? message, String url) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.attach_file_rounded, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              message ?? url.split('/').last.split('?').first,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map convData, int index) {
    final isPersonal = convData["to"] != widget.personId;
    final messagePosition =
        getMessagePosition(convList, index, widget.personId!);
    final borderRadius = getMessageBorderRadius(messagePosition, isPersonal);

    final createdTime =
        DateTime.fromMillisecondsSinceEpoch(convData["timestamp"]);
    final fullTime = DateFormat('dd-MM-yyyy HH:mm:ss').format(createdTime);
    final bool isTemp = (convData["isTemp"] == true);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAvatar(isPersonal, messagePosition),
        const SizedBox(width: 5),
        Padding(
          padding: EdgeInsets.only(
            top: (messagePosition == MessagePosition.LastInReply ||
                    messagePosition == MessagePosition.Single)
                ? 8
                : 0,
          ),
          child: Tooltip(
            message: fullTime,
            triggerMode: TooltipTriggerMode.tap,
            child: Container(
              constraints: BoxConstraints(maxWidth: Get.width - 80),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                color: isPersonal ? Colors.white : const Color(0xFFE3DFFF),
              ),
              child: Opacity(
                opacity: isTemp ? 0.6 : 1,
                child: Stack(
                  children: [
                    _buildMessageContent(convData),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(bool isPersonal, MessagePosition position) {
    if (!isPersonal ||
        (position != MessagePosition.Single &&
            position != MessagePosition.FirstInReply)) {
      return const SizedBox(width: 32);
    }

    return AppAvatar(
      imageUrl: widget.personAvatar ?? defaultAvatar,
      size: 32,
      shape: AvatarShape.circle,
      fallbackText: widget.personName!,
    );
  }

  Widget _buildDateDivider(String time, {bool isLastMessage = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isLastMessage ? 0 : 12.0,
      ).copyWith(bottom: isLastMessage ? 12.0 : 0),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Colors.black54)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              isLastMessage ? "Cuộc trò chuyện bắt đầu vào $time" : time,
            ),
          ),
          const Expanded(child: Divider(color: Colors.black54)),
        ],
      ),
    );
  }

  // ============================================================================
  // UI BUILDERS - MAIN LAYOUT
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Theme(
          data: ThemeData(primaryColor: Colors.white),
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F8F8),
            appBar: _buildAppBar(),
            body: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusScope.of(context).unfocus(),
              child: SafeArea(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 50.0),
                      child: _buildMessageList(),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildChatBottom(isKeyboardVisible),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F8F8),
      elevation: 2,
      shadowColor: Colors.black54,
      title: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          _conversationPersonName ?? widget.personName ?? '',
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        subtitle: Text(
          _conversationPageName ?? widget.pageName ?? '',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: const TextStyle(fontSize: 12),
        ),
        leading: AppAvatar(
          imageUrl: (_conversationPersonAvatar ?? widget.personAvatar) ??
              defaultAvatar,
          size: 44,
          shape: AvatarShape.circle,
          fallbackText: _conversationPersonName ?? widget.personName ?? '',
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            _showMemberSelectionDialog();
          },
          icon: (_conversationAssignId ?? widget.assignId) != null
              ? (widget.assignAvatar) == null
                  ? createCircleAvatar(
                      name: _conversationAssignName ?? widget.assignName ?? '',
                      radius: 14)
                  : CircleAvatar(
                      backgroundImage: getAvatarProvider(
                        (_conversationAssignAvatar ?? widget.assignAvatar) ??
                            defaultAvatar,
                      ),
                      radius: 14,
                    )
              : const Icon(Icons.person_add),
        ),
      ],
      automaticallyImplyLeading: true,
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  Widget _buildMessageList() {
    return SizedBox(
      height: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ListView.builder(
            controller: sc,
            itemCount: convList.length,
            padding: const EdgeInsets.symmetric(vertical: 20),
            itemBuilder: _buildMessageItem,
            shrinkWrap: true,
            reverse: true,
          ),
          if (isConvFetching)
            const Center(
              child: Positioned(
                top: 5,
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, int index) {
    final convData = convList[index];
    final createdTime = DateTime.fromMillisecondsSinceEpoch(
      convData["timestamp"],
    );
    final time = diffFunc(createdTime);

    final previousMessageTime = index < convList.length - 1
        ? DateTime.fromMillisecondsSinceEpoch(convList[index + 1]["timestamp"])
        : null;

    final isSameDay = previousMessageTime != null &&
        createdTime.year == previousMessageTime.year &&
        createdTime.month == previousMessageTime.month &&
        createdTime.day == previousMessageTime.day;

    final isPersonal = convData["to"] != widget.personId;
    final bool isTemp = (convData["isTemp"] == true);
    final int status =
        (convData["status"] is int) ? convData["status"] as int : 1;
    return Row(
      // mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            children: [
              if (convList.length - 1 == index && isLastMessage)
                _buildDateDivider(time, isLastMessage: true),
              if (!isSameDay && convList.length - 1 != index && index != 0)
                _buildDateDivider(time),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 2, 8, 2),
                alignment:
                    isPersonal ? Alignment.centerLeft : Alignment.centerRight,
                child: _buildMessageBubble(convData, index),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 8),
          child: Builder(builder: (context) {
            if (isTemp && status == 0) {
              return const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            }
            if (isTemp && status == -1) {
              return Tooltip(
                message: (convData["error"]?.toString() ?? "Gửi thất bại"),
                triggerMode: TooltipTriggerMode.tap,
                child: const Icon(Icons.error, size: 16, color: Colors.red),
              );
            }

            return Container();
          }),
        )
      ],
    );
  }

  Widget _buildChatBottom(bool isKeyboardVisible) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 237, 237, 240),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
        children: [
          if (chatController.text.trim().isEmpty) ...[
            _buildIconButton(
              onPressed: onPickImageFromGallery,
              icon: SvgPicture.asset(
                "assets/icons/img_icon.svg",
                color: const Color(0xFF554FE8),
              ),
            ),
            _buildIconButton(
              onPressed: onPickFileFromDevice,
              icon: const Icon(
                Icons.attach_file_rounded,
                color: Color(0xFF554FE8),
              ),
            ),
          ],
          Expanded(child: _buildTextField()),
          _buildSendButton(isKeyboardVisible),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required VoidCallback onPressed,
    required Widget icon,
  }) {
    return IconButton(onPressed: onPressed, icon: icon);
  }

  Widget _buildTextField() {
    return TextFormField(
      cursorColor: Colors.black,
      controller: chatController,
      maxLines: 5,
      minLines: 1,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Color.fromARGB(255, 237, 237, 240),
        hintText: "Nhập nội dung",
      ),
    );
  }

  Widget _buildSendButton(bool isKeyboardVisible) {
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: !isKeyboardVisible
            ? const Color(0xFF554FE8).withOpacity(0.2)
            : const Color(0xFF554FE8),
      ),
      child: IconButton(
        onPressed: sendMessage,
        icon: SvgPicture.asset(
          "assets/icons/send_1_icon.min.svg",
          color: Colors.white,
        ),
      ),
    );
  }

  void _showMemberSelectionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: MemberSelectionDialog(
          conversationId: widget.convId,
          assignedId: _conversationAssignId ?? widget.assignId,
          onMemberSelected: (member) {
            // Handle member selection here
            print(
                'Selected member: ${member['fullName']} (${member['email']})');
            // The assignment is now handled automatically by the dialog
          },
          onAssignmentSuccess: () {
            // Reload conversation details sau khi assignment thành công
            _loadConversationDetails();
          },
        ),
      ),
    );
  }
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

MessagePosition getMessagePosition(
  List convList,
  int index,
  String currentPersonId,
) {
  final convData = convList[index];
  final isPersonal = convData["to"] != currentPersonId;

  if (convList.length == 1) return MessagePosition.Single;

  if (index == 0) {
    final nextIsPersonal = convList[index + 1]["to"] != currentPersonId;
    return isPersonal == nextIsPersonal
        ? MessagePosition.FirstInReply
        : MessagePosition.Single;
  }

  if (index == convList.length - 1) {
    final prevIsPersonal = convList[index - 1]["to"] != currentPersonId;
    return isPersonal == prevIsPersonal
        ? MessagePosition.LastInReply
        : MessagePosition.Single;
  }

  final prevIsPersonal = convList[index - 1]["to"] != currentPersonId;
  final nextIsPersonal = convList[index + 1]["to"] != currentPersonId;

  if (isPersonal != prevIsPersonal && isPersonal == nextIsPersonal) {
    return MessagePosition.FirstInReply;
  } else if (isPersonal == prevIsPersonal && isPersonal != nextIsPersonal) {
    return MessagePosition.LastInReply;
  } else if (isPersonal == prevIsPersonal && isPersonal == nextIsPersonal) {
    return MessagePosition.MiddleInReply;
  }

  return MessagePosition.Single;
}

BorderRadius getMessageBorderRadius(MessagePosition position, bool isPersonal) {
  const double normalRadius = 14;
  const double tightRadius = 3;

  if (isPersonal) {
    switch (position) {
      case MessagePosition.Single:
        return BorderRadius.circular(normalRadius);
      case MessagePosition.LastInReply:
        return const BorderRadius.only(
          topLeft: Radius.circular(normalRadius),
          topRight: Radius.circular(normalRadius),
          bottomRight: Radius.circular(normalRadius),
          bottomLeft: Radius.circular(tightRadius),
        );
      case MessagePosition.MiddleInReply:
        return const BorderRadius.only(
          topLeft: Radius.circular(tightRadius),
          topRight: Radius.circular(normalRadius),
          bottomRight: Radius.circular(normalRadius),
          bottomLeft: Radius.circular(tightRadius),
        );
      case MessagePosition.FirstInReply:
        return const BorderRadius.only(
          topLeft: Radius.circular(tightRadius),
          topRight: Radius.circular(normalRadius),
          bottomRight: Radius.circular(normalRadius),
          bottomLeft: Radius.circular(normalRadius),
        );
    }
  } else {
    switch (position) {
      case MessagePosition.Single:
        return BorderRadius.circular(normalRadius);
      case MessagePosition.LastInReply:
        return const BorderRadius.only(
          topLeft: Radius.circular(normalRadius),
          topRight: Radius.circular(normalRadius),
          bottomRight: Radius.circular(tightRadius),
          bottomLeft: Radius.circular(normalRadius),
        );
      case MessagePosition.MiddleInReply:
        return const BorderRadius.only(
          topLeft: Radius.circular(normalRadius),
          topRight: Radius.circular(tightRadius),
          bottomRight: Radius.circular(tightRadius),
          bottomLeft: Radius.circular(normalRadius),
        );
      case MessagePosition.FirstInReply:
        return const BorderRadius.only(
          topLeft: Radius.circular(normalRadius),
          topRight: Radius.circular(tightRadius),
          bottomRight: Radius.circular(normalRadius),
          bottomLeft: Radius.circular(normalRadius),
        );
    }
  }
}
