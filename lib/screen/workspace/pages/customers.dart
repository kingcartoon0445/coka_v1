import 'dart:async';
import 'dart:convert';

import 'package:coka/components/elevated_btn.dart';
import 'package:coka/components/search_anchor.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/workspace/components/customer_filter_bottomsheet.dart';
import 'package:coka/screen/workspace/components/customer_list.dart';
import 'package:coka/screen/workspace/getx/multi_connect_binding.dart';
import 'package:coka/screen/workspace/main_controller.dart';
import 'package:coka/screen/workspace/pages/import_googlesheet.dart';
import 'package:coka/screen/workspace/pages/multi_connect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/import_contact_layout.dart';
import 'add_customer.dart';
import 'dashboard.dart';
import 'package:badges/badges.dart' as badges;

final categories = [
  "Tất cả",
  "Tiềm năng",
  "Giao dịch",
  "Không tiềm năng",
  "Chưa xác định"
];

class WorkspaceCustomersPage extends StatefulWidget {
  const WorkspaceCustomersPage({super.key});

  @override
  State<WorkspaceCustomersPage> createState() => _WorkspaceCustomersPageState();
}

class _WorkspaceCustomersPageState extends State<WorkspaceCustomersPage> {
  late StreamSubscription<bool> keyboardSubscription;

