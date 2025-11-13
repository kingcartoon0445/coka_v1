import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:coka/components/elevated_btn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showLongPressedBottomSheet({required VoidCallback onDeleteOk}) {
  Get.bottomSheet(Container(
    constraints: const BoxConstraints(minHeight: 90),
    padding: const EdgeInsets.only(bottom: 10),
    width: double.infinity,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), color: Colors.white),
    child: Wrap(
      children: [
        Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Container(
              height: 4,
              width: 28,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(3)),
              ),
            ),
            const SizedBox(
              height: 32,
            ),
            ElevatedBtn(
              circular: 0,
              paddingAllValue: 5,
              onPressed: () {
                AwesomeDialog(
                  context: Get.context!,
                  dialogType: DialogType.warning,
                  headerAnimationLoop: false,
                  animType: AnimType.topSlide,
                  closeIcon: const Icon(Icons.close_fullscreen_outlined),
                  title: 'Warning',
                  desc: 'Bạn có chắc sẽ xóa hành động này ?',
                  btnCancelOnPress: () {},
                  onDismissCallback: (type) {
                    debugPrint('Dialog Dismiss from callback $type');
                  },
                  btnOkOnPress: onDeleteOk,
                ).show();
              },
              child:  const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 14),
                  Icon(
                    Icons.delete,
                    color: Colors.redAccent,
                  ),
                  SizedBox(width: 14),
                  Text(
                    "Xóa",
                    style: TextStyle(color: Colors.redAccent, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ],
    ),
  ));
}
