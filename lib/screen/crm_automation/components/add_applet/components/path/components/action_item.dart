import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../action_selector/action_selector_controller.dart';
import '../../action_selector/components/config_action_page.dart';
import '../../filter_selector/filter_selector_binding.dart';
import '../../filter_selector/filter_selector_page.dart';
import '../../longpressed_bottomsheet.dart';
import '../../pressed_bottomsheet.dart';
import '../../stick_add_widget.dart';
import '../path_controller.dart';
import 'action_btn_widget.dart';

class ActionItem extends StatelessWidget {
  final Animation<double> animation;
  final int index;

  const ActionItem({super.key, required this.animation, required this.index});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PathController>(builder: (controller) {
      return SizeTransition(
        sizeFactor: animation,
        child: Column(
          children: [
            index >= controller.actionDataList.length
                ? Container()
                : ActionBtn(
                    onPressed: () {
                      controller.currentIndex.value = index;
                      if (controller.actionDataList[index]["type"] ==
                          "filter") {
                        print(controller.actionDataList[index]);
                        Get.to(() => const FilterSelectorPage(isPath: true),
                            binding: FilterSelectorBinding(),
                            arguments: controller.actionDataList[index]);
                      } else if (controller.actionDataList[index]["stepsData"]
                              ?["app"] ==
                          "GmailApi") {
                        print(controller.actionDataList[index]["index"]);

                        Get.put(ActionSelectorController());
                        Get.to(() => ConfigActionPage(
                              id: "email",
                              index: controller.actionDataList[index]["index"],
                              isPath: true,
                            ));
                      } else {
                        showPressedBottomSheet(
                            isLast: index == (controller.actionList.length - 1)
                                ? true
                                : false,
                            index: index,
                            isPath: true);
                      }
                    },
                    onLongPress: () {
                      showLongPressedBottomSheet(
                        onDeleteOk: () {
                          controller.actionList.pathRemoveAt(index);
                          Get.back();
                        },
                      );
                    },
                    index: index),
            if (index < controller.actionDataList.length &&
                controller.actionDataList[index]["type"] != "path")
              StickAdd(
                onPressed: () {
                  controller.actionList.pathInsert(index + 1, index + 1);
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
