# Standalone Call Service

Service độc lập hoàn toàn để xử lý cuộc gọi tổng đài, không phụ thuộc vào bất kỳ file nào trong source hiện tại.

## Tính năng

- ✅ Khởi tạo và quản lý kết nối SIP độc lập
- ✅ Thực hiện cuộc gọi qua WebRTC
- ✅ Xử lý quyền microphone tự động
- ✅ Theo dõi trạng thái cuộc gọi (đổ chuông, kết nối, kết thúc)
- ✅ Đếm thời lượng cuộc gọi
- ✅ Gửi tracking lên server (tùy chọn)
- ✅ Callbacks để xử lý sự kiện
- ✅ Singleton pattern - dễ sử dụng

## Cài đặt

Service này sử dụng các package đã có trong `pubspec.yaml`:
- `sip_ua: ^1.0.1`
- `permission_handler: ^11.0.1`
- `flutter_webrtc: ^0.12.2`
- `dio: ^5.1.1`

Không cần cài đặt thêm package nào.

## Cách sử dụng

### 1. Tự động lấy name và password từ API (Khuyến nghị)

```dart
import 'package:your_app/standalone_call_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final callService = StandaloneCallService();

// Bước 1: Cấu hình API để lấy thông tin SIP
final prefs = await SharedPreferences.getInstance();
final token = prefs.getString('accessToken');
final oDataString = prefs.getString('oData');
final oData = jsonDecode(oDataString ?? '{}');

callService.configureCallCenterApi(
  apiUrl: 'https://callcenter.coka.ai',
  apiToken: token ?? '',
  organizationId: oData["id"],
);

// Bước 2: Tự động lấy thông tin và khởi tạo
final userId = 'your_user_id'; // Thường là userData["id"]
final result = await callService.initializeFromApi(userId: userId);

if (result["success"]) {
  print('✅ Đã khởi tạo với username: ${result["username"]}');
  // Service đã sẵn sàng để gọi
} else {
  print('❌ Lỗi: ${result["message"]}');
}
```

### 2. Sử dụng cơ bản (nếu đã có username và password)

```dart
import 'package:your_app/standalone_call_service.dart';

// Lấy instance của service
final callService = StandaloneCallService();

// Khởi tạo service với thông tin SIP
await callService.initialize(
  username: 'your_username',
  password: 'your_password',
);

// Thiết lập callbacks
callService.onStatusChanged = (message) {
  print('Status: $message');
};

callService.onCallDurationChanged = (duration) {
  print('Call duration: $duration');
};

callService.onError = (error) {
  print('Error: $error');
};

// Kiểm tra xem service đã sẵn sàng chưa
if (callService.isReady) {
  // Thực hiện cuộc gọi
  await callService.makeCall(
    phoneNumber: '84901234567',
  );
}

// Kết thúc cuộc gọi
callService.hangUp();

// Dọn dẹp khi không dùng nữa
callService.dispose();
```

### 2. Sử dụng với Tracking API

```dart
final callService = StandaloneCallService();

// Khởi tạo
await callService.initialize(
  username: 'your_username',
  password: 'your_password',
);

// Cấu hình Tracking API (tùy chọn)
callService.configureTracking(
  apiUrl: 'https://your-api-url.com',
  apiToken: 'your_api_token',
  workspaceId: 'workspace_id', // Tùy chọn
  organizationId: 'org_id', // Tùy chọn
);

// Gọi với tracking data
await callService.makeCall(
  phoneNumber: '84901234567',
  trackingData: {
    'contactId': 'contact_123',
    'phone': '84901234567',
    'extention': 'extension_name',
  },
);
```

### 3. Sử dụng với Widget

```dart
import 'package:your_app/standalone_call_service.dart';

StandaloneCallWidget(
  onStatusChanged: (message) {
    // Xử lý thay đổi trạng thái
  },
  onCallDurationChanged: (duration) {
    // Xử lý thay đổi thời lượng
  },
  onError: (error) {
    // Xử lý lỗi
  },
  child: YourWidget(),
)
```

## API Reference

### StandaloneCallService

#### Methods

- `Future<bool> initialize({required String username, required String password, ...})`
  - Khởi tạo service và đăng ký SIP
  - Trả về `true` nếu thành công

- `void configureCallCenterApi({required String apiUrl, required String apiToken, String? organizationId})`
  - Cấu hình API để lấy thông tin SIP từ server
  - Cần gọi trước khi dùng `initializeFromApi()`

- `Future<Map<String, dynamic>> initializeFromApi({required String userId})`
  - Tự động lấy thông tin SIP từ API và khởi tạo
  - Giải mã password tự động
  - Trả về Map với:
    - `"success"`: bool - Thành công hay không
    - `"username"`: String? - Tên extension
    - `"message"`: String - Thông báo

- `Future<Map<String, dynamic>?> fetchCallSetting()`
  - Lấy thông tin SIP từ API (không tự động khởi tạo)
  - Trả về Map chứa `name` và `passwordHash`, hoặc `null` nếu lỗi

- `String decryptPassword(String encryptedBase64, String key)`
  - Giải mã password từ passwordHash
  - `encryptedBase64`: Password đã mã hóa (base64)
  - `key`: Key để giải mã (thường là userId)

