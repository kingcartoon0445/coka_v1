import 'package:coka/screen/crm_automation/components/add_applet/add_applet_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class TriggerBtn extends StatelessWidget {
  final VoidCallback onPressed;
  final Map triggerObject;

  const TriggerBtn(
      {super.key, required this.onPressed, required this.triggerObject});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FilledButton(
        style: ElevatedButton.styleFrom(
            backgroundColor:
                triggerUiData[triggerObject["type"]]!["id"] == "default"
                    ? const Color(0xFF5C33F0)
                    : triggerUiData[triggerObject["type"]]!["bgColor"] as Color,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        onPressed: onPressed,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 10,
            ),
            Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(8)),
                child: SvgPicture.asset(
                  triggerUiData[triggerObject["type"]]!["iconPath"] as String,
                  color: Colors.white,
                  width: 45,
                  height: 45,
                )),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '1. Nhận sự kiện',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: Get.width - 120,
                  child: Text(
                    triggerUiData[triggerObject["type"]]!["id"] == "default"
                        ? 'Chọn trigger lắng nghe sự kiện'
                        : (triggerUiData[triggerObject["type"]]!["triggers"]
                            as List)[triggerObject["index"]]["title"],
                    style: const TextStyle(fontSize: 14),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
