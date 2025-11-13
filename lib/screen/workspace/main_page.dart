import 'package:coka/screen/workspace/getx/dashboard_controller.dart';
import 'package:coka/screen/workspace/getx/team_controller.dart';
import 'package:coka/screen/workspace/pages/customers.dart';
import 'package:coka/screen/workspace/pages/dashboard.dart';
import 'package:coka/screen/workspace/pages/product_sale.dart';
import 'package:coka/screen/workspace/pages/team.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'getx/customer_controller.dart';
import 'getx/multi_connect_controller.dart';
import 'main_binding.dart';
import 'main_controller.dart';

final screens = [
  const WorkspaceDashboardPage(),
  const WorkspaceCustomersPage(),
  const ProductSalePage(),
  const TeamPage(),
];

class WorkspaceMainPage extends StatefulWidget {
  const WorkspaceMainPage({super.key});

  @override
  State<WorkspaceMainPage> createState() => _WorkspaceMainPageState();
}

class _WorkspaceMainPageState extends State<WorkspaceMainPage> {
  @override
  void dispose() {
    Get.delete<WorkspaceMainBinding>();
    Get.delete<TeamController>();
    Get.delete<DashboardController>();
    Get.delete<CustomerController>();
    Get.delete<MultiConnectController>();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WorkspaceMainController>(
        builder: (controller) => Obx(() {
              return WillPopScope(
                onWillPop: controller.onWillPop,
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  body: SafeArea(
                    child: Stack(
                      children: [
                        IndexedStack(
                          index: controller.selectedIndex.value,
                          children: screens,
                        ),
                      ],
                    ),
                  ),
                  bottomNavigationBar: NavigationBar(
                    destinations: [
                      NavigationDestination(
                          icon: Image.asset(
                            "assets/images/workspace_outline_icon.png",
                            width: 24,
                            height: 24,
                          ),
                          selectedIcon: Image.asset(
                            "assets/images/workspace_icon.png",
                            width: 24,
                            height: 24,
                          ),
                          label: 'NLV'),
                      NavigationDestination(
                          icon: Image.asset(
                            "assets/images/customer_outline_icon.png",
                            width: 24,
                            height: 24,
                          ),
                          selectedIcon: Image.asset(
                            "assets/images/customer_icon.png",
                            width: 24,
                            height: 24,
                          ),
                          label: 'Khách hàng'),
                      NavigationDestination(
                          icon: Image.asset(
                            "assets/images/demand_outline_icon.png",
                            width: 24,
                            height: 24,
                          ),
                          selectedIcon: Image.asset(
                            "assets/images/demand_icon.png",
                            width: 24,
                            height: 24,
                          ),
                          label: 'Bán hàng'),
                      NavigationDestination(
                          icon: Image.asset(
                            "assets/images/team_outline_icon.png",
                            width: 24,
                            height: 24,
                          ),
                          selectedIcon: Image.asset(
                            "assets/images/team_icon.png",
                            width: 24,
                            height: 24,
                          ),
                          label: 'Đội Sale'),
                    ],
                    onDestinationSelected: controller.onTapped,
                    selectedIndex: controller.selectedIndex.value,
                    backgroundColor: Colors.white,
                    elevation: 10,
                    shadowColor: Colors.black,
                    surfaceTintColor: Colors.white,
                    indicatorColor: const Color(0xFFDCDBFF),
                  ),
                ),
              );
            }));
  }
}
