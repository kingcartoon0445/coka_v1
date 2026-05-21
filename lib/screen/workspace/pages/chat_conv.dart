import 'dart:async';
import 'dart:convert';

import 'package:coka/api/conversation.dart';
import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatConvPage extends StatefulWidget {
  final String? personName,
      personId,
      personAvatar,
      convId,
      provider,
      pageName,
      pageAvatar;

  const ChatConvPage(
      {super.key,
      this.personName,
      this.personAvatar,
      this.convId,
      this.provider,
      this.pageName,
      this.pageAvatar,
      this.personId});

  @override
  State<ChatConvPage> createState() => _ChatConvPageState();
}

class _ChatConvPageState extends State<ChatConvPage> {
  final chatController = TextEditingController();
  final homeController = Get.put(HomeController());
  late StreamSubscription onChangedListener;
  ScrollController sc = ScrollController();
  var isLastMessage = false;
  var isConvFetching = false;
  var isConvEmpty = false;
  var convList = [];
  var offset = 0;
  String? latestMessagePreview;
  int? latestMessageTimestamp;
  bool _hasReceivedInitialRealtimeEvent = false;

  Future<bool> _handleBack() async {
    Get.back(result: {
      "snippet": latestMessagePreview,
      "updatedTime": latestMessageTimestamp,
    });
    return false;
  }

  Future onRefresh() async {
    isConvFetching = true;
    convList.clear();
    offset = 0;
    setState(() {});
    await Future.wait([fetchConvList()]);
    isConvFetching = false;
    setState(() {});
  }

