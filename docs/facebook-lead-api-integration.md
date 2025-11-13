# Facebook Lead API Integration

## Tổng quan

Tài liệu này mô tả cách sử dụng `selected` để gọi API Facebook Lead trong ứng dụng Coka.

## API Endpoint

**Endpoint:** `POST /api/v1/auth/facebook/lead/manual`

**Mô tả:** Cách 3: Kết nối tới Facebook Lead dùng AccessToken Page

## Headers

- `organizationId`: ID của tổ chức (string)
- `workspaceId`: ID của workspace (string)
- `Content-Type`: application/json
- `Authorization`: Bearer token

## Request Body

```json
{
  "accessTokens": [
    "string"
  ]
}
```

## Cách sử dụng trong code

### 1. API Method trong LeadApi

```dart
Future facebookLeadManualConnect(data) async {
  final apiToken = await getAccessToken();
  try {
    final response = await dio.post("/api/v1/auth/facebook/lead/manual",
        data: data,
        options: Options(headers: {
          "organizationId": jsonDecode(await getOData())["id"],
          "workspaceId": jsonDecode(await getOData())["workspaceId"],
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiToken",
        }));
    return response.data;
  } on DioException catch (e) {
    final response = e.response;
    if (response != null) {
      return response.data;
    } else {
      print(e.requestOptions);
      print(e.message);
    }
  }
}
```

### 2. Sử dụng selected để gọi API

```dart
if (selected != null && selected.isNotEmpty) {
  // Lấy access tokens từ các trang đã chọn
  final accessTokens = [
    for (final p in selected)
      p['access_token'] as String,
  ];
  
  // Gọi API Facebook Lead Manual Connect
  LeadApi()
      .facebookLeadManualConnect({
        "accessTokens": accessTokens,
      })
      .then((res) {
    Get.back(); // Đóng loading dialog
    if (isSuccessStatus(res["code"])) {
      final chatChannelController = Get.put(ChatChannelController());
      chatChannelController.onRefresh();
      Navigator.of(parentContext, rootNavigator: true).pop();
      successAlert(
          title: "Thành công", 
          desc: "Đã kết nối Facebook Lead thành công");
    } else {
      errorAlert(title: "Lỗi", desc: res["message"]);
    }
  }).catchError((error) {
    Get.back(); // Đóng loading dialog
    errorAlert(
        title: "Lỗi", 
        desc: "Có lỗi xảy ra khi kết nối Facebook Lead");
  });
}
```

## Luồng hoạt động

1. **Lấy danh sách Facebook Pages**: Người dùng đăng nhập Facebook và lấy danh sách các trang
2. **Chọn trang**: Hiển thị dialog cho phép người dùng chọn các trang muốn kết nối
3. **Lấy access tokens**: Từ các trang đã chọn, lấy access tokens
4. **Gọi API**: Sử dụng `selected` để tạo request body với access tokens
5. **Xử lý kết quả**: Hiển thị thông báo thành công hoặc lỗi

## Cấu trúc dữ liệu selected

```dart
List<Map<String, dynamic>> selected = [
  {
    'id': 'page_id_1',
    'name': 'Page Name 1',
    'access_token': 'page_access_token_1',
    'picture': {
      'data': {
        'url': 'avatar_url'
      }
    }
  },
  // ... các trang khác
];
```

## Xử lý lỗi

- **Lỗi API**: Hiển thị thông báo lỗi với message từ server
- **Lỗi network**: Hiển thị thông báo lỗi chung
- **Không có trang được chọn**: Không thực hiện gọi API

## Lưu ý

- Đảm bảo `selected` không null và không rỗng trước khi gọi API
- Access tokens phải hợp lệ và có quyền truy cập trang
- Luôn xử lý loading state khi gọi API
- Refresh danh sách kênh sau khi kết nối thành công