  @override
  void initState() {
    super.initState();

    var keyboardVisibilityController = KeyboardVisibilityController();
    HomeController hController = Get.put(HomeController());
    WorkspaceMainController controller = Get.put(WorkspaceMainController());

    // Subscribe
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) async {
      if (!visible) {
        final prefs = await SharedPreferences.getInstance();
        if (controller.searchController.text.isNotEmpty) {
          if (controller.hintCustomerList
              .contains(controller.searchController.text)) {
            controller.hintCustomerList
                .remove(controller.searchController.text);
          }
          if (controller.hintCustomerList.length > 4) {
            controller.hintCustomerList.removeLast();
          }
          controller.hintCustomerList
              .insert(0, controller.searchController.text);

          controller.hintPrefsData[hController.workGroupCardDataValue["id"]] =
              controller.hintCustomerList.value;
          prefs.setString(
              "hintCustomerData", jsonEncode(controller.hintPrefsData));
        }
        if (controller.isDismiss && controller.searchController.isOpen) {
          Get.back();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WorkspaceMainController>(builder: (controller) {
      return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body: Column(
            children: [
              const SizedBox(
                height: 4,
              ),
              Row(
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child:
                          buildDatePickerBtn(context, controller, false, true)),
                  // CustomSearchBar(
                  //   width: Get.width - 100,
                  //   hintText: "Tìm kiếm khách hàng",
                  //   onQueryChanged: (value) {
                  //     controller.onDebounce(() {
                  //       controller.searchController.text = value;
                  //       controller.onRefresh();
                  //     }, 800);
                  //   },
                  // ),
                  const Spacer(),
                  Obx(() => CustomSearchAnchor(
                      builder: (BuildContext context, controller) {
                        return IconButton(
                          icon: badges.Badge(
                            position:
                                badges.BadgePosition.topEnd(end: 2, top: 2),
                            badgeStyle: const badges.BadgeStyle(
                                padding: EdgeInsets.all(2)),
                            showBadge:
                                controller.text.isNotEmpty ? true : false,
                            child: Icon(Icons.search,
                                color: controller.text.isNotEmpty
                                    ? const Color(0xFF5C33F0)
                                    : null),
                          ),
                          onPressed: () {
                            controller.openView();
                          },
                        );
                      },
                      searchController: controller.searchController,
                      onTextChanged: (p0) {
                        controller.onDebounce(() {
                          controller.onRefresh();
                        }, 800);
                      },
                      isFullScreen: false,
                      viewConstraints: BoxConstraints(
                          minHeight: 0,
                          maxHeight: controller.hintCustomerList.length > 3
                              ? 300.0
                              : controller.hintCustomerList.isEmpty
                                  ? 112
                                  : 57 +
                                      62.0 * controller.hintCustomerList.length,
                          maxWidth: double.infinity,
                          minWidth: double.infinity),
                      suggestionsBuilder: (BuildContext context,
                          CustomSearchController sController) {
                        return controller.hintCustomerList.map((e) {
                          return ListTile(
                            leading: const Icon(Icons.history),
                            title: Text(e),
                            onTap: () {
                              controller.isDismiss = false;
                              controller.searchController.closeView(e);
                              controller.onRefresh();
                              Timer(
                                const Duration(milliseconds: 300),
                                () {
                                  controller.isDismiss = true;
                                },
                              );
                            },
                          );
                        }).toList();
                      })),
                  const SizedBox(
                    width: 2,
                  ),
                  ElevatedBtn(
                    onPressed: () {
                      showCustomerFilterBottomSheet();
                    },
                    circular: 50,
                    paddingAllValue: 0,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: badges.Badge(
                          position:
                              badges.BadgePosition.topEnd(end: -4, top: -4),
                          badgeStyle: const badges.BadgeStyle(
                              padding: EdgeInsets.all(2)),
                          showBadge: !controller.isNotFilter(),
                          child: SvgPicture.asset(
                            "assets/icons/path_icon.svg",
                            color: controller.isNotFilter()
                                ? null
                                : const Color(0xFF5C33F0),
                          )),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  )
                ],
              ),
              TabBar(
                isScrollable: true,
                controller: controller.tabController,
                dividerColor: Colors.transparent,
                tabAlignment: TabAlignment.start,
                tabs: [
                  ...categories.map(
                    (e) {
                      return Tab(
                        child: Row(
                          children: [
                            Row(
                              children: [
                                Text(e,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(
                                  width: 6,
                                ),
                                Container(
                                  constraints:
                                      const BoxConstraints(minWidth: 25),
                                  height: 16,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  decoration: BoxDecoration(
                                      color: getTabBadgeColor(e),
                                      borderRadius: BorderRadius.circular(100)),
                                  child: Center(
                                    child: Text(
                                      (controller.stageCountObject[e] ?? 0)
                                          .toString(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 11),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  )
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: controller.tabController,
                  children: const [
                    CustomerList(groupIndex: 0),
                    CustomerList(groupIndex: 1),
                    CustomerList(groupIndex: 2),
                    CustomerList(groupIndex: 3),
                    CustomerList(groupIndex: 4),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: SpeedDial(
            icon: Icons.add,
            spacing: 15,
            backgroundColor: const Color(0xFF5C33F0),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(14))),
            activeIcon: Icons.close,
            iconTheme: const IconThemeData(color: Colors.white),
            children: [
              SpeedDialChild(
                label: "Thủ công",
                backgroundColor: const Color(0xFFE3DFFF),
                child: const Icon(
                  Icons.create,
                  color: Colors.black,
                ),
                onTap: () {
                  Get.to(() => const AddCustomerPage());
                },
              ),
              SpeedDialChild(
                backgroundColor: const Color(0xFFE3DFFF),
                label: "Google Sheet",
                child: const Icon(
                  Icons.description,
                  color: Colors.black,
                ),
                onTap: () async {
                  Get.to(() => const ImportGoogleSheet());
                },
              ),
              SpeedDialChild(
                backgroundColor: const Color(0xFFE3DFFF),
                label: "Nhập từ danh bạ",
                child: const Icon(
                  Icons.perm_contact_cal_rounded,
                  color: Colors.black,
                ),
                onTap: () async {
                  if (await FlutterContacts.requestPermission()) {
                    importContactLayout();
                  }
                },
              ),
              SpeedDialChild(
                label: "Kết nối đa nguồn",
                backgroundColor: const Color(0xFFE3DFFF),
                onTap: () {
                  Get.to(() => const MultiConnect(),
                      binding: MultiConnectBinding());
                },
                child: const Icon(
                  Icons.link,
                  color: Colors.black,
                ),
              ),
            ],
          ));
    });
  }
}
