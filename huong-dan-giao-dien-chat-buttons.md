# Hướng Dẫn Giao Diện và Logic 3 Nút Chat: Gửi Hình, File và Chuyển Phụ Trách

## Tổng Quan

Tài liệu này hướng dẫn chi tiết về giao diện và logic của 3 nút chính trong trang chat với khách hàng:
1. **Nút gửi hình ảnh** - Cho phép gửi ảnh từ gallery hoặc camera
2. **Nút gửi file** - Cho phép gửi documents, files đính kèm  
3. **Nút chuyển phụ trách** - Chuyển cuộc trò chuyện cho thành viên/team khác

## Kiến Trúc UI Components

### 1. Layout Tổng Thể

```dart
Container buildChatBottom(bool isKeyboardVisible) {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.only(top: 6, bottom: 10),
    child: Row(
      children: [
        // 1. Nút More Options (chứa 3 nút chính)
        buildMoreOptionsButton(),
        
        // 2. Text Input Field
        Expanded(child: buildTextInput()),
        
        // 3. Send/Image Toggle Button
        buildSendImageToggle(isKeyboardVisible),
      ],
    ),
  );
}
```

### 2. Trạng Thái UI

```dart
class _ChatConvPageState extends State<ChatConvPage> {
  bool isMoreOptionsVisible = false;    // Hiển thị menu tùy chọn
  bool isKeyboardVisible = false;       // Bàn phím có hiển thị
  bool isUploading = false;            // Đang upload file
  String uploadProgress = "";          // Progress của upload
  
  // Controllers
  final chatController = TextEditingController();
  final fileController = ImagePicker();
}
```

## Chi Tiết Implementation

### 1. Nút More Options (Nút Dấu Cộng)

#### Giao Diện:

```dart
Widget buildMoreOptionsButton() {
  return IconButton(
    onPressed: () {
      setState(() {
        isMoreOptionsVisible = !isMoreOptionsVisible;
      });
      if (isMoreOptionsVisible) {
        _showOptionsBottomSheet();
      }
    },
    icon: AnimatedRotation(
      turns: isMoreOptionsVisible ? 0.125 : 0, // Xoay 45 độ khi mở
      duration: Duration(milliseconds: 200),
      child: Icon(
        Icons.add,
        color: Color(0xFF554FE8),
        size: 24,
      ),
    ),
  );
}
```

#### Bottom Sheet Options:

```dart
void _showOptionsBottomSheet() {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header với thanh kéo
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Options Grid
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOptionItem(
                    icon: "assets/icons/image_icon.svg",
                    label: "Gửi hình",
                    onTap: _showImageSourceDialog,
                  ),
                  _buildOptionItem(
                    icon: "assets/icons/attachment_icon.svg", 
                    label: "Gửi file",
                    onTap: _pickFile,
                  ),
                  _buildOptionItem(
                    icon: "assets/icons/assign_to_icon.svg",
                    label: "Chuyển phụ trách", 
                    onTap: _showAssignBottomSheet,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildOptionItem({
  required String icon,
  required String label,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(0xFFE3DFFF), width: 1),
          ),
          child: Center(
            child: SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              color: Color(0xFF554FE8),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF2D2D2D),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
```

### 2. Nút Gửi Hình Ảnh

#### Dialog Chọn Nguồn Ảnh:

```dart
void _showImageSourceDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Chọn nguồn hình ảnh"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.camera_alt, color: Color(0xFF554FE8)),
            title: Text("Chụp ảnh"),
            onTap: () {
              Navigator.pop(context);
              _pickImageFromCamera();
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_library, color: Color(0xFF554FE8)),
            title: Text("Chọn từ thư viện"),
            onTap: () {
              Navigator.pop(context);
              _pickImageFromGallery();
            },
          ),
        ],
      ),
    ),
  );
}
```

#### Logic Chụp/Chọn Ảnh:

```dart
final ImagePicker _picker = ImagePicker();

Future<void> _pickImageFromCamera() async {
  try {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (image != null) {
      await _processAndSendImage(File(image.path));
    }
  } catch (e) {
    errorAlert(title: "Lỗi", desc: "Không thể chụp ảnh: $e");
  }
}

Future<void> _pickImageFromGallery() async {
  try {
    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (images.isNotEmpty) {
      for (var image in images) {
        await _processAndSendImage(File(image.path));
      }
    }
  } catch (e) {
    errorAlert(title: "Lỗi", desc: "Không thể chọn ảnh: $e");
  }
}
```

