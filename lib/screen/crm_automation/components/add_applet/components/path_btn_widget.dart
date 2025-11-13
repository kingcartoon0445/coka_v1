import 'dart:convert';

import 'package:coka/constants.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/more_path_dropdown_btn.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/path/path_binding.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/path/path_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../add_applet_controller.dart';
import 'longpressed_bottomsheet.dart';

class PathBtnWidget extends StatelessWidget {
  final int index;

  const PathBtnWidget({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddAppletController>(builder: (controller) {
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
                    side: const BorderSide(color: Colors.transparent),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                onPressed: () {},
                onLongPress: () {
                  showLongPressedBottomSheet(
                    onDeleteOk: () {
                      controller.actionList.removeAt(index);
                      Get.back();
                    },
                  );
                },
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.transparent),
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
                          child: Text(
                            '${index + 2}. Rẻ nhánh',
                            style: TextStyle(
                                fontSize: 18,
                                color: actionUiData[type]!["color"] as Color,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: kTextSmallColor.withOpacity(0.1),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ListView.builder(
                        itemBuilder: (context, i2) {
                          return controller
                                  .actionDataList[index]["pathList"][i2]
                                  .isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    Get.to(
                                        () => PathPage(
                                            title:
                                                "Nhánh ${convertIndexToAlphabet(i2)}",
                                            i1: index,
                                            i2: i2),
                                        arguments: jsonEncode(
                                            controller.actionDataList[index]
                                                ["pathList"][i2]),
                                        binding: PathBinding());
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFEEE9),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 10),
                                    margin: const EdgeInsets.only(
                                        bottom: 10, left: 12, right: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 35,
                                          height: 35,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                              border: Border.all(
                                                  color: Colors.transparent)),
                                          child: Center(
                                            child: Container(
                                              height: 25,
                                              width: 25,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(2)),
                                              child: Text(
                                                convertIndexToAlphabet(i2),
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 6,
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              "Nhánh ${convertIndexToAlphabet(i2)}",
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        MoreDropdown(
                                          index: i2,
                                          onDeleteClick: () {
                                            controller.deleteOneItemPath(
                                                index, i2);
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              : Container();
                        },
                        itemCount:
                            controller.actionDataList[index]["pathList"].length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics()),
                    ElevatedButton(
                      onPressed: () {
                        controller.actionDataList[index]["pathList"].add([]);
                        controller.addOnePath(
                            index,
                            controller
                                    .actionDataList[index]["pathList"].length -
                                1);
                        controller.update();
                      },
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white),
                      child: const Text(
                        "Thêm nhánh mới",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    )
                  ],
                ),
              ),
            )
          : Container();
    });
  }
}
