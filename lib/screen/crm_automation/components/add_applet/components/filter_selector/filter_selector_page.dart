import 'dart:convert';

import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/elevated_btn.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/filter_selector/components/config_filter_page.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/filter_selector/filter_selector_controller.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/path/path_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../add_applet_controller.dart';

class FilterSelectorPage extends StatelessWidget {
  final bool isPath;

  const FilterSelectorPage({super.key, required this.isPath});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FilterSelectorController>(builder: (controller) {
      return Obx(() {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
              backgroundColor: Colors.white,
              title: const Text(
                'Bộ lọc',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              centerTitle: true,
              leading: ElevatedBtn(
                  onPressed: () {
                    Get.back();
                  },
                  circular: 30,
                  paddingAllValue: 15,
                  child: SvgPicture.asset(
                    'assets/icons/back_arrow.svg',
                    color: Colors.black,
                    height: 30,
                    width: 30,
                  ))),
          body: SizedBox(
            width: double.infinity,
            child: ListView.builder(
              itemCount: controller.orList.length,
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              itemBuilder: (context, i1) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i1 == 0 ? "Chỉ tiếp tục khi" : "Hoặc tiếp tục khi",
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ListView.builder(
                      itemCount: controller.orList[i1].length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, i2) {
                        return AnimationConfiguration.staggeredList(
                            position: i2,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (i2 != 0)
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: Text("Và",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      Row(
                                        children: [
                                          buildFilterRow(controller, i1, i2),
                                          if (controller.orList.length != 1 ||
                                              controller.orList[i1].length != 1)
                                            IconButton(
                                                onPressed: () {
                                                  controller.orList[i1]
                                                      .removeAt(i2);
                                                  if (controller
                                                      .orList[i1].isEmpty) {
                                                    controller.orList
                                                        .removeAt(i1);
                                                  }
                                                  controller.update();
                                                },
                                                icon: const Icon(
                                                  Icons.delete_rounded,
                                                  color: kTextSmallColor,
                                                ))
                                        ],
                                      ),
                                    ],
                                  ),
                                )));
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            controller.orList[i1].add({});
                            controller.update();
                          },
                          child: Container(
                            padding: const EdgeInsets.only(
                                top: 2, right: 8, bottom: 2, left: 4),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: kTextSmallColor, width: 1)),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, color: kTextSmallColor),
                                SizedBox(
                                  width: 3,
                                ),
                                Text(
                                  "Và",
                                  style: TextStyle(
                                      color: kTextSmallColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        if (i1 == controller.orList.length - 1)
                          GestureDetector(
                            onTap: () {
                              controller.orList.add([{}]);
                              controller.update();
                            },
                            child: Container(
                              padding: const EdgeInsets.only(
                                  top: 2, right: 8, bottom: 2, left: 4),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: kTextSmallColor, width: 1)),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add, color: kTextSmallColor),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Text(
                                    "Hoặc",
                                    style: TextStyle(
                                        color: kTextSmallColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
              onPressed: () {
                try {
                  if (isPath) {
                    PathController pathController = Get.put(PathController());
                    final index = pathController.currentIndex.value;

                    final String orList = jsonEncode(controller.orList);

                    final List<Map<String, dynamic>> formatData =
                        formatOrList(controller.orList);

                    final stepsData = {
                      "app": "filter",
                      "type": "filter",
                      "action": "filter",
                      "filter_criteria": formatData
                    };
                    pathController.actionDataList[index] = {
                      "type": "filter",
                      "orList": orList,
                      "stepsData": stepsData,
                    };

                    pathController.update();
                  } else {
                    AddAppletController appletController =
                        Get.put(AddAppletController());
                    final index = appletController.currentIndex.value;

                    final String orList = jsonEncode(controller.orList);

                    final List<Map<String, dynamic>> formatData =
                        formatOrList(controller.orList);

                    final stepsData = {
                      "app": "filter",
                      "type": "filter",
                      "action": "filter",
                      "filter_criteria": formatData
                    };

                    appletController.actionDataList[index] = {
                      "type": "filter",
                      "orList": orList,
                      "stepsData": stepsData,
                    };

                    appletController.update();
                  }

                  Get.back();
                } catch (e) {
                  errorAlert(
                      title: "Lỗi", desc: "Không được để trống điều kiện");
                }
              },
              shape: const CircleBorder(),
              child: const Icon(Icons.check)),
        );
      });
    });
  }

  Widget buildFilterRow(FilterSelectorController controller, int i1, int i2) {
    return OutlinedButton(
      onPressed: () {
        Get.to(() => ConfigFilterPage(
              currentCondition: controller.orList[i1][i2]["currentCondition"],
              currentAction: controller.orList[i1][i2]["currentAction"],
              filterText: controller.orList[i1][i2]["filterText"],
              onUpdateData: (Map<dynamic, dynamic> updateData) {
                controller.orList[i1][i2]["currentCondition"] =
                    updateData["currentCondition"];
                controller.orList[i1][i2]["currentAction"] =
                    updateData["currentAction"];
                controller.orList[i1][i2]["filterText"] =
                    updateData["filterText"];
                controller.update();
              },
            ));
      },
      style: OutlinedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: const BorderSide(color: kTextSmallColor),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
      child: controller.orList[i1][i2].isNotEmpty
          ? Container(
              constraints: BoxConstraints(maxWidth: Get.width - 120),
              child: Text(
                "${controller.orList[i1][i2]["currentAction"]["data"]} ${controller.orList[i1][i2]["currentCondition"]["name"].toString().toLowerCase()} ${controller.orList[i1][i2]["filterText"].replaceAll("{{", "").replaceAll("}}", "")}",
                style: const TextStyle(color: Colors.black),
              ),
            )
          : const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Cấu hình điều kiện",
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(
                  width: 5,
                ),
                Icon(Icons.add_circle, color: kTextSmallColor),
              ],
            ),
    );
  }
}
