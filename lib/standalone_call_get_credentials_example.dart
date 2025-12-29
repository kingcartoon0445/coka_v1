/// Ví dụ cách lấy name và password để đăng ký SIP
/// 
/// Có 2 cách:
/// 1. Tự động lấy từ API và khởi tạo (đơn giản nhất)
/// 2. Lấy từ API rồi tự xử lý (linh hoạt hơn)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'standalone_call_service.dart';

/// ============================================
/// CÁCH 1: Tự động lấy từ API và khởi tạo
/// ============================================
class AutoInitializeExample extends StatefulWidget {
  const AutoInitializeExample({Key? key}) : super(key: key);

  @override
  State<AutoInitializeExample> createState() => _AutoInitializeExampleState();
}

class _AutoInitializeExampleState extends State<AutoInitializeExample> {
  final _callService = StandaloneCallService();
  String _status = 'Chưa khởi tạo';

  @override
  void initState() {
    super.initState();
    _setupService();
  }

  Future<void> _setupService() async {
    // Thiết lập callbacks
    _callService.onStatusChanged = (message) {
      setState(() => _status = message);
    };

    _callService.onError = (error) {
      setState(() => _status = 'Lỗi: $error');
    };

    // Bước 1: Cấu hình API để lấy thông tin SIP
    final token = await _getAccessToken();
    if (token == null) {
      setState(() => _status = 'Lỗi: Không có access token');
      return;
    }
    
    _callService.configureCallCenterApi(
      apiUrl: 'https://callcenter.coka.ai', // URL API call center
      apiToken: token, // Token xác thực
      organizationId: await _getOrganizationId(), // ID organization (tùy chọn)
    );

    // Bước 2: Lấy userId (thường là userData["id"])
    final userId = await _getUserId();

    // Bước 3: Tự động lấy thông tin và khởi tạo
    final result = await _callService.initializeFromApi(userId: userId);

    if (result["success"]) {
      print('✅ Đã khởi tạo thành công với username: ${result["username"]}');
    } else {
      print('❌ Lỗi: ${result["message"]}');
    }
  }

  // Helper: Lấy access token từ SharedPreferences
  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  // Helper: Lấy organization ID từ SharedPreferences
  Future<String?> _getOrganizationId() async {
    final prefs = await SharedPreferences.getInstance();
    final oDataString = prefs.getString('oData');
    if (oDataString != null) {
      final oData = jsonDecode(oDataString);
      return oData["id"];
    }
    return null;
  }

  // Helper: Lấy user ID (thường lấy từ userData)
  Future<String> _getUserId() async {
    // Ví dụ: Lấy từ SharedPreferences hoặc API
    // Trong thực tế, bạn có thể lấy từ userData["id"]
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? 'default_user_id';
  }

  @override
  void dispose() {
    _callService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tự động lấy thông tin SIP')),
      body: Center(
        child: Text(_status),
      ),
    );
  }
}

/// ============================================
/// CÁCH 2: Lấy từ API rồi tự xử lý
/// ============================================
class ManualInitializeExample extends StatefulWidget {
  const ManualInitializeExample({Key? key}) : super(key: key);

  @override
  State<ManualInitializeExample> createState() => _ManualInitializeExampleState();
}

class _ManualInitializeExampleState extends State<ManualInitializeExample> {
  final _callService = StandaloneCallService();
  String? _username;
  String? _password;

  Future<void> _fetchAndDecrypt() async {
    // Bước 1: Cấu hình API
    final token = await _getAccessToken();
    if (token == null) {
      print('❌ Không có access token');
      return;
    }
    
    _callService.configureCallCenterApi(
      apiUrl: 'https://callcenter.coka.ai',
      apiToken: token,
      organizationId: await _getOrganizationId(),
    );

    // Bước 2: Lấy thông tin từ API
    final callData = await _callService.fetchCallSetting();

    if (callData == null || callData.isEmpty) {
      print('❌ Không có thông tin tổng đài');
      return;
    }

    // Bước 3: Lấy username và passwordHash
    final username = callData["name"] as String?;
    final passwordHash = callData["passwordHash"] as String?;

    if (username == null || passwordHash == null) {
      print('❌ Thông tin không đầy đủ');
      return;
    }

    // Bước 4: Lấy userId để giải mã
    final userId = await _getUserId();

    // Bước 5: Giải mã password
    final decryptedPassword = _callService.decryptPassword(passwordHash, userId);

    setState(() {
      _username = username;
      _password = decryptedPassword;
    });

    print('✅ Username: $username');
    print('✅ Password đã giải mã: $decryptedPassword');

    // Bước 6: Khởi tạo với thông tin đã lấy
    await _callService.initialize(
      username: username,
      password: decryptedPassword,
    );
  }

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<String?> _getOrganizationId() async {
    final prefs = await SharedPreferences.getInstance();
    final oDataString = prefs.getString('oData');
    if (oDataString != null) {
      final oData = jsonDecode(oDataString);
      return oData["id"];
    }
    return null;
  }

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? 'default_user_id';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lấy thông tin thủ công')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _fetchAndDecrypt,
              child: const Text('Lấy thông tin SIP'),
            ),
            const SizedBox(height: 20),
            if (_username != null)
              Text('Username: $_username'),
            if (_password != null)
              Text('Password: $_password'),
          ],
        ),
      ),
    );
  }
}

/// ============================================
/// CÁCH 3: Tích hợp với code hiện tại
/// ============================================
/// 
/// Nếu bạn đã có HomeController và userData:
/// 
/// ```dart
/// final callService = StandaloneCallService();
/// final homeController = Get.put(HomeController());
/// 
/// // Cấu hình API
/// callService.configureCallCenterApi(
///   apiUrl: 'https://callcenter.coka.ai',
///   apiToken: await getAccessToken(),
///   organizationId: jsonDecode(await getOData())["id"],
/// );
/// 
/// // Tự động lấy và khởi tạo
/// final result = await callService.initializeFromApi(
///   userId: homeController.userData["id"],
/// );
/// 
/// if (result["success"]) {
///   // Đã sẵn sàng để gọi
///   await callService.makeCall(phoneNumber: '84901234567');
/// }
/// ```

/// ============================================
/// CÁCH 4: Sử dụng với SharedPreferences trực tiếp
/// ============================================
/// 
/// ```dart
/// Future<void> initializeFromSharedPrefs() async {
///   final callService = StandaloneCallService();
///   final prefs = await SharedPreferences.getInstance();
///   
///   // Lấy token và organization ID
///   final token = prefs.getString('accessToken');
///   final oDataString = prefs.getString('oData');
///   final oData = jsonDecode(oDataString ?? '{}');
///   final orgId = oData["id"];
///   
///   // Cấu hình API
///   callService.configureCallCenterApi(
///     apiUrl: 'https://callcenter.coka.ai',
///     apiToken: token ?? '',
///     organizationId: orgId,
///   );
///   
///   // Lấy userId (có thể lưu riêng hoặc lấy từ API)
///   final userId = prefs.getString('userId') ?? 'default';
///   
///   // Tự động khởi tạo
///   await callService.initializeFromApi(userId: userId);
/// }
/// ```

