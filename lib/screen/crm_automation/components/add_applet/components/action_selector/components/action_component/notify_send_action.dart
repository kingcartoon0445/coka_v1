import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../add_applet_controller.dart';
import '../../../path/path_controller.dart';
import '../../action_selector_controller.dart';
import 'textfield_ingredient.dart';

class NotifyAction extends StatefulWidget {
  final String id;
  final int index;
  final bool isPath;

  const NotifyAction(
      {super.key, required this.id, required this.index, required this.isPath});

  @override
  State<NotifyAction> createState() => _NotifyActionState();
}

class _NotifyActionState extends State<NotifyAction> {
  TextEditingController titleController =
      TextEditingController(text: "Automation Notify");
  TextEditingController bodyController =
      TextEditingController(text: "Bạn có một thông báo từ Coka");

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ActionSelectorController>(builder: (controller) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFieldIngredient(
            maxLine: 2,
            label: "Tiêu đề",
            controller: titleController,
          ),
          const SizedBox(
            height: 10,
          ),
          TextFieldIngredient(
            maxLine: 2,
            label: "Nội dung",
            controller: bodyController,
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: Get.width - 40,
            height: 50,
            child: ElevatedButton(
                onPressed: () async {
                  final fcmToken = await FirebaseMessaging.instance.getToken();
                  final stepsData = {
                    "app": "notify",
                    "type": "write",
                    "action": "notify_send",
                    "params": {
                      "fcmToken": fcmToken.toString(),
                      "title": titleController.text,
                      "body": bodyController.text
                    }
                  };
                  if (widget.isPath) {
                    PathController pathController = Get.put(PathController());
                    final index = pathController.currentIndex.value;
                    final isEdit = pathController.actionDataList[index]
                            ["stepsData"] ==
                        null;
                    print(pathController.currentIndex);

                    pathController.actionDataList[index] = {
                      "type": "notify",
                      "stepsData": stepsData,
                      "index": widget.index
                    };
                    print(pathController.actionDataList[index]);
                    pathController.update();
                    if (isEdit) {
                      Get.back();
                      Get.back();
                    }
                  } else {
                    AddAppletController appletController =
                        Get.put(AddAppletController());
                    final index = appletController.currentIndex.value;
                    final isEdit = appletController.actionDataList[index]
                            ["stepsData"] ==
                        null;
                    print(appletController.currentIndex);

                    appletController.actionDataList[index] = {
                      "type": "notify",
                      "stepsData": stepsData,
                      "index": widget.index
                    };
                    print(appletController.actionDataList[index]);
                    appletController.update();
                    if (isEdit) {
                      Get.back();
                      Get.back();
                    }
                  }

                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white),
                child: const Text(
                  "Tiếp tục",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                )),
          )
        ],
      );
    });
  }
}
