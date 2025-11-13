import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void successAlert(
    {required String title, required String desc, VoidCallback? btnOkOnPress}) {
  AwesomeDialog(
    context: Get.context!,
    animType: AnimType.leftSlide,
    headerAnimationLoop: false,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    dialogType: DialogType.success,
    showCloseIcon: true,
    title: title,
    desc: desc != "" ? desc : null,
    btnOkIcon: Icons.check_circle,
    btnOkOnPress: btnOkOnPress ?? () {},
  ).show();
}

void errorAlert({required String title, required String desc}) {
  AwesomeDialog(
    context: Get.context!,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    animType: AnimType.leftSlide,
    headerAnimationLoop: false,
    dialogType: DialogType.error,
    showCloseIcon: true,
    title: title,
    desc: desc != "" ? desc : null,
    btnOkIcon: Icons.check_circle,
    btnOkOnPress: () {
      debugPrint('OnClcik');
    },
  ).show();
}

void warningAlert(
    {required String title,
    required String desc,
    String? nameOkBtn,
    required Function btnOkOnPress}) {
  AwesomeDialog(
    context: Get.context!,
    dialogType: DialogType.warning,
    headerAnimationLoop: false,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    animType: AnimType.bottomSlide,
    title: title,
    desc: desc != "" ? desc : null,
    buttonsTextStyle: const TextStyle(color: Colors.white, fontSize: 15),
    btnCancelText: 'Hủy',
    btnOkText: nameOkBtn ?? 'Xóa',
    showCloseIcon: true,
    btnCancelOnPress: () {},
    btnOkOnPress: () {
      btnOkOnPress();
    },
  ).show();
}