#### Xử Lý và Gửi Ảnh:

```dart
Future<void> _processAndSendImage(File imageFile) async {
  // Hiển thị loading trong UI
  setState(() {
    isUploading = true;
    uploadProgress = "Đang xử lý ảnh...";
  });
  
  try {
    // Compress ảnh nếu cần
    final compressedImage = await _compressImage(imageFile);
    
    // Upload lên server
    setState(() {
      uploadProgress = "Đang tải lên...";
    });
    
    final uploadResult = await _uploadImage(compressedImage);
    
    if (uploadResult['success']) {
      // Thêm message với ảnh vào conversation
      final imageMessage = {
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "to": widget.personId,
        "toName": widget.personName,
        "message": "",
        "imageUrl": uploadResult['url'],
        "type": "IMAGE",
        "status": 1,
      };
      
      setState(() {
        convList.insert(0, imageMessage);
      });
      
      // Gửi lên server
      await ConvApi().sendConv({
        "conversationId": widget.convId,
        "message": "",
        "imageUrl": uploadResult['url'],
        "type": "IMAGE",
      });
      
    } else {
      errorAlert(title: "Lỗi", desc: "Không thể tải ảnh lên server");
    }
    
  } catch (e) {
    errorAlert(title: "Lỗi", desc: "Lỗi xử lý ảnh: $e");
  } finally {
    setState(() {
      isUploading = false;
      uploadProgress = "";
    });
  }
}

Future<File> _compressImage(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  final image = img.decodeImage(bytes);
  
  if (image != null) {
    // Resize nếu quá lớn
    img.Image resized = image;
    if (image.width > 1920 || image.height > 1080) {
      resized = img.copyResize(image, width: 1920, height: 1080);
    }
    
    // Compress
    final compressedBytes = img.encodeJpg(resized, quality: 85);
    
    // Save compressed file
    final compressedFile = File('${imageFile.path}_compressed.jpg');
    await compressedFile.writeAsBytes(compressedBytes);
    
    return compressedFile;
  }
  
  return imageFile;
}
```

#### UI Hiển Thị Ảnh Trong Chat:

```dart
Widget buildImageMessage(Map messageData) {
  return Container(
    constraints: BoxConstraints(
      maxWidth: Get.width * 0.7,
      maxHeight: 300,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: messageData['imageUrl'],
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 200,
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF554FE8),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: 200,
              color: Colors.grey[200],
              child: Icon(Icons.error, color: Colors.red),
            ),
          ),
        ),
        if (messageData['message']?.isNotEmpty == true) ...[
          SizedBox(height: 8),
          Text(
            messageData['message'],
            style: TextStyle(fontSize: 14),
          ),
        ],
      ],
    ),
  );
}
```

### 3. Nút Gửi File

#### Logic Chọn File:

```dart
Future<void> _pickFile() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
      allowedExtensions: null,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      
      // Kiểm tra kích thước file (max 10MB)
      if (file.size > 10 * 1024 * 1024) {
        errorAlert(
          title: "Lỗi", 
          desc: "File quá lớn. Vui lòng chọn file nhỏ hơn 10MB"
        );
        return;
      }
      
      await _processAndSendFile(file);
    }
  } catch (e) {
    errorAlert(title: "Lỗi", desc: "Không thể chọn file: $e");
  }
}
```

#### Xử Lý và Gửi File:

```dart
Future<void> _processAndSendFile(PlatformFile file) async {
  setState(() {
    isUploading = true;
    uploadProgress = "Đang tải file lên...";
  });
  
  try {
    // Upload file lên server
    final uploadResult = await _uploadFile(file);
    
    if (uploadResult['success']) {
      // Thêm message với file vào conversation
      final fileMessage = {
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "to": widget.personId,
        "toName": widget.personName,
        "message": file.name,
        "fileUrl": uploadResult['url'],
        "fileName": file.name,
        "fileSize": file.size,
        "fileExtension": file.extension,
        "type": "FILE",
        "status": 1,
      };
      
      setState(() {
        convList.insert(0, fileMessage);
      });
      
      // Gửi lên server
      await ConvApi().sendConv({
        "conversationId": widget.convId,
        "message": file.name,
        "fileUrl": uploadResult['url'],
        "type": "FILE",
      });
      
    } else {
      errorAlert(title: "Lỗi", desc: "Không thể tải file lên server");
    }
    
  } catch (e) {
    errorAlert(title: "Lỗi", desc: "Lỗi tải file: $e");
  } finally {
    setState(() {
      isUploading = false;
      uploadProgress = "";
    });
  }
}

Future<Map<String, dynamic>> _uploadFile(PlatformFile file) async {
  try {
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path!,
        filename: file.name,
      ),
      'type': 'chat_attachment',
    });
    
    final response = await ApiConfig().dio.post(
      '/api/v1/file/upload',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer ${await getAccessToken()}',
          'organizationId': jsonDecode(await getOData())["id"],
        },
      ),
      onSendProgress: (sent, total) {
        setState(() {
          uploadProgress = "Đang tải lên: ${(sent / total * 100).toInt()}%";
        });
      },
    );
    
    return {
      'success': true,
      'url': response.data['content']['url'],
    };
    
  } catch (e) {
    return {
      'success': false,
      'error': e.toString(),
    };
  }
}
```

#### UI Hiển Thị File Trong Chat:

```dart
Widget buildFileMessage(Map messageData) {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Color(0xFFF8F9FA),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Color(0xFFE9ECEF)),
    ),
    child: Row(
      children: [
        // File icon dựa theo extension
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getFileColor(messageData['fileExtension']),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              _getFileIcon(messageData['fileExtension']),
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        
        SizedBox(width: 12),
        
        // File info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                messageData['fileName'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D2D2D),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                _formatFileSize(messageData['fileSize']),
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6C757D),
                ),
              ),
            ],
          ),
        ),
        
        // Download button
        IconButton(
          onPressed: () => _downloadFile(messageData['fileUrl'], messageData['fileName']),
          icon: Icon(
            Icons.download,
            color: Color(0xFF554FE8),
          ),
        ),
      ],
    ),
  );
}

Color _getFileColor(String? extension) {
  switch (extension?.toLowerCase()) {
    case 'pdf':
      return Color(0xFFDC3545);
    case 'doc':
    case 'docx':
      return Color(0xFF007BFF);
    case 'xls':
    case 'xlsx':
      return Color(0xFF28A745);
    case 'ppt':
    case 'pptx':
      return Color(0xFFFF6B35);
    default:
      return Color(0xFF6C757D);
  }
}

IconData _getFileIcon(String? extension) {
  switch (extension?.toLowerCase()) {
    case 'pdf':
      return Icons.picture_as_pdf;
    case 'doc':
    case 'docx':
      return Icons.description;
    case 'xls':
    case 'xlsx':
      return Icons.table_chart;
    case 'ppt':
    case 'pptx':
      return Icons.slideshow;
    case 'zip':
    case 'rar':
      return Icons.folder_zip;
    default:
      return Icons.insert_drive_file;
  }
}

String _formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
```

### 4. Nút Chuyển Phụ Trách

#### Bottom Sheet Chuyển Phụ Trách:

