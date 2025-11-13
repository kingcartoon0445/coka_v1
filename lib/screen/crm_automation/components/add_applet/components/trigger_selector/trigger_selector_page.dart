import 'package:coka/components/elevated_btn.dart';
import 'package:coka/screen/crm_automation/components/add_applet/add_applet_controller.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/trigger_selector/components/trigger_card_item.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/trigger_selector/components/trigger_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'trigger_selector_controller.dart';

class TriggerSelectorPage extends StatelessWidget {
  const TriggerSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TriggerSelectorController>(builder: (controller) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text(
              'Chọn trigger',
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
                    triggerUiData.keys.length - 1,
                    (index) {
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: CardItem(
                          onPressed: () {
                            Get.to(
                                () => TriggerDetailPage(
                                    id: triggerUiData.keys.toList()[index + 1]),
                                transition: Transition.rightToLeft,
                                duration: const Duration(milliseconds: 300));
                          },
                          id: triggerUiData.keys.toList()[index + 1],
                        ),
                      );
                    },
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
