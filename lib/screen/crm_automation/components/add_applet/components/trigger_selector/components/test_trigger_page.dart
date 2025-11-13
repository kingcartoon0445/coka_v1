import 'dart:developer';

import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/elevated_btn.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/crm_automation/components/add_applet/add_applet_controller.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/trigger_selector/trigger_selector_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class TestTriggerPage extends StatefulWidget {
  final String id;
  final int index;

  const TestTriggerPage({super.key, required this.id, required this.index});

  @override
  State<TestTriggerPage> createState() => _TestTriggerPageState();
}

class _TestTriggerPageState extends State<TestTriggerPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final controller = Get.put(TriggerSelectorController());
    controller.testData.clear();
  }

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<ScaffoldState>();
    return GetBuilder<TriggerSelectorController>(builder: (controller) {
      return Obx(() {
        return Scaffold(
          key: key,
          appBar: AppBar(
              title: const Text(
                'Kiểm tra trigger',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              actions: [
                if (controller.testData.keys.isNotEmpty)
                  IconButton(
                      onPressed: () {
                        final appletController = Get.put(AddAppletController());
                        appletController.triggerData.value = {
                          "type": widget.id,
                          "index": widget.index,
                          "stepsData": {
                            "app": "JsonData",
                            "type": "read",
                            "action": "json_read",
                          },
                        };
                        log((appletController.triggerData).toString());

                        Get.back();
                        Get.back();
                        Get.back();
                      },
                      style:
                          IconButton.styleFrom(foregroundColor: Colors.white),
                      icon: const Icon(
                        Icons.check,
                        color: Colors.white,
                      ))
              ],
              backgroundColor: triggerUiData[widget.id]!["bgColor"] as Color,
              leading: ElevatedBtn(
                  onPressed: () {
                    Get.back();
                  },
                  circular: 30,
                  paddingAllValue: 15,
                  child: SvgPicture.asset(
                    'assets/icons/back_arrow.svg',
                    color: Colors.white,
                    height: 30,
                    width: 30,
                  ))),
          body: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              constraints: BoxConstraints(minHeight: Get.height),
              color: triggerUiData[widget.id]!["bgColor"] as Color,
              child: Column(
                children: [
                  SvgPicture.asset(
                      triggerUiData[widget.id]!["iconPath"] as String,
                      color: Colors.white,
                      width: 100),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    triggerUiData[widget.id]!["name"] as String,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                        fontSize: 22),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    (triggerUiData[widget.id]!["triggers"]
                        as List)[widget.index]["title"],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        controller.testRun();
                        successAlert(
                            title: "Thành công",
                            desc: "Trigger đang hoạt động");
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white),
                      child: const Text(
                        "Kiểm tra",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black),
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: controller.testData.keys.isNotEmpty
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 8,
                        ),
                        for (var x in controller.testData.entries)
                          if (controller.formatData[x.key] != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ElevatedBtn(
                                  paddingAllValue: 0,
                                  onPressed: () {},
                                  onLongPressd: () {
                                    Clipboard.setData(ClipboardData(
                                        text: controller.formatData[x.key] +
                                            ": " +
                                            x.value.toString()));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text("Đã copy nội dung này"),
                                    ));
                                  },
                                  circular: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 15),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  "${controller.formatData[x.key]}: ",
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            TextSpan(
                                              text: x.value.toString(),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (controller.testData.keys.lastWhere(
                                        (element) =>
                                            controller.formatData[element] !=
                                            null) !=
                                    x.key)
                                  Container(
                                    width: double.infinity,
                                    height: 1,
                                    color: kTextSmallColor,
                                  )
                              ],
                            ),
                        const SizedBox(
                          height: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                ],
              ),
            ),
          ),
        );
      });
    });
  }
}