```dart
void _showAssignBottomSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AssignToBottomSheet(
      onSelected: (data) {
        Navigator.pop(context);
        _assignConversation(data);
      },
    ),
  );
}

class AssignToBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onSelected;
  
  const AssignToBottomSheet({super.key, required this.onSelected});

  @override
  State<AssignToBottomSheet> createState() => _AssignToBottomSheetState();
}

class _AssignToBottomSheetState extends State<AssignToBottomSheet> {
  var memberList = [];
  var teamList = [];
  var filteredTeam = [];
  var isMemberFetching = false;
  var isTeamFetching = false;
  
  TextEditingController searchMemberController = TextEditingController();
  TextEditingController searchTeamController = TextEditingController();
  final homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height - 100,
      child: DefaultTabController(
        length: 2,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFEBEBEB)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.assignment_ind, 
                         color: Color(0xFF554FE8), size: 24),
                    SizedBox(width: 12),
                    Text(
                      "Chuyển phụ trách",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2329),
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              // Tab Bar
              TabBar(
                indicatorColor: Color(0xFF554FE8),
                labelColor: Color(0xFF554FE8),
                unselectedLabelColor: Color(0xFF6C757D),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person, size: 18),
                        SizedBox(width: 8),
                        Text("Thành viên"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group, size: 18),
                        SizedBox(width: 8),
                        Text("Đội Sale"),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  children: [
                    _buildMemberTab(),
                    _buildTeamTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMemberTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            controller: searchMemberController,
            decoration: InputDecoration(
              hintText: "Tìm kiếm thành viên...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFFE9ECEF)),
              ),
              filled: true,
              fillColor: Color(0xFFF8F9FA),
            ),
            onChanged: (value) => _searchMembers(value),
          ),
        ),
        
        // Member list
        Expanded(
          child: isMemberFetching
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: memberList.length,
                  itemBuilder: (context, index) {
                    final member = memberList[index];
                    final profile = member["profile"];
                    
                    return ListTile(
                      leading: profile["avatar"] == null
                          ? createCircleAvatar(
                              name: profile["fullName"], 
                              radius: 20
                            )
                          : CircleAvatar(
                              backgroundImage: getAvatarProvider(profile["avatar"]),
                              radius: 20,
                            ),
                      title: Text(
                        profile["fullName"],
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(member["team"]["name"]),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        widget.onSelected({
                          "type": "member",
                          "teamId": member["team"]["id"],
                          "assignTo": member["profileId"],
                          "assignToName": profile["fullName"],
                        });
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildTeamTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            controller: searchTeamController,
            decoration: InputDecoration(
              hintText: "Tìm kiếm đội sale...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFFE9ECEF)),
              ),
              filled: true,
              fillColor: Color(0xFFF8F9FA),
            ),
            onChanged: (value) => _searchTeams(value),
          ),
        ),
        
        // Team list
        Expanded(
          child: isTeamFetching
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: filteredTeam.length,
                  itemBuilder: (context, index) {
                    final team = filteredTeam[index];
                    
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0xFF554FE8).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.group,
                          color: Color(0xFF554FE8),
                        ),
                      ),
                      title: Text(
                        team["name"],
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text("${team["memberCount"] ?? 0} thành viên"),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        widget.onSelected({
                          "type": "team",
                          "teamId": team["id"],
                          "assignToName": team["name"],
                        });
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
```

#### Logic Chuyển Phụ Trách:

```dart
Future<void> _assignConversation(Map<String, dynamic> data) async {
  try {
    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text("Đang chuyển phụ trách..."),
          ],
        ),
      ),
    );
    
    // Call API chuyển phụ trách
    final response = await ConvApi().assignConversation({
      "conversationId": widget.convId,
      "teamId": data["teamId"],
      "assignTo": data["assignTo"],
      "type": data["type"],
    });
    
    Navigator.pop(context); // Đóng loading dialog
    
    if (isSuccessStatus(response["code"])) {
      // Thêm system message vào chat
      final systemMessage = {
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "message": "Cuộc trò chuyện đã được chuyển cho ${data['assignToName']}",
        "type": "SYSTEM",
        "isSystem": true,
      };
      
      setState(() {
        convList.insert(0, systemMessage);
      });
      
      // Hiển thị thông báo thành công
      successAlert(
        title: "Thành công",
        desc: "Đã chuyển phụ trách cho ${data['assignToName']}",
      );
      
      // Có thể redirect về trang trước hoặc disable input
      // Navigator.pop(context);
      
    } else {
      errorAlert(title: "Lỗi", desc: response["message"]);
    }
    
  } catch (e) {
    Navigator.pop(context); // Đóng loading dialog
    errorAlert(title: "Lỗi", desc: "Không thể chuyển phụ trách: $e");
  }
}
```

### 5. UI Hiển Thị Trạng Thái Upload

```dart
Widget buildUploadProgressIndicator() {
  if (!isUploading) return SizedBox.shrink();
  
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    color: Color(0xFFF8F9FA),
    child: Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF554FE8),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            uploadProgress,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6C757D),
            ),
          ),
        ),
        TextButton(
          onPressed: _cancelUpload,
          child: Text("Hủy"),
        ),
      ],
    ),
  );
}
```