  Timer? _debounce;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    onRefresh();
    ConvApi()
        .setRead(widget.convId)
        .then((value) => homeController.fetchConvUnread());
    sc.addListener(() async {
      if (sc.position.pixels >= sc.position.maxScrollExtent) {
        if (convList.isNotEmpty && !isConvFetching && !isLastMessage) {
          offset += 20;
          isConvFetching = true;
          setState(() {});
          await fetchConvList();
          isConvFetching = false;
          setState(() {});
        }
      }
    });
    getOData().then((value) {
      final oId = jsonDecode(value)["id"];
      DatabaseReference convRef = FirebaseDatabase.instance
          .ref('root/OrganizationId: $oId/CreateOrUpdateConversation');
      onChangedListener = convRef.onValue.listen((event) {
        final value = event.snapshot.value;
        if (value is! Map) return;

        final data = Map<String, dynamic>.from(value);
        if (!_hasReceivedInitialRealtimeEvent) {
          _hasReceivedInitialRealtimeEvent = true;
          return;
        }

        if (data["ConversationId"] == widget.convId) {
          final latestMessage = convList.isNotEmpty ? convList.first : null;
          final isDuplicate = latestMessage != null &&
              latestMessage["message"] == data["Message"] &&
              latestMessage["to"] == data["To"];
          if (isDuplicate) return;

          addMessage(data["Message"], data["To"], data["ToName"]);
        }
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    onChangedListener.cancel();

    // onValueListener.cancel();
    // onAddedListener.cancel();
  }

  Future fetchConvList() async {
    await ConvApi().getConvList(widget.convId, offset).then((res) {
      if (isSuccessStatus(res["code"])) {
        convList.addAll(res["content"]);
        if (convList.isEmpty) {
          isConvEmpty = true;
        } else {
          if (convList.length >= res["metadata"]["total"]) {
            isLastMessage = true;
          } else {
            isLastMessage = false;
          }
          isConvEmpty = false;
        }
      } else {
        errorAlert(title: "Lỗi", desc: res["message"]);
      }
    });
  }

  void addMessage(message, to, toName) async {
    setState(() {
      convList.insert(0, {
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "to": to,
        "toName": toName,
        "message": message,
        "isGpt": false,
        "type": "MESSAGE",
        "status": 1
      });
    });
  }

  Future sendMessage() async {
    final message = chatController.text.trim();
    if (message.isEmpty) return;

    addMessage(message, widget.personId, widget.personName);
    latestMessagePreview = message;
    latestMessageTimestamp = DateTime.now().millisecondsSinceEpoch;
    ConvApi().sendConv({
      "conversationId": widget.convId,
      "messageId": null,
      "message": message
    }).then((res) {
      if (res is! Map<String, dynamic>) {
        errorAlert(
            title: "Lỗi",
            desc: "Không thể gửi tin nhắn. Phản hồi từ hệ thống không hợp lệ.");
        return;
      }

      if (!isSuccessStatus(res["code"])) {
        print(res);
        errorAlert(
            title: "Lỗi",
            desc: res["message"] ??
                "Không thể gửi tin nhắn. Vui lòng thử lại sau.");
      }
    });
    chatController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return Theme(
        data: ThemeData(primaryColor: Colors.white),
        child: WillPopScope(
          onWillPop: _handleBack,
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F8F8),
            appBar: AppBar(
              backgroundColor: const Color(0xFFF8F8F8),
              elevation: 2,
              shadowColor: Colors.black54,
              leading: IconButton(
                onPressed: _handleBack,
                icon: const Icon(Icons.arrow_back),
              ),
              title: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    widget.personName!,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                  subtitle: Text(widget.pageName!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 12)),
                  leading: widget.personAvatar == null
                      ? createCircleAvatar(name: widget.personName!, radius: 20)
                      : CircleAvatar(
                          backgroundImage: getAvatarProvider(
                              widget.personAvatar ?? defaultAvatar),
                          radius: 20,
                        )),
              automaticallyImplyLeading: false,
              iconTheme: const IconThemeData(color: Colors.black),
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50.0),
                    child: SizedBox(
                      height: double.infinity,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          ListView.builder(
                              controller: sc,
                              itemCount: convList.length,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              itemBuilder: (context, index) {
                                final convData = convList[index];
                                final message = convData["message"];
                                final isPersonal =
                                    convData["to"] == widget.personId
                                        ? false
                                        : true;

                                final messagePosition = getMessagePosition(
                                    convList, index, widget.personId!);
                                final createdTime =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        convData["timestamp"]);
                                final previousMessageTime =
                                    index < convList.length - 1
                                        ? DateTime.fromMillisecondsSinceEpoch(
                                            convList[index + 1]["timestamp"])
                                        : null;

                                final isSameDay = previousMessageTime != null &&
                                    createdTime.year ==
                                        previousMessageTime.year &&
                                    createdTime.month ==
                                        previousMessageTime.month &&
                                    createdTime.day == previousMessageTime.day;

                                final time = diffFunc(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        convData["timestamp"]));
                                final fullTime =
                                    DateFormat('dd-MM-yyyy HH:mm:ss').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            convData["timestamp"]));
                                final borderRadius = getMessageBorderRadius(
                                    messagePosition, isPersonal);
                                final isGpt = convData["isGpt"];
                                return message == null
                                    ? Container()
                                    : Column(
                                        children: [
                                          if (convList.length - 1 == index &&
                                              isLastMessage)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 12.0),
                                              child: Row(children: <Widget>[
                                                const Expanded(
                                                    child: Divider(
                                                  color: Colors.black54,
                                                )),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 4.0),
                                                  child: Text(
                                                    "Cuộc trò chuyện bắt đầu vào $time",
                                                  ),
                                                ),
                                                const Expanded(
                                                    child: Divider(
                                                  color: Colors.black54,
                                                )),
                                              ]),
                                            ),
                                          if (!isSameDay &&
                                              convList.length - 1 != index &&
                                              index != 0)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12.0),
                                              child: Center(child: Text(time)),
                                            ),
                                          Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 1),
                                              alignment: isPersonal
                                                  ? Alignment.centerLeft
                                                  : Alignment.centerRight,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  ((isPersonal &&
                                                              messagePosition
                                                                      .name ==
                                                                  "Single") ||
                                                          (isPersonal &&
                                                              messagePosition
                                                                      .name ==
                                                                  "FirstInReply"))
                                                      ? widget.personAvatar ==
                                                              null
                                                          ? createCircleAvatar(
                                                              name: widget
                                                                  .personName!,
                                                              radius: 16)
                                                          : CircleAvatar(
                                                              backgroundImage:
                                                                  getAvatarProvider(
                                                                      widget.personAvatar ??
                                                                          defaultAvatar),
                                                              radius: 16,
                                                            )
                                                      : const SizedBox(
                                                          width: 32,
                                                        ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: messagePosition
                                                                        .name ==
                                                                    "LastInReply" ||
                                                                messagePosition
                                                                        .name ==
                                                                    "Single"
                                                            ? 8
                                                            : 0),
                                                    child: Tooltip(
                                                      message: fullTime,
                                                      triggerMode:
                                                          TooltipTriggerMode
                                                              .tap,
                                                      child: Container(
                                                        constraints:
                                                            BoxConstraints(
                                                                maxWidth:
                                                                    Get.width -
                                                                        80),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 8,
                                                                horizontal: 12),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                borderRadius,
                                                            color: isPersonal
                                                                ? Colors.white
                                                                : const Color(
                                                                    0xFFE3DFFF)),
                                                        child: Text(
                                                          message,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black87),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                        ],
                                      );
                              },
                              shrinkWrap: true,
                              reverse: true),
                          if (isConvFetching)
                            const Positioned(
                                top: 5, child: CircularProgressIndicator())
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 0, // Đặt vị trí dưới cùng
                      left: 0, // Đặt vị trí bên trái
                      right: 0, // Đặt vị trí bên phải,
                      child: buildChatBottom(isKeyboardVisible))
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Container buildChatBottom(bool isKeyboardVisible) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Row(
        children: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.add,
                color: Color(0xFF554FE8),
              )),
          Expanded(
            child: TextFormField(
              cursorColor: Colors.black,
              controller: chatController,
              maxLines: 5,
              minLines: 1,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none),
                  filled: true,
                  fillColor: const Color(0x66F3EEEE),
                  hintText: "Nhập nội dung"),
            ),
          ),
          !isKeyboardVisible
              ? IconButton(
                  onPressed: () async {},
                  icon: SvgPicture.asset(
                    "assets/icons/img_icon.svg",
                    color: const Color(0xFF554FE8),
                  ))
              : IconButton(
                  onPressed: () async {
                    sendMessage();
                  },
                  icon: SvgPicture.asset(
                    "assets/icons/send_1_icon.svg",
                    color: const Color(0xFF554FE8),
                  ))
        ],
      ),
    );
  }
}

