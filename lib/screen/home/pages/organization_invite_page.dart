import 'package:coka/api/organization.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/appbar_widget.dart';
import 'package:coka/screen/home/organization_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:source_base/config/app_color.dart';
// import 'package:source_base/config/app_size.dart';
// import 'package:source_base/data/models/organization_model.dart';
// import 'package:source_base/presentation/blocs/organization/organization_bloc.dart';
// import 'package:source_base/presentation/screens/shared/widgets/avatar_widget.dart';
// import 'package:source_base/dio/service_locator.dart';
// import 'package:source_base/data/datasources/remote/api_service.dart';
import 'package:photo_view/photo_view.dart';

class OrganizationInvitePage extends StatefulWidget {
  const OrganizationInvitePage({
    super.key,
    required this.organizationId,
    required this.organizationName,
    this.inviteSlug,
  });

  final String organizationId;
  final String organizationName;
  final String? inviteSlug;

  @override
  State<OrganizationInvitePage> createState() => _OrganizationInvitePageState();
}

class _OrganizationInvitePageState extends State<OrganizationInvitePage> {
  final GlobalKey _qrKey = GlobalKey();
  Uint8List? _qrBytes;
  bool _loadingQr = false;
  bool _isSaved = false;
  Uint8List? _savedBytes;

  String get inviteLink =>
      'COKA.AI/join/org/${widget.inviteSlug ?? widget.organizationId}';
  OrganizationModel? org;
  Future<void> _shareLink() async {
    await Share.share(inviteLink,
        subject: 'Tham gia tổ chức ${widget.organizationName}');
  }

  Future<void> _saveQrToGallery() async {
    final status = await _ensureGalleryPermission();
    if (!status) {
      return;
    }

    try {
      Uint8List? bytesToSave = _qrBytes;
      if (bytesToSave == null) {
        final boundary =
            _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) return;
        final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        final ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) return;
        bytesToSave = byteData.buffer.asUint8List();
      }
      final result = await ImageGallerySaverPlus.saveImage(
        bytesToSave,
        name: 'coka_qr_${DateTime.now().millisecondsSinceEpoch}',
        quality: 100,
      );
      if (!mounted) return;
      final isSuccess = (result is Map &&
          (result['isSuccess'] == true || result['isSuccess'] == 1));

      if (isSuccess) {
        setState(() {
          _isSaved = true;
          _savedBytes = bytesToSave;
        });
      }
    } catch (e) {
      // Ignore error
    }
  }

  void _viewSavedImage() {
    if (_savedBytes != null) {
      _showImageInGallery(context, _savedBytes!);
    }
  }

  Future<bool> _ensureGalleryPermission() async {
    // Prefer Photos permission (iOS and Android 13+) then fall back to Storage on old Android.
    var photosStatus = await Permission.photos.status;
    if (!photosStatus.isGranted) {
      photosStatus = await Permission.photos.request();
    }
    if (photosStatus.isGranted) return true;

    var storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      storageStatus = await Permission.storage.request();
    }
    return storageStatus.isGranted;
  }

  void _showImageInGallery(BuildContext context, Uint8List imageBytes) {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: PhotoView(
            imageProvider: MemoryImage(imageBytes),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    getOData().then((value) {
      org = OrganizationModel(
        id: value["id"],
        name: value["name"],
        avatar: value["avatar"],
      );
    });
    _loadQr();
    super.initState();
  }

  Future<void> _loadQr() async {
    setState(() => _loadingQr = true);
    try {
      final res = await OrganApi().getOrganQR();
      if (res.statusCode == 200 && res.data is List<int>) {
        setState(() => _qrBytes = Uint8List.fromList(res.data as List<int>));
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _loadingQr = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Logo placeholder
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE9E6F2)),
              ),
              child: AppAvatar(
                size: 40,
                shape: AvatarShape.rectangle,
                borderRadius: 8,
                fallbackText: org!.name,
                imageUrl: org!.avatar,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.organizationName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.verified, color: Color(0xFF4C46F1), size: 18),
              ],
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Mời mọi người tham gia tổ chức bằng mã QR\nhoặc liên kết dưới đây:',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF6B6A76)),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE9E6F2)),
              ),
              alignment: Alignment.center,
              child: _loadingQr
                  ? const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : (_qrBytes != null
                      ? Image.memory(
                          _qrBytes!,
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        )
                      : AppAvatar(
                          size: 150,
                          shape: AvatarShape.rectangle,
                          borderRadius: 8,
                          fallbackText: org!.name,
                          imageUrl: org!.avatar,
                        )),
            ),

            // const SizedBox(height: 12),
            // Container(
            //   padding:
            //       const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            //   decoration: BoxDecoration(
            //     color: const Color(0xFFEDE8FF),
            //     borderRadius: BorderRadius.circular(20),
            //   ),
            //   child: Text(
            //     inviteLink,
            //     textAlign: TextAlign.center,
            //     style: const TextStyle(
            //       color: AppColors.primary,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            // ),

            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ActionButton(
                    icon: Icons.copy,
                    label: 'Sao chép liên kết',
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: inviteLink));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã sao chép liên kết')),
                        );
                      }
                    },
                  ),
                  _ActionButton(
                    icon: Icons.share_outlined,
                    label: 'Chia sẻ liên kết',
                    onTap: _shareLink,
                  ),
                  _ActionButton(
                    icon: _isSaved
                        ? Icons.image_outlined
                        : Icons.download_outlined,
                    label: _isSaved ? 'Xem ảnh' : 'Lưu mã QR',
                    onTap: _isSaved ? _viewSavedImage : _saveQrToGallery,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 96,
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE9E6F2)),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B6A76)),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
