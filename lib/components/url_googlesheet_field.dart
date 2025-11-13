import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UrlGoogleSheetField extends StatefulWidget {
  final TextEditingController urlController;
  final Function onSubmit, onRetry;
  final String? errorMessage, successMessage, fileName;
  const UrlGoogleSheetField({
    super.key,
    required this.urlController,
    required this.onSubmit,
    this.errorMessage,
    this.successMessage,
    this.fileName,
    required this.onRetry,
  });

  @override
  State<UrlGoogleSheetField> createState() => _UrlGoogleSheetFieldState();
}

class _UrlGoogleSheetFieldState extends State<UrlGoogleSheetField>
    with TickerProviderStateMixin {
  late AnimationController _controller, _containerController;
  late Animation widthAnimate,
      p0Animate,
      p1Animate,
      icon0Animate,
      icon1Animate,
      iconPaddingAnimate,
      borderRadiusAnimate;
  bool isLoading = false;
  bool isHideText = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      reverseDuration: const Duration(seconds: 1),
    );
    _containerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      reverseDuration: const Duration(milliseconds: 600),
    );
    widthAnimate = Tween(begin: 113.0, end: 50.0).animate(_containerController);
    p0Animate = Tween(begin: 0.0, end: 8.0).animate(_containerController);
    p1Animate = Tween(
            begin: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
            end: const EdgeInsets.symmetric(horizontal: 0))
        .animate(_containerController);

    icon1Animate = Tween(begin: 24.0, end: 34.0).animate(_containerController);
    iconPaddingAnimate =
        Tween(begin: 0.0, end: 8.0).animate(_containerController);
    borderRadiusAnimate = BorderRadiusTween(
            begin: const BorderRadius.horizontal(right: Radius.circular(4)),
            end: BorderRadius.circular(50))
        .animate(_containerController);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleRotation() {
    if (formKey.currentState!.validate() &&
        isLoading == false &&
        widget.errorMessage == null &&
        widget.successMessage == null) {
      formKey.currentState!.save();
      widget.onSubmit();
      _controller.repeat();
      _containerController.forward();

      setState(() {
        isLoading = !isLoading;
      });
    }
  }

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (widget.errorMessage != null || widget.successMessage != null) {
      isLoading = false;
      isHideText = true;
    } else if (isLoading == false) {
      isHideText = false;
      _controller.stop();
      _containerController.reset();
    }

    return AnimatedBuilder(
        animation: _containerController,
        builder: (context, child) {
          return Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: widget.urlController,
                  readOnly: isLoading || isHideText,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Hãy điền url của Google Sheet';
                    }
                    return null;
                  },
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isLoading || isHideText
                          ? Colors.transparent
                          : Colors.black),
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide.none),
                      hintText: "Nhập link GoogleSheet",
                      prefixIcon: widget.errorMessage != null
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 12,
                                ),
                                Icon(Icons.folder,
                                    size: 36, color: Color(0xFFF9EBDD)),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "Có lỗi xảy ra",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14),
                                )
                              ],
                            )
                          : isLoading
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    const Icon(Icons.folder,
                                        size: 36, color: Color(0xFF646A72)),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    AnimatedTextKit(animatedTexts: [
                                      WavyAnimatedText(
                                        "Đang xử lý",
                                        textStyle: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14),
                                      )
                                    ])
                                  ],
                                )
                              : widget.successMessage != null
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(
                                          width: 12,
                                        ),
                                        const Icon(Icons.folder,
                                            size: 36, color: Color(0xFF63D3B3)),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          widget.fileName!,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14),
                                        )
                                      ],
                                    )
                                  : null,
                      suffixIcon: InkWell(
                        onTap: _toggleRotation,
                        child: Padding(
                          padding: EdgeInsets.all(p0Animate.value),
                          child: Container(
                            width: widthAnimate.value,
                            padding: p1Animate.value,
                            decoration: BoxDecoration(
                              borderRadius: borderRadiusAnimate.value,
                              color: widget.errorMessage == null &&
                                      widget.successMessage == null &&
                                      !isLoading
                                  ? const Color(0xFF554FE8)
                                  : isLoading
                                      ? const Color(0xFF858F9F)
                                      : widget.successMessage != null
                                          ? const Color(0xFFE5F8F5)
                                          : const Color(0xFFFBECDE),
                            ),
                            child: Row(children: [
                              widget.errorMessage == null &&
                                      widget.successMessage == null
                                  ? RotationTransition(
                                      turns: Tween(begin: 0.0, end: 1.0)
                                          .animate(_controller),
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                            iconPaddingAnimate.value),
                                        child: Icon(Icons.sync,
                                            size: icon1Animate.value,
                                            color: Colors.white),
                                      ),
                                    )
                                  : widget.successMessage != null
                                      ? Padding(
                                          padding: EdgeInsets.all(
                                              iconPaddingAnimate.value),
                                          child: const Icon(Icons.check,
                                              size: 34,
                                              color: Color(0xB263D4B4)),
                                        )
                                      : Padding(
                                          padding: EdgeInsets.all(
                                              iconPaddingAnimate.value),
                                          child: const Icon(Icons.warning,
                                              size: 34,
                                              color: Color(0xFFEE6002)),
                                        ),
                              if (!(isLoading || isHideText))
                                const Row(
                                  children: [
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "Kiểm tra",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 11),
                                    )
                                  ],
                                )
                            ]),
                          ),
                        ),
                      ),
                      fillColor: Colors.white,
                      filled: true),
                ),
                if (widget.errorMessage != null)
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        color: Color(0xFFFBECDE),
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(4))),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    child: Row(children: [
                      SizedBox(
                        width: Get.width - 140,
                        child: Text(
                          widget.errorMessage!,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(70, 28),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              backgroundColor: const Color(0xFFEC6002)),
                          onPressed: () {
                            widget.onRetry();
                          },
                          child: const Text(
                            "Thử lại",
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ))
                    ]),
                  ),
                if (widget.successMessage != null)
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        color: Color(0xFFE5F8F5),
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(4))),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 18),
                    child: Text(
                      widget.successMessage!,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                  ),
              ],
            ),
          );
        });
  }
}
