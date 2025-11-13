import 'package:coka/screen/crm_automation/components/add_applet/add_applet_controller.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/action_selector/components/config_action_page.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/path_btn_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'action_btn_widget.dart';
import 'action_selector/action_selector_controller.dart';
import 'filter_selector/filter_selector_binding.dart';
import 'filter_selector/filter_selector_page.dart';
import 'longpressed_bottomsheet.dart';
import 'pressed_bottomsheet.dart';
import 'stick_add_widget.dart';

class ActionItem extends StatelessWidget {
  final Animation<double> animation;
  final int index;

  const ActionItem({super.key, required this.animation, required this.index});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddAppletController>(builder: (controller) {
      return SizeTransition(
        sizeFactor: animation,
        child: Column(
          children: [
            index >= controller.actionDataList.length
                ? Container()
                : controller.actionDataList[index]["type"] == "path"
                    ? PathBtnWidget(index: index)
                    : ActionBtn(
                        onPressed: () {
                          controller.currentIndex.value = index;
                          if (controller.actionDataList[index]["type"] ==
                              "filter") {
                            print(controller.actionDataList[index]);
                            Get.to(
                                () => const FilterSelectorPage(isPath: false),
                                binding: FilterSelectorBinding(),
                                arguments: controller.actionDataList[index]);
                          } else if (controller.actionDataList[index]
                                  ["stepsData"]?["app"] ==
                              "email") {
                            Get.put(ActionSelectorController());
                            Get.to(() => ConfigActionPage(
                                  id: "email",
                                  index: controller.actionDataList[index]
                                      ["index"],
                                  isPath: false,
                                ));
                          } else if (controller.actionDataList[index]
                                  ["stepsData"]?["app"] ==
                              "assign") {
                            Get.put(ActionSelectorController());
                            Get.to(() => ConfigActionPage(
                                  id: "assign",
                                  index: controller.actionDataList[index]
                                      ["index"],
                                  isPath: false,
                                ));
                          } else {
                            showPressedBottomSheet(
                              isLast:
                                  index == (controller.actionList.length - 1)
                                      ? true
                                      : false,
                              index: index,
                            );
                          }
                        },
                        onLongPress: () {
                          showLongPressedBottomSheet(
                            onDeleteOk: () {
                              controller.actionList.removeAt(index);
                              Get.back();
                            },
                          );
                        },
                        index: index),
            if (index < controller.actionDataList.length &&
                controller.actionDataList[index]["type"] != "path")
              StickAdd(
                onPressed: () {
                  controller.actionList.insert(index + 1, index + 1);
                },
                isEnd:
                    index == (controller.actionList.length - 1) ? true : false,
              )
          ],
        ),
      );
    });
  }
}
