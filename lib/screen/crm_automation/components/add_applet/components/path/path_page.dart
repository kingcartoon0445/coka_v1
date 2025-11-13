import 'package:coka/components/elevated_btn.dart';
import 'package:coka/screen/crm_automation/components/add_applet/add_applet_controller.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/path/path_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'components/action_item.dart';

class PathPage extends StatelessWidget {
  final String title;
  final int i1, i2;
  const PathPage(
      {super.key, required this.title, required this.i1, required this.i2});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PathController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            leading: ElevatedBtn(
                onPressed: () {
                  Get.back();
                },
                circular: 30,
                paddingAllValue: 15,
                child: SvgPicture.asset(
                  'assets/icons/back_arrow.svg',
                  height: 30,
                  width: 30,
                )),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                AnimatedList(
                  key: controller.listKey,
                  initialItemCount: controller.actionList.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index, animation) {
                    return ActionItem(animation: animation, index: index);
                  },
                ),
                const SizedBox(
                  height: 80,
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final appletController = Get.put(AddAppletController());
                appletController.actionDataList[i1]["pathList"][i2] =
                    controller.actionDataList;
                appletController.update();
                Get.back();
              },
              child: const Icon(Icons.check)),
        );
      },
    );
  }
}
