import 'package:badges/badges.dart' as badges;
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/main/getx/notification_controller.dart';
import 'package:coka/screen/main/pages/more.dart';
import 'package:coka/screen/main/pages/notification.dart';
import 'package:coka/screen/main/pages/support.dart';
import 'package:coka/screen/messages/messages_page.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/api_url.dart';
import '../home/home_page.dart';
import '../workspace/pages/multi_channel.dart';
import 'main_controller.dart';

final screens = [
  const HomePage(),
  const MultiChannel(),
  const NotificationPage(),
  const SupportPage(),
  const MorePage()
];

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final notifyController = Get.put(NotificationController());
  final homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainController>(builder: (controller) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: WillPopScope(
          onWillPop: controller.onWillPop,
          child: DoubleBackToCloseApp(
            snackBar: const SnackBar(
              content: Text('Nhấn thêm lần nữa để thoát'),
            ),
            child: SafeArea(
                child: Obx(
              () => Stack(
                children: [
                  IndexedStack(
                    index: controller.selectedIndex.value,
                    children: screens,
                  ),
                  if (isValidId(homeController.userData["id"] ?? ""))
                    Positioned(
                        bottom: 0,
                        right: 16,
                        child: Row(
                          children: [
                            const Text(
                              "Dev Mode",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Switch(
                              value: homeController.isDevMode.value,
                              onChanged: (value) {
                                homeController.isDevMode.value = value;
                                if (value) {
                                  apiBaseUrl = "https://dev.coka.ai/";
                                } else {
                                  apiBaseUrl = "https://api.coka.ai/";
                                }
                              },
                            ),
                          ],
                        ))
                ],
              ),
            )),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          destinations: [
            const NavigationDestination(
                icon: Icon(Icons.business_outlined, size: 26),
                selectedIcon: Icon(Icons.business_sharp,
                    size: 26, color: Color(0xFF5A48EF)),
                label: 'Tổ chức'),
            NavigationDestination(
                icon: badges.Badge(
                  showBadge: homeController.badgeList.isNotEmpty,
                  position: badges.BadgePosition.topEnd(top: -3, end: -3),
                  child: Image.asset(
                    "assets/images/target_outline_icon.png",
                    width: 24,
                    height: 24,
                  ),
                ),
                selectedIcon: Image.asset(
                  "assets/images/target_icon.png",
                  width: 24,
                  height: 24,
                ),
                label: 'Đa kênh'),
            Obx(() {
              return NavigationDestination(
                  icon: badges.Badge(
                    position: badges.BadgePosition.topEnd(top: -14, end: -14),
                    badgeContent: Text(
                      notifyController.readCount.value > 0
                          ? notifyController.readCount.value > 99
                              ? "+99"
                              : notifyController.readCount.value.toString()
                          : "0",
                      style: const TextStyle(color: Colors.white),
                    ),
                    showBadge:
                        (notifyController.readCount.value <= 0) ? false : true,
                    child: const Icon(CupertinoIcons.bell, size: 26),
                  ),
                  selectedIcon: const Icon(CupertinoIcons.bell_fill,
                      size: 26, color: Color(0xFF5A48EF)),
                  label: 'Thông báo ');
            }),
            NavigationDestination(
                icon: badges.Badge(
                  showBadge: homeController.badgeList.isNotEmpty,
                  position: badges.BadgePosition.topEnd(top: -3, end: -3),
                  child: Image.asset(
                    "assets/images/support_outline_icon.png",
                    width: 24,
                    height: 24,
                  ),
                ),
                selectedIcon: Image.asset("assets/images/support_icon.png",
                    width: 24, height: 24, color: const Color(0xFF5A48EF)),
                label: 'Hỗ trợ'),
            NavigationDestination(
                icon: badges.Badge(
                    showBadge: homeController.isUpdateAble.value,
                    child: const Icon(Icons.settings_outlined, size: 26)),
                selectedIcon: const Icon(Icons.settings_outlined,
                    size: 26, color: Color(0xFF5A48EF)),
                label: 'Cài đặt'),
          ],
          onDestinationSelected: controller.onTapped,
          selectedIndex: controller.selectedIndex.value,
          animationDuration: const Duration(milliseconds: 500),
          indicatorColor: const Color(0xFFDCDBFF),
          backgroundColor: Colors.white,
          elevation: 10,
          shadowColor: Colors.black,
          surfaceTintColor: Colors.white,
        ),
      );
    });
  }
}