enum MessagePosition {
  Single,
  FirstInReply,
  MiddleInReply,
  LastInReply,
}

MessagePosition getMessagePosition(
    List convList, int index, String currentPersonId) {
  final convData = convList[index];
  final isPersonal = convData["to"] == currentPersonId ? false : true;

  if (convList.length == 1) {
    return MessagePosition.Single;
  } else if (index == 0) {
    final nextConvData = convList[index + 1];
    final nextIsPersonal = nextConvData["to"] == currentPersonId ? false : true;
    return isPersonal == nextIsPersonal
        ? MessagePosition.FirstInReply
        : MessagePosition.Single;
  } else if (index == convList.length - 1) {
    final prevConvData = convList[index - 1];
    final prevIsPersonal = prevConvData["to"] == currentPersonId ? false : true;
    return isPersonal == prevIsPersonal
        ? MessagePosition.LastInReply
        : MessagePosition.Single;
  } else {
    final prevConvData = convList[index - 1];
    final nextConvData = convList[index + 1];
    final prevIsPersonal = prevConvData["to"] == currentPersonId ? false : true;
    final nextIsPersonal = nextConvData["to"] == currentPersonId ? false : true;

    if (isPersonal != prevIsPersonal && isPersonal == nextIsPersonal) {
      return MessagePosition.FirstInReply;
    } else if (isPersonal == prevIsPersonal && isPersonal != nextIsPersonal) {
      return MessagePosition.LastInReply;
    } else if (isPersonal == prevIsPersonal && isPersonal == nextIsPersonal) {
      return MessagePosition.MiddleInReply;
    } else {
      return MessagePosition.Single;
    }
  }
}

BorderRadius getMessageBorderRadius(MessagePosition position, bool isPersonal) {
  if (isPersonal) {
    switch (position) {
      case MessagePosition.Single:
        return BorderRadius.circular(14);
      case MessagePosition.LastInReply:
        return const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
          bottomRight: Radius.circular(14),
          bottomLeft: Radius.circular(3),
        );
      case MessagePosition.MiddleInReply:
        return const BorderRadius.only(
          topLeft: Radius.circular(3),
          topRight: Radius.circular(14),
          bottomRight: Radius.circular(14),
          bottomLeft: Radius.circular(3),
        );
      case MessagePosition.FirstInReply:
        return const BorderRadius.only(
          topLeft: Radius.circular(3),
          topRight: Radius.circular(14),
          bottomRight: Radius.circular(14),
          bottomLeft: Radius.circular(14),
        );
      default:
        return BorderRadius.circular(14);
    }
  } else {
    switch (position) {
      case MessagePosition.Single:
        return BorderRadius.circular(14);
      case MessagePosition.LastInReply:
        return const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
          bottomRight: Radius.circular(3),
          bottomLeft: Radius.circular(14),
        );
      case MessagePosition.MiddleInReply:
        return const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(3),
          bottomRight: Radius.circular(3),
          bottomLeft: Radius.circular(14),
        );
      case MessagePosition.FirstInReply:
        return const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(3),
          bottomRight: Radius.circular(14),
          bottomLeft: Radius.circular(14),
        );
      default:
        return BorderRadius.circular(14);
    }
  }
}
