import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../add_applet_controller.dart';
import '../path_controller.dart';

class ActionBtn extends StatelessWidget {
  final VoidCallback onPressed;
  final VoidCallback onLongPress;
  final int index;

  const ActionBtn(
      {super.key,
      required this.onPressed,
      required this.index,
      required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PathController>(builder: (controller) {
      final type = index < controller.actionDataList.length
          ? controller.actionDataList[index]["type"]
          : "";
      return index < controller.actionDataList.length
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                    backgroundColor: actionUiData[type]?["bgColor"] as Color,
                    side: BorderSide(
                        color: actionUiData[type]?["id"] == "default"
                            ? Colors.transparent
                            : Colors.transparent),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                onPressed: onPressed,
                onLongPress: onLongPress,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: actionUiData[type]?["iconBg"] as Color,
                          borderRadius: BorderRadius.circular(8)),
                      child: SvgPicture.asset(
                        actionUiData[type]!["iconPath"] as String,
                        width: 30,
                        height: 30,
                        color: actionUiData[type]!["iconColor"] as Color,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: Get.width - 105,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${index + 1}. ${actionUiData[type]!["type"] == "action" ? "Hành động" : actionUiData[type]!["type"] == "filter" ? "Bộ lọc" : "Chọn hành động"}',
                            style: TextStyle(
                                fontSize: 18,
                                color: actionUiData[type]!["color"] as Color,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            actionUiData[type]!["description"] as String,
                            style: TextStyle(
                                fontSize: 16,
                                color: actionUiData[type]!["color"] as Color),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Container();
    });
  }
}
