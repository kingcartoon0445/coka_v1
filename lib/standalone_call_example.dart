/// File ví dụ minh họa cách sử dụng StandaloneCallService
/// 
/// Đây là file demo, có thể xóa hoặc tham khảo để tích hợp vào ứng dụng

import 'package:flutter/material.dart';
import 'standalone_call_service.dart';

/// Ví dụ 1: Sử dụng cơ bản
class BasicCallExample extends StatefulWidget {
  const BasicCallExample({Key? key}) : super(key: key);

  @override
  State<BasicCallExample> createState() => _BasicCallExampleState();
}

class _BasicCallExampleState extends State<BasicCallExample> {
  final _service = StandaloneCallService();
  String _status = 'Chưa khởi tạo';
  String _callDuration = '00:00';

  @override
  void initState() {
    super.initState();
    _setupService();
  }

  void _setupService() {
    // Thiết lập callbacks
    _service.onStatusChanged = (message) {
      setState(() {
        _status = message;
      });
    };

    _service.onCallDurationChanged = (duration) {
      setState(() {
        _callDuration = duration;
      });
    };

    _service.onError = (error) {
      setState(() {
        _status = 'Lỗi: $error';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    };

    _service.onCallEnded = () {
      setState(() {
        _status = 'Cuộc gọi đã kết thúc';
      });
    };
  }

  Future<void> _initializeService() async {
    // Cấu hình SIP
    // Lưu ý: Thay thế bằng thông tin thực tế của bạn
    final success = await _service.initialize(
      username: 'your_username', // Thay bằng username thực tế
      password: 'your_password', // Thay bằng password thực tế
      // Có thể tùy chỉnh:
      // webSocketUrl: "wss://your-server.com:9443",
      // domain: "your-domain.com",
    );

    if (success) {
      setState(() {
        _status = 'Đang đăng ký SIP...';
      });
    }
  }

  Future<void> _makeCall() async {
    if (!_service.isReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SIP chưa sẵn sàng. Vui lòng đợi...')),
      );
      return;
    }

    // Thực hiện cuộc gọi
    await _service.makeCall(
      phoneNumber: '84901234567', // Số điện thoại cần gọi
      trackingData: {
        // Dữ liệu tracking (tùy chọn)
        'contactId': 'contact_123',
        'phone': '84901234567',
        'extention': 'extension_name',
      },
    );
  }

  void _hangUp() {
    _service.hangUp();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ví dụ Gọi Tổng Đài')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trạng thái: $_status', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Thời lượng: $_callDuration'),
                    const SizedBox(height: 8),
                    Text('Sẵn sàng: ${_service.isReady ? "Có" : "Không"}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _initializeService,
              child: const Text('Khởi tạo Service'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _service.isReady ? _makeCall : null,
              child: const Text('Gọi số điện thoại'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _service.currentCall != null ? _hangUp : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Kết thúc cuộc gọi'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ví dụ 2: Sử dụng với Tracking API
class CallWithTrackingExample extends StatefulWidget {
  const CallWithTrackingExample({Key? key}) : super(key: key);

  @override
  State<CallWithTrackingExample> createState() => _CallWithTrackingExampleState();
}

class _CallWithTrackingExampleState extends State<CallWithTrackingExample> {
  final _service = StandaloneCallService();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupService();
  }

  void _setupService() {
    // Khởi tạo service
    _service.initialize(
      username: 'your_username',
      password: 'your_password',
    );

    // Cấu hình Tracking API (tùy chọn)
    _service.configureTracking(
      apiUrl: 'https://your-api-url.com', // URL API tracking
      apiToken: 'your_api_token', // Token xác thực
      workspaceId: 'workspace_id', // ID workspace (tùy chọn)
      organizationId: 'org_id', // ID organization (tùy chọn)
    );

    _service.onStatusChanged = (message) {
      print('Status: $message');
    };

    _service.onError = (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    };
  }

  Future<void> _makeCallWithTracking() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số điện thoại')),
      );
      return;
    }

    await _service.makeCall(
      phoneNumber: _phoneController.text,
      trackingData: {
        'contactId': 'contact_123',
        'phone': _phoneController.text,
        'extention': 'extension_name',
      },
    );
  }

  @override
  void dispose() {
    _service.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gọi với Tracking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                hintText: '84901234567',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _service.isReady ? _makeCallWithTracking : null,
              child: const Text('Gọi với Tracking'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ví dụ 3: Sử dụng với StandaloneCallWidget
class CallWidgetExample extends StatelessWidget {
  const CallWidgetExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StandaloneCallWidget(
      onStatusChanged: (message) {
        print('Status: $message');
      },
      onCallDurationChanged: (duration) {
        print('Duration: $duration');
      },
      onError: (error) {
        print('Error: $error');
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Sử dụng Widget')),
        body: const Center(
          child: Text('Service đã được khởi tạo tự động'),
        ),
      ),
    );
  }
}

