# Hướng Dẫn Implement Logic Upload Ảnh và File trong Flutter

## 1. Thêm Dependencies

Trong file `pubspec.yaml`, thêm các dependencies sau:

```yaml
dependencies:
  image_picker: ^1.0.4
  file_picker: ^6.1.1
  dio: ^5.3.2
  permission_handler: ^11.0.1
  path: ^1.8.3
  mime: ^1.0.4
```

## 2. Cấu Hình Permissions

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS (ios/Runner/Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>Ứng dụng cần quyền truy cập camera để chụp ảnh</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Ứng dụng cần quyền truy cập thư viện ảnh để chọn ảnh</string>
```

## 3. Tạo Service Upload File

Tạo file `lib/api/upload_service.dart`:

```dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class UploadService {
  static final Dio _dio = Dio();

  // Upload single file
  static Future<Map<String, dynamic>> uploadFile(File file) async {
    try {
      String fileName = path.basename(file.path);
      String? mimeType = lookupMimeType(file.path);
      
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType ?? 'application/octet-stream'),
        ),
      });

      Response response = await _dio.post(
        'YOUR_UPLOAD_ENDPOINT',
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
          },
        ),
        onSendProgress: (sent, total) {
          // Callback để theo dõi tiến trình upload
          print('Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%');
        },
      );

      return {
        'success': true,
        'data': response.data,
        'url': response.data['url'], // URL của file đã upload
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Upload multiple files
  static Future<List<Map<String, dynamic>>> uploadMultipleFiles(List<File> files) async {
    List<Map<String, dynamic>> results = [];
    
    for (File file in files) {
      Map<String, dynamic> result = await uploadFile(file);
      results.add(result);
    }
    
    return results;
  }
}
```

## 4. Tạo File Picker Helper

Tạo file `lib/utils/file_picker_helper.dart`:

```dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class FilePickerHelper {
  static final ImagePicker _imagePicker = ImagePicker();

  // Kiểm tra và yêu cầu permissions
  static Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();

    return statuses[Permission.camera]!.isGranted && 
           statuses[Permission.storage]!.isGranted;
  }

  // Chọn ảnh từ camera
  static Future<File?> pickImageFromCamera() async {
    bool hasPermission = await requestPermissions();
    if (!hasPermission) return null;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  // Chọn ảnh từ gallery
  static Future<File?> pickImageFromGallery() async {
    bool hasPermission = await requestPermissions();
    if (!hasPermission) return null;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  // Chọn nhiều ảnh từ gallery
  static Future<List<File>> pickMultipleImages() async {
    bool hasPermission = await requestPermissions();
    if (!hasPermission) return [];

    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );
      
      return images.map((image) => File(image.path)).toList();
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }

  // Chọn file bất kỳ
  static Future<File?> pickFile({List<String>? allowedExtensions}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }

  // Chọn nhiều file
  static Future<List<File>> pickMultipleFiles({List<String>? allowedExtensions}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
      );

      if (result != null) {
        return result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error picking multiple files: $e');
      return [];
    }
  }

  // Hiển thị dialog chọn source cho ảnh
  static Future<File?> showImageSourceDialog(BuildContext context) async {
    return showDialog<File?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chọn nguồn ảnh'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  File? image = await pickImageFromCamera();
                  Navigator.pop(context, image);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Thư viện ảnh'),
                onTap: () async {
                  Navigator.pop(context);
                  File? image = await pickImageFromGallery();
                  Navigator.pop(context, image);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
```

## 5. Tạo Upload Controller với GetX

Tạo file `lib/controllers/upload_controller.dart`:

```dart
import 'dart:io';
import 'package:get/get.dart';
import '../api/upload_service.dart';
import '../utils/file_picker_helper.dart';

class UploadController extends GetxController {
  var isUploading = false.obs;
  var uploadProgress = 0.0.obs;
  var selectedFiles = <File>[].obs;
  var uploadedUrls = <String>[].obs;

  // Upload single image
  Future<String?> uploadImage({bool fromCamera = false}) async {
    try {
      isUploading(true);
      
      File? imageFile;
      if (fromCamera) {
        imageFile = await FilePickerHelper.pickImageFromCamera();
      } else {
        imageFile = await FilePickerHelper.pickImageFromGallery();
      }

      if (imageFile == null) {
        isUploading(false);
        return null;
      }

      Map<String, dynamic> result = await UploadService.uploadFile(imageFile);
      
      if (result['success']) {
        String url = result['url'];
        uploadedUrls.add(url);
        Get.snackbar('Thành công', 'Upload ảnh thành công');
        return url;
      } else {
        Get.snackbar('Lỗi', 'Upload ảnh thất bại: ${result['error']}');
        return null;
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Có lỗi xảy ra: $e');
      return null;
    } finally {
      isUploading(false);
    }
  }

  // Upload multiple images
  Future<List<String>> uploadMultipleImages() async {
    try {
      isUploading(true);
      
      List<File> imageFiles = await FilePickerHelper.pickMultipleImages();
      if (imageFiles.isEmpty) {
        isUploading(false);
        return [];
      }

      List<Map<String, dynamic>> results = await UploadService.uploadMultipleFiles(imageFiles);
      
      List<String> urls = [];
      for (var result in results) {
        if (result['success']) {
          urls.add(result['url']);
        }
      }

      uploadedUrls.addAll(urls);
      Get.snackbar('Thành công', 'Upload ${urls.length} ảnh thành công');
      return urls;
    } catch (e) {
      Get.snackbar('Lỗi', 'Có lỗi xảy ra: $e');
      return [];
    } finally {
      isUploading(false);
    }
  }

  // Upload file
  Future<String?> uploadFile({List<String>? allowedExtensions}) async {
    try {
      isUploading(true);
      
      File? file = await FilePickerHelper.pickFile(allowedExtensions: allowedExtensions);
      if (file == null) {
        isUploading(false);
        return null;
      }

      Map<String, dynamic> result = await UploadService.uploadFile(file);
      
      if (result['success']) {
        String url = result['url'];
        uploadedUrls.add(url);
        Get.snackbar('Thành công', 'Upload file thành công');
        return url;
      } else {
        Get.snackbar('Lỗi', 'Upload file thất bại: ${result['error']}');
        return null;
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Có lỗi xảy ra: $e');
      return null;
    } finally {
      isUploading(false);
    }
  }

  // Xóa file đã upload
  void removeUploadedFile(String url) {
    uploadedUrls.remove(url);
  }

  // Clear all uploaded files
  void clearUploadedFiles() {
    uploadedUrls.clear();
  }
}
```

## 6. Tạo UI Component cho Upload

Tạo file `lib/components/upload_widget.dart`:

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/upload_controller.dart';

class UploadWidget extends StatelessWidget {
  final Function(List<String>)? onFilesUploaded;
  final bool allowMultiple;
  final bool imagesOnly;
  final List<String>? allowedExtensions;

  const UploadWidget({
    Key? key,
    this.onFilesUploaded,
    this.allowMultiple = true,
    this.imagesOnly = true,
    this.allowedExtensions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UploadController uploadController = Get.put(UploadController());

    return Obx(() => Column(
      children: [
        // Upload buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (imagesOnly) ...[
              ElevatedButton.icon(
                onPressed: uploadController.isUploading.value ? null : () async {
                  String? url = await uploadController.uploadImage(fromCamera: true);
                  if (url != null && onFilesUploaded != null) {
                    onFilesUploaded!([url]);
                  }
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
              ),
              ElevatedButton.icon(
                onPressed: uploadController.isUploading.value ? null : () async {
                  if (allowMultiple) {
                    List<String> urls = await uploadController.uploadMultipleImages();
                    if (urls.isNotEmpty && onFilesUploaded != null) {
                      onFilesUploaded!(urls);
                    }
                  } else {
                    String? url = await uploadController.uploadImage();
                    if (url != null && onFilesUploaded != null) {
                      onFilesUploaded!([url]);
                    }
                  }
                },
                icon: const Icon(Icons.photo_library),
                label: Text(allowMultiple ? 'Chọn ảnh' : 'Chọn ảnh'),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: uploadController.isUploading.value ? null : () async {
                  String? url = await uploadController.uploadFile(
                    allowedExtensions: allowedExtensions,
                  );
                  if (url != null && onFilesUploaded != null) {
                    onFilesUploaded!([url]);
                  }
                },
                icon: const Icon(Icons.attach_file),
                label: const Text('Chọn file'),
              ),
            ],
          ],
        ),
        
        // Loading indicator
        if (uploadController.isUploading.value)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        
        // Uploaded files list
        if (uploadController.uploadedUrls.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Files đã upload:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...uploadController.uploadedUrls.map((url) => 
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        if (imagesOnly)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              url,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error),
                            ),
                          )
                        else
                          const Icon(Icons.insert_drive_file),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            url.split('/').last,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            uploadController.removeUploadedFile(url);
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ).toList(),
              ],
            ),
          ),
      ],
    ));
  }
}
```

## 7. Sử Dụng Upload Widget

Trong file UI bất kỳ, bạn có thể sử dụng như sau:

```dart
import 'package:flutter/material.dart';
import '../components/upload_widget.dart';

class MyUploadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Files')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Upload chỉ ảnh, cho phép nhiều file
            UploadWidget(
              imagesOnly: true,
              allowMultiple: true,
              onFilesUploaded: (urls) {
                print('Uploaded image URLs: $urls');
                // Xử lý URLs đã upload
              },
            ),
            
            const SizedBox(height: 20),
            
            // Upload file bất kỳ, chỉ 1 file
            UploadWidget(
              imagesOnly: false,
              allowMultiple: false,
              allowedExtensions: ['pdf', 'doc', 'docx'],
              onFilesUploaded: (urls) {
                print('Uploaded file URL: ${urls.first}');
                // Xử lý URL file đã upload
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

## 8. Xử Lý Error và Validation

### Validate file size
```dart
bool validateFileSize(File file, {int maxSizeInMB = 10}) {
  int fileSizeInBytes = file.lengthSync();
  int maxSizeInBytes = maxSizeInMB * 1024 * 1024;
  return fileSizeInBytes <= maxSizeInBytes;
}
```

### Validate file type
```dart
bool validateFileType(File file, List<String> allowedExtensions) {
  String extension = path.extension(file.path).toLowerCase();
  return allowedExtensions.contains(extension.substring(1));
}
```

## 9. Caching và Optimization

### Sử dụng cached_network_image cho hiển thị ảnh
```yaml
dependencies:
  cached_network_image: ^3.3.0
```

```dart
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)
```

## 10. Testing

### Test upload functionality
```dart
// test/upload_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:coka/api/upload_service.dart';

void main() {
  group('Upload Service Tests', () {
    test('should upload file successfully', () async {
      // Mock file and test upload
    });
    
    test('should handle upload errors', () async {
      // Test error scenarios
    });
  });
}
```

## Lưu Ý Quan Trọng

1. **Security**: Luôn validate file type và size ở cả client và server
2. **Performance**: Compress ảnh trước khi upload
3. **UX**: Hiển thị progress bar cho user
4. **Error Handling**: Xử lý các trường hợp lỗi network, permission
5. **Cleanup**: Xóa temporary files sau khi upload
6. **Backup**: Có plan backup cho các file đã upload

Hướng dẫn này cung cấp foundation hoàn chỉnh cho việc implement upload functionality trong Flutter app của bạn. 