- `void configureTracking({required String apiUrl, required String apiToken, ...})`
  - Cấu hình API tracking (tùy chọn)

- `Future<bool> makeCall({required String phoneNumber, Map<String, dynamic>? trackingData})`
  - Thực hiện cuộc gọi
  - Tự động xin quyền microphone
  - Trả về `true` nếu thành công

- `void hangUp()`
  - Kết thúc cuộc gọi hiện tại

- `void dispose()`
  - Dọn dẹp và đóng kết nối

#### Properties

- `bool isReady` - Service đã sẵn sàng để gọi
- `bool isRegistered` - SIP đã đăng ký thành công
- `String callDuration` - Thời lượng cuộc gọi hiện tại (format: MM:SS)
- `Call? currentCall` - Cuộc gọi hiện tại

#### Callbacks

- `Function(String message)? onStatusChanged` - Khi trạng thái thay đổi
- `Function(String duration)? onCallDurationChanged` - Khi thời lượng thay đổi
- `Function(Call call)? onCallInitiated` - Khi cuộc gọi được khởi tạo
- `Function()? onCallEnded` - Khi cuộc gọi kết thúc
- `Function(String error)? onError` - Khi có lỗi xảy ra

## Cấu hình

### Cấu hình SIP mặc định

- WebSocket URL: `wss://vcwebrtc.voicecloud.vn:9443`
- Domain: `azvidi.voicecloud-platform.com`
- User Agent: `Dart SIP Client v1.0.0`

Có thể tùy chỉnh khi gọi `initialize()`:

```dart
await callService.initialize(
  username: 'your_username',
  password: 'your_password',
  webSocketUrl: 'wss://your-server.com:9443',
  domain: 'your-domain.com',
  userAgent: 'Your App Name',
);
```

## Xử lý lỗi

Service tự động xử lý các lỗi phổ biến:

- **SIP chưa đăng ký**: Hiển thị thông báo và không cho phép gọi
- **Không có quyền microphone**: Tự động mở cài đặt để cấp quyền
- **Lỗi kết nối**: Thông báo qua callback `onError`

## Lưu ý

1. **Quyền microphone**: Service tự động xin quyền, nhưng cần cấu hình trong `AndroidManifest.xml` và `Info.plist`

2. **SIP Registration**: Cần đợi SIP đăng ký thành công (`isReady = true`) trước khi gọi

3. **Singleton Pattern**: Service sử dụng singleton, chỉ có một instance duy nhất

4. **Dispose**: Nhớ gọi `dispose()` khi không dùng nữa để giải phóng tài nguyên

## Ví dụ đầy đủ

- `standalone_call_example.dart` - Các ví dụ sử dụng cơ bản
- `standalone_call_get_credentials_example.dart` - **Cách lấy name và password từ API** ⭐

## So sánh với code cũ

| Tính năng | Code cũ | Standalone Service |
|-----------|---------|-------------------|
| Phụ thuộc source | ✅ Có | ❌ Không |
| Có thể tái sử dụng | ❌ Khó | ✅ Dễ |
| Cấu hình linh hoạt | ❌ Cứng | ✅ Linh hoạt |
| Tracking API | ✅ Có | ✅ Có (tùy chọn) |
| Callbacks | ❌ Hạn chế | ✅ Đầy đủ |

## Cách lấy Name và Password

### Cách 1: Tự động từ API (Khuyến nghị)

```dart
// 1. Cấu hình API
callService.configureCallCenterApi(
  apiUrl: 'https://callcenter.coka.ai',
  apiToken: await getAccessToken(),
  organizationId: jsonDecode(await getOData())["id"],
);

// 2. Tự động lấy và khởi tạo
final result = await callService.initializeFromApi(
  userId: userData["id"], // ID của user
);
```

### Cách 2: Lấy thủ công rồi giải mã

```dart
// 1. Cấu hình API
callService.configureCallCenterApi(...);

// 2. Lấy thông tin từ API
final callData = await callService.fetchCallSetting();
final username = callData!["name"];
final passwordHash = callData["passwordHash"];

// 3. Giải mã password
final password = callService.decryptPassword(
  passwordHash,
  userData["id"], // Key để giải mã
);

// 4. Khởi tạo
await callService.initialize(
  username: username,
  password: password,
);
```

Xem file `standalone_call_get_credentials_example.dart` để xem ví dụ chi tiết.

## Troubleshooting

### SIP không đăng ký được
- Kiểm tra username/password
- Kiểm tra kết nối mạng
- Kiểm tra WebSocket URL và domain
- Nếu dùng `initializeFromApi()`, kiểm tra:
  - API URL và token có đúng không
  - userId có đúng không (thường là userData["id"])
  - Có thông tin tổng đài trong response không

### Không thể gọi
- Kiểm tra `isReady` phải là `true`
- Kiểm tra quyền microphone
- Kiểm tra số điện thoại đúng format

### Tracking không gửi được
- Kiểm tra đã cấu hình `configureTracking()` chưa
- Kiểm tra API URL và token
- Lỗi tracking không ảnh hưởng đến cuộc gọi

