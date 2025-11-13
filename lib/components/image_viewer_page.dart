import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class ImagePageViewer extends StatelessWidget {
  final ImageProvider imageProvider;
  const ImagePageViewer({super.key, required this.imageProvider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
      ),
      body: Hero(
        tag: "avatarImg",
        child: PhotoView(
          imageProvider: imageProvider,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
