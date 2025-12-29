import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:permission_handler/permission_handler.dart';
import 'package:sip_ua/sip_ua.dart';
import 'package:dio/dio.dart';
import 'package:pointycastle/export.dart' hide State;

/// Service độc lập để xử lý cuộc gọi tổng đài
/// Không phụ thuộc vào bất kỳ file nào trong source hiện tại
class StandaloneCallService implements SipUaHelperListener {
  // Singleton pattern
  static final StandaloneCallService _instance =
      StandaloneCallService._internal();
  factory StandaloneCallService() => _instance;
  StandaloneCallService._internal();

  // SIP Helper
  late SIPUAHelper _helper;

  // Trạng thái
  bool _isInitialized = false;
  bool _isRegistered = false;
  Call? _currentCall;
  Timer? _callTimer;
  String _callDuration = '00:00';

  // Callbacks
  Function(String message)? onStatusChanged;
  Function(String duration)? onCallDurationChanged;
  Function(Call call)? onCallInitiated;
  Function()? onCallEnded;
  Function(String error)? onError;

  // Cấu hình SIP (có thể thay đổi)
  String _webSocketUrl = "wss://vcwebrtc.voicecloud.vn:9443";
  String _domain = "azvidi.voicecloud-platform.com";
  String _userAgent = 'Dart SIP Client v1.0.0';

  // Cấu hình API Tracking (tùy chọn)
  String? _trackingApiUrl;
  String? _trackingApiToken;
  String? _workspaceId;
  String? _organizationId;

  // Cấu hình API để lấy thông tin SIP (tùy chọn)
  String? _callCenterApiUrl;
  String? _apiToken;
  String? _organizationIdForApi;

  /// Khởi tạo service
  Future<bool> initialize({
    required String username,
    required String password,
    String? webSocketUrl,
    String? domain,
    String? userAgent,
  }) async {
    try {
      if (_isInitialized) {
        return true;
      }

      // Cập nhật cấu hình nếu có
      if (webSocketUrl != null) _webSocketUrl = webSocketUrl;
      if (domain != null) _domain = domain;
      if (userAgent != null) _userAgent = userAgent;

      // Khởi tạo SIP Helper
      _helper = SIPUAHelper();
      _helper.addSipUaHelperListener(this);

      // Cấu hình SIP Settings
      UaSettings settings = UaSettings();
      settings.webSocketUrl = _webSocketUrl;
      settings.webSocketSettings.extraHeaders = {};
      settings.webSocketSettings.allowBadCertificate = true;
      settings.uri = "$username@$_domain";
      settings.authorizationUser = username;
      settings.password = password;
      settings.displayName = username;
      settings.userAgent = _userAgent;
      settings.dtmfMode = DtmfMode.RFC2833;
      settings.transportType = TransportType.WS;

      // Bắt đầu đăng ký SIP
      _helper.start(settings);
      _isInitialized = true;

      _notifyStatus("Đang khởi tạo kết nối SIP...");
      return true;
    } catch (e) {
      _notifyError("Lỗi khởi tạo: $e");
      return false;
    }
  }

  /// Cấu hình API Tracking (tùy chọn)
  void configureTracking({
    required String apiUrl,
    required String apiToken,
    String? workspaceId,
    String? organizationId,
  }) {
    _trackingApiUrl = apiUrl;
    _trackingApiToken = apiToken;
    _workspaceId = workspaceId;
    _organizationId = organizationId;
  }

  /// Cấu hình API để lấy thông tin SIP (tùy chọn)
  /// Sử dụng để tự động lấy username và password từ server
  void configureCallCenterApi({
    required String apiUrl,
    required String apiToken,
    String? organizationId,
  }) {
    _callCenterApiUrl = apiUrl;
    _apiToken = apiToken;
    _organizationIdForApi = organizationId;
  }

