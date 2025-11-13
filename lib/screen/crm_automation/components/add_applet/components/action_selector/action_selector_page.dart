import 'package:coka/screen/crm_automation/components/add_applet/add_applet_controller.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/action_selector/action_selector_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../../../components/elevated_btn.dart';
import 'components/action_card_item.dart';
import 'components/action_detail_page.dart';

class ActionSelectorPage extends StatelessWidget {
  final bool isPath;

  const ActionSelectorPage({super.key, required this.isPath});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ActionSelectorController>(builder: (controller) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text(
              'Chọn hành động',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                ))),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: Get.width,
                  height: 50,
                  child: TextFormField(
                    maxLines: 1,
                    onChanged: (value) {
                      controller.onSearchChanged(value);
                    },
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(top: 8),
                      filled: true,
                      fillColor: Color(0xFFf3f4f6),
                      hintText: "Tìm kiếm",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  children: List.generate(
                    actionUiData.keys.length - 3,
                    (index) => Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: CardItem(
                        onPressed: () {
                          Get.to(
                              () => ActionDetailPage(
                                    id: actionUiData.keys.toList()[index + 3],
                                    isPath: isPath,
                                  ),
                              transition: Transition.rightToLeft,
                              duration: const Duration(milliseconds: 300));
                        },
                        id: actionUiData.keys.toList()[index + 3],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
