import 'package:coka/components/elevated_btn.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/action_selector/components/config_action_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../add_applet_controller.dart';
import 'detail_action_card_item.dart';

class ActionDetailPage extends StatelessWidget {
  final String id;
  final bool isPath;
  const ActionDetailPage({super.key, required this.id, required this.isPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

          title: const Text(
            'Chọn hành động',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: actionUiData[id]!["bgColor"] as Color,
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
              tag: actionUiData[id]!["name"] as String,
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(minHeight: Get.height * .5 - 100),
                color: actionUiData[id]!["bgColor"] as Color,
                child: Material(
                  color: Colors.transparent,
                  child: Wrap(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            SvgPicture.asset(
                                actionUiData[id]!["iconPath"] as String,
                                color: Colors.white,
                                width: 100),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              actionUiData[id]!["name"] as String,
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
                                actionUiData[id]!["description"] as String,
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
              itemCount: (actionUiData[id]!["actions"] as List).length,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemBuilder: (context, index) {
                return DetailActionCardItem(
                  onPressed: () {
                    Get.to(
                        () => ConfigActionPage(
                              id: id,
                              index: index,
                              isPath: isPath,
                            ),
                        transition: Transition.rightToLeftWithFade);
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