  /// Lấy thông tin SIP từ API và tự động khởi tạo
  ///
  /// Cần cấu hình trước bằng configureCallCenterApi()
  ///
  /// [userId] - ID của user để giải mã password (thường là userData["id"])
  ///
  /// Trả về Map chứa:
  /// - "success": bool
  /// - "username": String? - Tên extension
  /// - "message": String - Thông báo
  Future<Map<String, dynamic>> initializeFromApi({
    required String userId,
  }) async {
    try {
      if (_callCenterApiUrl == null || _apiToken == null) {
        return {
          "success": false,
          "message": "Chưa cấu hình API. Gọi configureCallCenterApi() trước.",
        };
      }

      _notifyStatus("Đang lấy thông tin tổng đài...");

      // Lấy thông tin từ API
      final callData = await _fetchCallSetting();

      if (callData == null || callData.isEmpty) {
        return {
          "success": false,
          "message": "Không có thông tin tổng đài. Bạn chưa mua gói tổng đài.",
        };
      }

      // Kiểm tra có passwordHash không
      if (!callData.containsKey("passwordHash") ||
          !callData.containsKey("name")) {
        return {
          "success": false,
          "message": "Thông tin tổng đài không đầy đủ.",
        };
      }

      final username = callData["name"] as String;
      final passwordHash = callData["passwordHash"] as String;

      // Giải mã password
      String decryptedPassword;
      try {
        decryptedPassword = _decryptPassword(passwordHash, userId);
      } catch (e) {
        return {
          "success": false,
          "message": "Lỗi giải mã mật khẩu: $e",
        };
      }

      // Khởi tạo với thông tin đã lấy
      final success = await initialize(
        username: username,
        password: decryptedPassword,
      );

      if (success) {
        return {
          "success": true,
          "username": username,
          "message": "Đã khởi tạo thành công",
        };
      } else {
        return {
          "success": false,
          "message": "Không thể khởi tạo SIP",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Lỗi: $e",
      };
    }
  }

  /// Lấy thông tin SIP từ API (không tự động khởi tạo)
  ///
  /// Trả về Map chứa:
  /// - "name": String - Tên extension
  /// - "passwordHash": String - Password đã mã hóa
  /// - Hoặc null nếu lỗi
  Future<Map<String, dynamic>?> fetchCallSetting() async {
    return await _fetchCallSetting();
  }

  /// Giải mã password từ passwordHash
  ///
  /// [encryptedBase64] - Password đã mã hóa (base64)
  /// [key] - Key để giải mã (thường là userId)
  ///
  /// Trả về password đã giải mã
  String decryptPassword(String encryptedBase64, String key) {
    return _decryptPassword(encryptedBase64, key);
  }

  // ========== Private Helper Methods ==========

  /// Lấy thông tin call setting từ API
  Future<Map<String, dynamic>?> _fetchCallSetting() async {
    if (_callCenterApiUrl == null || _apiToken == null) {
      return null;
    }

    try {
      final dio = Dio(BaseOptions(baseUrl: _callCenterApiUrl!));

      Map<String, String> headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_apiToken",
      };

      if (_organizationIdForApi != null) {
        headers["organizationId"] = _organizationIdForApi!;
      }

      final response = await dio.get(
        "/api/v1/user/line",
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data["content"] != null && (data["content"] as List).isNotEmpty) {
          return (data["content"] as List)[0] as Map<String, dynamic>;
        }
      }

      return null;
    } catch (e) {
      print("Lỗi lấy call setting: $e");
      return null;
    }
  }

  /// Giải mã password sử dụng AES
  String _decryptPassword(String encryptedBase64, String key) {
    try {
      // Decode base64
      final encryptedBytes = base64.decode(encryptedBase64);

      // Convert key
      final keyBytes = _convertCryptKey(key);

      // Setup cipher
      final cipher = ECBBlockCipher(AESEngine());
      final params = KeyParameter(keyBytes);
      cipher.init(false, params);

      // Decrypt
      final paddedBytes = _processBlocks(cipher, encryptedBytes);

      // Remove PKCS7 padding
      final padLength = paddedBytes.last;
      final messageBytes =
          paddedBytes.sublist(0, paddedBytes.length - padLength);

      return utf8.decode(messageBytes);
    } catch (e) {
      throw Exception('Lỗi giải mã mật khẩu: $e');
    }
  }

  /// Chuyển đổi key string thành Uint8List
  Uint8List _convertCryptKey(String strKey) {
    final newKey = Uint8List(16);
    final strKeyBytes = utf8.encode(strKey);

    for (var i = 0; i < strKeyBytes.length; i++) {
      newKey[i % 16] ^= strKeyBytes[i];
    }
    return newKey;
  }

  /// Xử lý các block khi decrypt
  Uint8List _processBlocks(BlockCipher cipher, Uint8List input) {
    final output = Uint8List(input.length);
    for (var offset = 0; offset < input.length; offset += 16) {
      cipher.processBlock(input, offset, output, offset);
    }
    return output;
  }

  /// Kiểm tra xem service đã sẵn sàng để gọi chưa
  bool get isReady => _isInitialized && _isRegistered;

  /// Thực hiện cuộc gọi
  Future<bool> makeCall({
    required String phoneNumber,
    Map<String, dynamic>? trackingData,
  }) async {
    try {
      // Kiểm tra trạng thái
      if (!_isInitialized) {
        _notifyError("Service chưa được khởi tạo. Gọi initialize() trước.");
        return false;
      }

      if (!_isRegistered) {
        _notifyError("SIP chưa đăng ký thành công. Vui lòng đợi...");
        return false;
      }

      // Kiểm tra quyền microphone
      Map<Permission, PermissionStatus> statuses = await [
        Permission.microphone,
      ].request();

      if (statuses[Permission.microphone] != PermissionStatus.granted) {
        _notifyError("Cần quyền truy cập microphone để thực hiện cuộc gọi");
        await openAppSettings();
        return false;
      }

      // Lấy media stream
      final mediaConstraints = <String, dynamic>{
        'audio': true,
        'video': false,
      };

      rtc.MediaStream mediaStream;
      try {
        mediaStream =
            await rtc.navigator.mediaDevices.getUserMedia(mediaConstraints);
      } catch (e) {
        _notifyError("Không thể truy cập microphone: $e");
        return false;
      }

      // Thực hiện cuộc gọi
      String formattedPhone =
          phoneNumber.startsWith('+') ? phoneNumber : '+$phoneNumber';

      _helper.call(
        formattedPhone,
        mediaStream: mediaStream,
      );

      _notifyStatus("Đang gọi $phoneNumber...");

      // Gửi tracking nếu có cấu hình
      if (trackingData != null && _trackingApiUrl != null) {
        _sendTracking(trackingData);
      }

      return true;
    } catch (e) {
      _notifyError("Lỗi khi thực hiện cuộc gọi: $e");
      return false;
    }
  }

  /// Kết thúc cuộc gọi hiện tại
  void hangUp() {
    if (_currentCall != null) {
      _currentCall!.hangup();
      _currentCall = null;
      _stopCallTimer();
      _notifyStatus("Đã kết thúc cuộc gọi");
    }
  }

  /// Dọn dẹp và đóng kết nối
  void dispose() {
    hangUp();
    _helper.removeSipUaHelperListener(this);
    _stopCallTimer();
    _isInitialized = false;
    _isRegistered = false;
  }

  // ========== SIP Event Handlers ==========

  @override
  void registrationStateChanged(RegistrationState state) {
    if (state.state == RegistrationStateEnum.REGISTERED) {
      _isRegistered = true;
      _notifyStatus("Đã kết nối tổng đài thành công");
    } else if (state.state == RegistrationStateEnum.REGISTRATION_FAILED) {
      _isRegistered = false;
      String errorMsg =
          "Đăng ký SIP thất bại: ${state.cause ?? 'Không xác định'}";
      _notifyError(errorMsg);
    } else {
      _isRegistered = false;
      _notifyStatus("Đang đăng ký SIP...");
    }
  }

  @override
  void callStateChanged(Call call, CallState state) {
    _currentCall = call;

    switch (state.state) {
      case CallStateEnum.CALL_INITIATION:
        _notifyStatus("Đang khởi tạo cuộc gọi...");
        if (onCallInitiated != null) {
          onCallInitiated!(call);
        }
        break;

      case CallStateEnum.PROGRESS:
        _notifyStatus("Đang đổ chuông...");
        break;

      case CallStateEnum.CONFIRMED:
        _notifyStatus("Cuộc gọi đã được kết nối");
        _startCallTimer();
        break;

      case CallStateEnum.ENDED:
      case CallStateEnum.FAILED:
        _notifyStatus("Cuộc gọi đã kết thúc");
        _stopCallTimer();
        _currentCall = null;
        if (onCallEnded != null) {
          onCallEnded!();
        }
        break;

      default:
        break;
    }
  }

  @override
  void transportStateChanged(TransportState state) {
    // Xử lý thay đổi trạng thái transport nếu cần
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {
    // Xử lý tin nhắn SIP nếu cần
  }

  @override
  void onNewNotify(Notify ntf) {
    // Xử lý thông báo SIP nếu cần
  }

  @override
  void onNewReinvite(ReInvite event) {
    // Xử lý reinvite nếu cần
  }

  // ========== Helper Methods ==========

  void _startCallTimer() {
    _stopCallTimer();
    int seconds = 0;
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds++;
      Duration duration = Duration(seconds: seconds);
      _callDuration = [duration.inMinutes, duration.inSeconds.remainder(60)]
          .map((seg) => seg.toString().padLeft(2, '0'))
          .join(':');

      if (onCallDurationChanged != null) {
        onCallDurationChanged!(_callDuration);
      }
    });
  }

  void _stopCallTimer() {
    _callTimer?.cancel();
    _callTimer = null;
    _callDuration = '00:00';
  }

  void _notifyStatus(String message) {
    if (onStatusChanged != null) {
      onStatusChanged!(message);
    }
  }

  void _notifyError(String error) {
    if (onError != null) {
      onError!(error);
    }
  }

  /// Gửi tracking lên server (tùy chọn)
  Future<void> _sendTracking(Map<String, dynamic> data) async {
    if (_trackingApiUrl == null || _trackingApiToken == null) {
      return;
    }

    try {
      final dio = Dio(BaseOptions(baseUrl: _trackingApiUrl!));

      Map<String, String> headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_trackingApiToken",
      };

      if (_workspaceId != null) {
        headers["workspaceId"] = _workspaceId!;
      }

      if (_organizationId != null) {
        headers["organizationId"] = _organizationId!;
      }

      await dio.post(
        "/api/v1/calltracking/int",
        data: data,
        options: Options(headers: headers),
      );
    } catch (e) {
      // Tracking thất bại không ảnh hưởng đến cuộc gọi
      print("Lỗi gửi tracking: $e");
    }
  }

  /// Lấy thời lượng cuộc gọi hiện tại
  String get callDuration => _callDuration;

  /// Lấy trạng thái đăng ký
  bool get isRegistered => _isRegistered;

  /// Lấy cuộc gọi hiện tại
  Call? get currentCall => _currentCall;
}

/// Widget helper để sử dụng service trong Flutter
class StandaloneCallWidget extends StatefulWidget {
  final Widget child;
  final Function(String message)? onStatusChanged;
  final Function(String duration)? onCallDurationChanged;
  final Function(String error)? onError;

  const StandaloneCallWidget({
    Key? key,
    required this.child,
    this.onStatusChanged,
    this.onCallDurationChanged,
    this.onError,
  }) : super(key: key);

  @override
  State<StandaloneCallWidget> createState() => _StandaloneCallWidgetState();
}

class _StandaloneCallWidgetState extends State<StandaloneCallWidget> {
  final _service = StandaloneCallService();

  @override
  void initState() {
    super.initState();
    _service.onStatusChanged = widget.onStatusChanged;
    _service.onCallDurationChanged = widget.onCallDurationChanged;
    _service.onError = widget.onError;
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
