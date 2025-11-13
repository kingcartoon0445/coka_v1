import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

class BottomMenuPicker extends StatelessWidget {
  const BottomMenuPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Container(
          height: Get.bottomBarHeight,
          // Your emoji picker content here
        );
      },
    );
  }
}
