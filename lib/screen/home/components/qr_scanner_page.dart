import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
// Scanner page chỉ trả về mã quét, xử lý hiển thị ở màn trước đó

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key, this.title});

  final String? title;

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final Barcode? code =
        capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
    final String? value = code?.rawValue;
    if (value != null && value.isNotEmpty) {
      _handled = true;
      Navigator.of(context).pop<String>(value);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      // Allow detection for this flow
      _handled = false;
      await _controller.analyzeImage(image.path);
    } catch (e) {
      if (!mounted) return;
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
            icon: const Icon(Icons.photo_library_rounded),
            onPressed: _pickFromGallery,
            tooltip: 'Chọn ảnh từ thư viện',
          ),
          IconButton(
            icon: const Icon(Icons.flash_on_rounded),
            onPressed: () async {
              await _controller.toggleTorch();
              setState(() {});
            },
          ),
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
            onDetect: _onDetect,
          ),
          const _ScannerOverlay(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Đưa mã QR vào khung để quét',
                  style: TextStyle(color: Colors.white),
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

