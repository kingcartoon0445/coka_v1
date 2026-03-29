import 'dart:convert';

import 'package:coka/components/auto_avatar.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/home/pages/join_org_page.dart';
import 'package:coka/screen/main/main_controller.dart';
import 'package:coka/screen/main/pages/detail_member.dart';
import 'package:coka/screen/main/pages/support_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/user.dart';
import 'loading_dialog.dart';

class NavigationDrawerSection extends StatefulWidget {
  final Function onCloseDrawer;

  const NavigationDrawerSection({super.key, required this.onCloseDrawer});

  @override
  State<NavigationDrawerSection> createState() =>
      _NavigationDrawerSectionState();
}

class _NavigationDrawerSectionState extends State<NavigationDrawerSection> {
  HomeController homeController = Get.put(HomeController());
  MainController mainController = Get.put(MainController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    homeController.getOrgData().then((value) {
      setState(() {
        homeController.navDrawerIndex.value =
            (homeController.orgList.indexWhere(
          (e) => e["id"] == homeController.oData["id"],
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (controller) {
      return NavigationDrawer(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        // onDestinationSelected: (selectedIndex) async {
        //   final prefs = await SharedPreferences.getInstance();
        //   setState(() {
        //     homeController.navDrawerIndex.value = selectedIndex;
        //     prefs.setString(
        //         'oData',
        //         jsonEncode(homeController
        //             .orgList[homeController.navDrawerIndex.value]));
        //     homeController.onRefresh();
        //     widget.onCloseDrawer();
        //   });
        // },
        selectedIndex: homeController.navDrawerIndex.value,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: const Color(0xFFF9F9F9),
                height: Get.height - 100,
                width: 88,
                child: SingleChildScrollView(
                  child: Column(children: [
                    const SizedBox(
                      height: 30,
                    ),
                    ...homeController.orgList.asMap().entries.map((entry) {
                      int selectedIndex = entry.key;
                      final destination = entry.value;
                      return GestureDetector(
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          setState(() {
                            homeController.navDrawerIndex.value = selectedIndex;
                            prefs.setString(
                                'oData',
                                jsonEncode(homeController.orgList[
                                    homeController.navDrawerIndex.value]));
                            homeController.onRefresh();
                            widget.onCloseDrawer();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 14.0),
                          child: Stack(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    destination["avatar"] == null
                                        ? createSquareAvatar(
                                            name: destination["name"],
                                            radius: 20)
                                        : Container(
                                            height: 40,
                                            width: 40,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: getAvatarProvider(
                                                        destination["avatar"]),
                                                    fit: BoxFit.cover),
                                                borderRadius:
                                                    BorderRadius.circular(8))),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 2.0, left: 10, right: 10),
                                      child: Text(destination["name"],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF1F2329))),
                                    ),
                                  ],
                                ),
                              ),
                              if (homeController.navDrawerIndex.value ==
                                  selectedIndex)
                                Positioned(
                                    top: 2,
                                    left: 0,
                                    child: Container(
                                      width: 2,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                          color: kPrimaryColor,
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(6),
                                              bottomRight: Radius.circular(6))),
                                    ))
                            ],
                          ),
                        ),
                      );
                    }),
                    InkWell(
                      onTap: () {
                        Get.toNamed('/createPOrg');
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.add, color: kPrimaryColor),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    )
                  ]),
                ),
              ),
              SizedBox(
                height: Get.height - 110,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        Get.to(() => DetailMember(
                              dataItem: controller.userData,
                              isMyProfile: true,
                            ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 16, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            controller.userData["avatar"] == "" ||
                                    controller.userData["avatar"] == null
                                ? createCircleAvatar(
                                    name:
                                        controller.userData["fullName"] ?? ".",
                                    radius: 22)
                                : CircleAvatar(
                                    backgroundImage: getAvatarProvider(
                                        controller.userData["avatar"]),
                                    radius: 22,
                                  ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.userData["fullName"],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF44474F)),
                                ),
                                const Text(
                                  "Xem profile của bạn",
                                  style: TextStyle(
                                      fontSize: 11,
                                      decorationColor: Color(0xFF828489),
                                      color: Color(0xFF828489),
                                      decoration: TextDecoration.underline),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),

                    // TextButton.icon(
                    //   icon: const Icon(
                    //     Icons.edit,
                    //     size: 20,
                    //     color: kPrimaryColor,
                    //   ),
                    //   label: const Text("Chỉnh sửa tổ chức",
                    //       style: TextStyle(
                    //           color: Color(0xFF1F2329), fontSize: 14)),
                    //   onPressed: () {},
                    // ),
                    TextButton.icon(
                      icon: const Icon(
                        Icons.group_add_outlined,
                        size: 20,
                        color: kPrimaryColor,
                      ),
                      label: const Text("Tham gia tổ chức",
                          style: TextStyle(
                              color: Color(0xFF1F2329), fontSize: 14)),
                      onPressed: () {
                        Get.to(() => const JoinOrgPage());
                      },
                    ),
                    // TextButton.icon(
                    //   icon: const Icon(
                    //     Icons.person_add_outlined,
                    //     size: 20,
                    //     color: kPrimaryColor,
                    //   ),
                    //   label: const Text("Mời",
                    //       style: TextStyle(
                    //           color: Color(0xFF1F2329), fontSize: 14)),
                    //   onPressed: () {},
                    // ),
                    // TextButton.icon(
                    //   icon: const Icon(
                    //     Icons.person_outline,
                    //     size: 20,
                    //     color: kPrimaryColor,
                    //   ),
                    //   label: const Text("Nhân sự",
                    //       style: TextStyle(
                    //           color: Color(0xFF1F2329), fontSize: 14)),
                    //   onPressed: () {},
                    // ),
                    TextButton.icon(
                      icon: const Icon(
                        Icons.help_outline,
                        color: kPrimaryColor,
                        size: 20,
                      ),
                      label: const Text("Trợ giúp - Hỗ trợ",
                          style: TextStyle(
                              color: Color(0xFF1F2329), fontSize: 14)),
                      onPressed: () {},
                    ),
                    TextButton.icon(
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: kPrimaryColor,
                        size: 20,
                      ),
                      label: const Text("Cài đặt",
                          style: TextStyle(
                              color: Color(0xFF1F2329), fontSize: 14)),
                      onPressed: () {},
                    ),
                    TextButton.icon(
                      icon: const Icon(
                        Icons.error_outline,
                        color: kPrimaryColor,
                        size: 20,
                      ),
                      label: const Text("Giới thiệu về Coka",
                          style: TextStyle(
                              color: Color(0xFF1F2329), fontSize: 14)),
                      onPressed: () {
                        Get.to(() => const SupportChatPage());
                      },
                    ),
                    const Spacer(),
                    Container(
                      height: 0.8,
                      width: 216,
                      color: const Color(0xFFC5C6D0),
                    ),
                    TextButton.icon(
                      icon: const Icon(
                        Icons.logout,
                        color: kPrimaryColor,
                        size: 24,
                      ),
                      label: const Text("Đăng xuất",
                          style: TextStyle(color: Color(0xFF1F2329))),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        prefs.clear();
                        Future.delayed(const Duration(milliseconds: 50),
                            () => showLoadingDialog(Get.context!));
                        try {
                          UserApi().updateFcmToken({
                            "deviceId": await getDeviceId(),
                            "fcmToken":
                                await FirebaseMessaging.instance.getToken(),
                            "status": 0
                          });
                          FirebaseAuth.instance.signOut();
                          await FirebaseMessaging.instance.deleteToken();
                        } catch (e) {
                          print(e);
                        }
                        Get.back();
                        Get.offAllNamed("/login");
                      },
                    ),
                  ],
                ),
              )
            ],
          ),

          // const Divider(indent: 28, endIndent: 28),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
          //   child: Text(
          //     'Tổ chức',
          //     style: Theme.of(context).textTheme.titleSmall,
          //   ),
          // ),
          // ...homeController.orgList.map((destination) {
          //   return NavigationDrawerDestination(
          //     label: Wrap(
          //       children: [
          //         Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             SizedBox(
          //               width: 200,
          //               child: Text(destination["name"],
          //                   maxLines: 1,
          //                   overflow: TextOverflow.ellipsis,
          //                   style: const TextStyle(
          //                       fontSize: 16, color: Color(0xFF44474F))),
          //             ),
          //             Text(
          //                 destination["subscription"] == "PERSONAL"
          //                     ? "Cá nhân"
          //                     : "Doanh nghiệp",
          //                 style: TextStyle(
          //                     fontSize: 11,
          //                     color: Colors.black.withOpacity(0.3))),
          //           ],
          //         ),
          //       ],
          //     ),
          //     icon: destination["avatar"] == null
          //         ? createCircleAvatar(name: destination["name"], radius: 20)
          //         : CircleAvatar(
          //             backgroundImage: getAvatarProvider(destination["avatar"]),
          //             radius: 20),
          //   );
          // }),
        ],
      );
    });
  }
}