### 6. Toggle Button Send/Image

```dart
Widget buildSendImageToggle(bool isKeyboardVisible) {
  return AnimatedSwitcher(
    duration: Duration(milliseconds: 200),
    child: !isKeyboardVisible
        ? IconButton(
            key: ValueKey("image"),
            onPressed: _showImageSourceDialog,
            icon: SvgPicture.asset(
              "assets/icons/img_icon.svg",
              color: Color(0xFF554FE8),
              width: 24,
              height: 24,
            ),
          )
        : IconButton(
            key: ValueKey("send"),
            onPressed: chatController.text.trim().isNotEmpty 
                ? sendMessage 
                : null,
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: chatController.text.trim().isNotEmpty
                    ? Color(0xFF554FE8)
                    : Color(0xFFE9ECEF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: SvgPicture.asset(
                "assets/icons/send_1_icon.svg",
                color: Colors.white,
                width: 16,
                height: 16,
              ),
            ),
          ),
  );
}
```

## Dependencies Cần Thiết

```yaml
dependencies:
  # Existing dependencies...
  
  # File & Image handling
  image_picker: ^1.0.4           # Chọn ảnh từ camera/gallery
  file_picker: ^6.1.1           # Chọn files
  image: ^4.1.3                 # Image processing
  cached_network_image: ^3.2.3  # Cache network images
  
  # Permissions
  permission_handler: ^11.0.1   # Xin quyền camera, storage
  
  # HTTP & Upload
  dio: ^5.3.2                   # HTTP client với upload progress
  
  # UI Components
  flutter_svg: ^2.0.7          # SVG icons
  get: ^4.6.5                   # State management
```

## Permissions Configuration

### Android (android/app/src/main/AndroidManifest.xml):

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS (ios/Runner/Info.plist):

```xml
<key>NSCameraUsageDescription</key>
<string>Ứng dụng cần quyền truy cập camera để chụp ảnh gửi tin nhắn</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Ứng dụng cần quyền truy cập thư viện ảnh để chọn ảnh gửi tin nhắn</string>
```

## Best Practices

### 1. Performance Optimization:

```dart
// Lazy load images
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(height: 200, color: Colors.white),
  ),
);

// Compress images trước khi upload
final compressedImage = await FlutterImageCompress.compressWithFile(
  imageFile.absolute.path,
  quality: 85,
  minWidth: 1920,
  minHeight: 1080,
);
```

### 2. Error Handling:

```dart
try {
  await _uploadFile(file);
} on DioException catch (e) {
  if (e.type == DioExceptionType.connectionTimeout) {
    errorAlert(title: "Lỗi", desc: "Kết nối mạng không ổn định");
  } else if (e.response?.statusCode == 413) {
    errorAlert(title: "Lỗi", desc: "File quá lớn để tải lên");
  } else {
    errorAlert(title: "Lỗi", desc: "Không thể tải file lên");
  }
} catch (e) {
  errorAlert(title: "Lỗi", desc: "Đã xảy ra lỗi không mong muốn");
}
```

### 3. Security:

```dart
// Validate file types
final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'pdf', 'doc', 'docx'];
if (!allowedExtensions.contains(file.extension?.toLowerCase())) {
  errorAlert(title: "Lỗi", desc: "Loại file không được hỗ trợ");
  return;
}

// Check file size
const maxFileSize = 10 * 1024 * 1024; // 10MB
if (file.size > maxFileSize) {
  errorAlert(title: "Lỗi", desc: "File quá lớn (tối đa 10MB)");
  return;
}
```

## Kết Luận

Hệ thống 3 nút này cung cấp:

1. **Gửi Hình Ảnh**:
   - Chụp ảnh từ camera hoặc chọn từ gallery
   - Compress và optimize ảnh
   - Upload với progress indicator
   - Hiển thị preview trong chat

2. **Gửi File**:
   - Chọn file từ device storage  
   - Validate loại file và kích thước
   - Upload với progress tracking
   - Hiển thị file info trong chat

3. **Chuyển Phụ Trách**:
   - Interface chọn thành viên hoặc team
   - Search và filter
   - API call assign conversation
   - System message notification

Tất cả được thiết kế với UX/UI mượt mà, error handling tốt và performance optimize. 