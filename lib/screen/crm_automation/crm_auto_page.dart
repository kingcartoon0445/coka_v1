import 'package:coka/screen/crm_automation/components/add_applet/add_applet_binding.dart';
import 'package:coka/screen/crm_automation/components/add_applet/add_applet_page.dart';
import 'package:coka/screen/crm_automation/components/applet_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../components/elevated_btn.dart';
import 'components/add_applet/add_applet_controller.dart';
import 'crm_auto_controller.dart';

final sampleList = [
  {
    "icon_1": "assets/icons/customer_2_icon.svg",
    "icon_2": "assets/icons/gmail.svg",
    "title": "Nếu có khách hàng phát sinh, tự động phân phối đến Đội sale.",
    "isActive": false
  },
  {
    "icon_1": "assets/icons/customer_2_icon.svg",
    "icon_2": "assets/icons/gmail.svg",
    "title":
        "Nếu có khách hàng phát sinh, tự động phân phối đến Nhân viên sale.",
    "isActive": true
  },
  {
    "icon_1": "assets/icons/customer_2_icon.svg",
    "icon_2": "assets/icons/assign.svg",
    "title": "Nếu có khách hàng phát sinh, gửi thông báo đến Telegram.",
    "isActive": false
  },
];

class CrmAutoPage extends StatelessWidget {
  const CrmAutoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CrmAutoController>(builder: (controller) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'Automation',
            style: TextStyle(
                color: Color(0xFF171A1F),
                fontSize: 18,
                fontWeight: FontWeight.bold),
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
                height: 30,
                width: 30,
              )),
        ),
        body: RefreshIndicator(
          onRefresh: () {
            return controller.fetchCamList();
          },
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 600),
              child: controller.isFetching.value
                  ? buildPlaceholder()
                  : controller.isEmpty.value
                      ? buildAutoEmpty()
                      : Column(
                          children: [
                            ...controller.camList.map((e) {
                              final triggerData =
                                  triggerUiData[e["trigger"]["app"]];
                              var icons = [];
                              var title = "";
                              icons.add(triggerData?["iconPath"]);
                              var matchingElement =
                                  (triggerData?["triggers"] as List).firstWhere(
                                (element) =>
                                    element["id"] == e["trigger"]["action"],
                                orElse: () => <String, String>{},
                              );

                              title = matchingElement?["title"] + ", ";

                              for (var x in e["steps"]) {
                                icons.add(actionUiData[x["app"]]?["iconPath"]);
                                final findAction =
                                    (actionUiData[x["app"]]?["actions"] as List)
                                        .firstWhere(
                                  (element) => element["id"] == x["action"],
                                );
                                title +=
                                    "${findAction["title"].toLowerCase()} ";
                              }
                              final dataItem = {
                                "id": e["_id"],
                                "steps": e["steps"],
                                "trigger": e["trigger"],
                                "icons": icons,
                                "title": title,
                                "isActive": e["stage"],
                                "uiData": e["uiData"],
                              };
                              return AppletItem(
                                dataItem: dataItem,
                              );
                            })
                          ],
                        ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.to(() => const AddAppletPage(isEdit: false),
                binding: AddAppletBinding());
          },
          backgroundColor: const Color(0xFF5C33F0),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
    });
  }

  Column buildPlaceholder() {
    return Column(
      children: [
        ...List.generate(10, (index) => 1).map((e) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                enabled: true,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ))
      ],
    );
  }

  Center buildAutoEmpty() {
    return Center(
      child: Column(
        children: [
          Image.asset(
            "assets/images/auto_empty.png",
            width: Get.width - 40,
          ),
          const Text("Hiện chưa có kịch bản nào"),
          ElevatedButton(
              onPressed: () {
                Get.to(() => const AddAppletPage(isEdit: false),
                    binding: AddAppletBinding());
              },
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  backgroundColor: const Color(0xFF5C33F0)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Thêm",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
