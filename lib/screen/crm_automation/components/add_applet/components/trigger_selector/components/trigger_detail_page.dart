import 'dart:developer';

import 'package:coka/components/elevated_btn.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/trigger_selector/components/detail_trigger_card_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../add_applet_controller.dart';

class TriggerDetailPage extends StatelessWidget {
  final String id;
  const TriggerDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Chọn trigger',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: triggerUiData[id]!["bgColor"] as Color,
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
        child: Column(
          children: [
            Hero(
              tag: triggerUiData[id]!["name"] as String,
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(minHeight: Get.height * .5 - 100),
                color: triggerUiData[id]!["bgColor"] as Color,
                child: Material(
                  color: Colors.transparent,
                  child: Wrap(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            SvgPicture.asset(
                                triggerUiData[id]!["iconPath"] as String,
                                color: Colors.white,
                                width: 100),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              triggerUiData[id]!["name"] as String,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 22),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text(
                                triggerUiData[id]!["description"] as String,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ListView.builder(
              itemCount: (triggerUiData[id]!["triggers"] as List).length,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemBuilder: (context, index) {
                return DetailTriggerCardItem(
                  onPressed: () {
                    final appletController = Get.put(AddAppletController());
                    appletController.triggerData.value = {
                      "type": id,
                      "index": index,
                      "stepsData": {
                        "app": id,
                        "action": (triggerUiData[id]!["triggers"]
                            as List)[index]["id"],
                      },
                    };
                    log((appletController.triggerData).toString());

                    Get.back();
                    Get.back();
                  },
                  id: id,
                  index: index,
                );
              },
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
            )
          ],
        ),
      ),
    );
  }
}
