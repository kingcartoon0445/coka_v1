import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
// Scanner page chỉ trả về mã quét, xử lý hiển thị ở màn trước đó

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({
    super.key,
    this.title,
    this.onQrScanned,
  });

  /// Tiêu đề của trang quét QR
  final String? title;

  /// Callback được gọi khi quét thành công mã QR (từ camera hoặc ảnh)
  /// Nếu callback trả về true, sẽ không tự động đóng trang (Navigator.pop)
  /// Nếu callback trả về false hoặc null, sẽ tự động đóng trang và trả về kết quả
  final Future<bool?> Function(String qrValue)? onQrScanned;

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    formats: const [BarcodeFormat.qrCode],
  );

  bool _handled = false;
  bool _isScanningImage = false;
  bool _isTorchOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) return;
    final Barcode? code =
        capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
    final String? value = code?.rawValue;
    if (value != null && value.isNotEmpty) {
      _handled = true;
      if (_isScanningImage) {
        setState(() {
          _isScanningImage = false;
        });
      }

      // Nếu có callback, gọi callback trước
      if (widget.onQrScanned != null) {
        try {
          final shouldKeepOpen = await widget.onQrScanned!(value);
          // Nếu callback trả về true, giữ trang mở (không pop)
          if (shouldKeepOpen == true) {
            // Reset handled để có thể quét tiếp
            _handled = false;
            return;
          }
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi xử lý QR: $e')),
          );
          // Nếu callback lỗi, vẫn đóng trang và trả về kết quả
        }
      }

      // Đóng trang và trả về kết quả
      if (mounted) {
        Navigator.of(context).pop<String>(value);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      // Kiểm tra file có tồn tại không
      final File imageFile = File(image.path);
      if (!await imageFile.exists()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy ảnh đã chọn')),
        );
        return;
      }

      // Đặt cờ để cho phép detection và hiển thị loading
      setState(() {
        _handled = false;
        _isScanningImage = true;
      });

      // Quét ảnh từ thư viện
      BarcodeCapture? barcodeCapture =
          await _controller.analyzeImage(image.path);
      if (barcodeCapture?.barcodes.isNotEmpty ?? false) {
        _onDetect(barcodeCapture!);
      }

      // Đợi một chút để quét hoàn tất, nếu không có kết quả thì hiển thị thông báo
      // Tăng thời gian chờ để đảm bảo quét hoàn tất
      await Future.delayed(const Duration(milliseconds: 2000));

      if (!mounted) return;

      // Nếu sau khi quét mà vẫn chưa có kết quả (chưa được handle)
      if (!_handled && _isScanningImage) {
        setState(() {
          _isScanningImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy mã QR trong ảnh'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isScanningImage = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể đọc mã từ ảnh: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.title ?? 'Quét QR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cameraswitch_rounded),
            onPressed: () async {
              await _controller.switchCamera();
              setState(() {});
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (BarcodeCapture capture) {
              // Gọi async function
              _onDetect(capture);
            },
          ),
          const _ScannerOverlay(),
          // Hiển thị loading khi đang quét ảnh từ thư viện
          if (_isScanningImage)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Đang quét mã QR từ ảnh...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          // Nút chọn ảnh từ thư viện - góc trái dưới
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.photo_library_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: _pickFromGallery,
                  tooltip: 'Chọn ảnh từ thư viện',
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),
          // Nút bật/tắt flash - góc phải dưới
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _isTorchOn
                        ? Icons.flash_off_rounded
                        : Icons.flash_on_rounded,
                    color: _isTorchOn ? Colors.amber : Colors.white,
                    size: 28,
                  ),
                  onPressed: () async {
                    await _controller.toggleTorch();
                    setState(() {
                      _isTorchOn = !_isTorchOn;
                    });
                  },
                  tooltip: _isTorchOn ? 'Tắt đèn flash' : 'Bật đèn flash',
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),
          // Thông báo hướng dẫn - giữa dưới
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _isScanningImage
                      ? 'Đang quét ảnh từ thư viện...'
                      : 'Đưa mã QR vào khung để quét',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        final double boxSize = width < height ? width * 0.65 : height * 0.65;
        final double cutoutSize = boxSize.clamp(220.0, 320.0);

        return CustomPaint(
          painter: _ScannerOverlayPainter(cutoutSize: cutoutSize),
          size: Size(width, height),
        );
      },
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  _ScannerOverlayPainter({required this.cutoutSize});

  final double cutoutSize;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint overlayPaint = Paint()..color = Colors.black.withOpacity(0.55);

    final double left = (size.width - cutoutSize) / 2;
    final double top =
        (size.height - cutoutSize) / 2.5; // slightly upper center
    final Rect cutoutRect = Rect.fromLTWH(left, top, cutoutSize, cutoutSize);
    final RRect cutoutRRect =
        RRect.fromRectAndRadius(cutoutRect, const Radius.circular(16));

    // Darken background with transparent cutout
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(Offset.zero & size, overlayPaint);
    final Paint clearPaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawRRect(cutoutRRect, clearPaint);
    canvas.restore();

    // Corner guides
    final Paint cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square;

    const double cornerLen = 28;
    const double r = 16;

    // Top-left
    canvas.drawLine(Offset(cutoutRect.left, cutoutRect.top + r),
        Offset(cutoutRect.left, cutoutRect.top + r + cornerLen), cornerPaint);
    canvas.drawLine(Offset(cutoutRect.left + r, cutoutRect.top),
        Offset(cutoutRect.left + r + cornerLen, cutoutRect.top), cornerPaint);

    // Top-right
    canvas.drawLine(Offset(cutoutRect.right, cutoutRect.top + r),
        Offset(cutoutRect.right, cutoutRect.top + r + cornerLen), cornerPaint);
    canvas.drawLine(Offset(cutoutRect.right - r, cutoutRect.top),
        Offset(cutoutRect.right - r - cornerLen, cutoutRect.top), cornerPaint);

    // Bottom-left
    canvas.drawLine(
        Offset(cutoutRect.left, cutoutRect.bottom - r),
        Offset(cutoutRect.left, cutoutRect.bottom - r - cornerLen),
        cornerPaint);
    canvas.drawLine(
        Offset(cutoutRect.left + r, cutoutRect.bottom),
        Offset(cutoutRect.left + r + cornerLen, cutoutRect.bottom),
        cornerPaint);

    // Bottom-right
    canvas.drawLine(
        Offset(cutoutRect.right, cutoutRect.bottom - r),
        Offset(cutoutRect.right, cutoutRect.bottom - r - cornerLen),
        cornerPaint);
    canvas.drawLine(
        Offset(cutoutRect.right - r, cutoutRect.bottom),
        Offset(cutoutRect.right - r - cornerLen, cutoutRect.bottom),
        cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.cutoutSize != cutoutSize;
  }
}

// Không còn dùng InfoRow ở trang quét
