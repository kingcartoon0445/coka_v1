import 'dart:async';

import 'package:coka/api/user.dart';
import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/elevated_btn.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/authentication/register_screen/org_page.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/home/pages/accept_request_page.dart';
import 'package:coka/screen/home/pages/join_org_page.dart';
import 'package:coka/screen/main/main_controller.dart';
import 'package:coka/screen/main/pages/coka_info.dart';
import 'package:coka/screen/workspace/components/customer_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'detail_member.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  final mainController = Get.put(MainController());
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (controller) {
      final moreItemList = [
        [
          // {
          //   "name": "Quản lý tổ chức",
          //   "id": "org_manage",
          //   "icon": const Icon(Icons.lan_outlined),
          // },
          {
            "name": "Tạo tổ chức",
            "id": "org_create",
            "icon": const Icon(
              Icons.add,
              color: Color(0xFF554FE8),
            )
          },
          {
            "name": "Tham gia tổ chức",
            "id": "org_join",
            "icon": const Icon(
              Icons.group_add_outlined,
              color: Color(0xFF554FE8),
            )
          },
          {
            "name": "Lời mời",
            "id": "org_invite",
            "icon":
                const Icon(Icons.person_add_outlined, color: Color(0xFF554FE8))
          }
        ],
        [
          {
            "name": "Giới thiệu về Coka",
            "id": "coka_info",
            "icon": const Icon(Icons.error_outline, color: Color(0xFF554FE8))
          },
          {
            "name": "Chỉnh sửa tài khoản",
            "id": "account_setting",
            "icon":
                const Icon(Icons.settings_outlined, color: Color(0xFF554FE8))
          },
          // {
          //   "name": "Nâng cấp tài khoản",
          //   "id": "account_upgrade",
          //   "icon": const Icon(Icons.workspace_premium, color: Color(0xFF554FE8))
          // },
          if (homeController.isUpdateAble.value)
            {
              "name": "Cập nhật phiên bản mới",
              "id": "update",
              "icon": const Icon(Icons.update, color: Color(0xFF554FE8))
            }
        ],
        // [
        //   {
        //     "name": "Liên hệ hỗ trợ",
        //     "id": "support",
        //     "icon": const Icon(Icons.headset_mic_outlined, color: Color(0xFF554FE8))
        //   },
        //   {
        //     "name": "Điều khoản điều kiện",
        //     "id": "terms",
        //     "icon": const Icon(Icons.verified_user_outlined, color: Color(0xFF554FE8))
        //   },
        //   {
        //     "name": "Chính sách bảo mật",
        //     "id": "privacy",
        //     "icon": const Icon(Icons.security_outlined, color: Color(0xFF554FE8))
        //   },
        // ],
        [
          {
            "name": "Đăng xuất",
            "id": "logout",
            "icon": const Icon(Icons.logout, color: Color(0xFF554FE8))
          },
          {
            "name": "Xóa tài khoản",
            "id": "delete",
            "icon": const Icon(Icons.delete_outline, color: Color(0xFF554FE8))
          },
        ],
      ];
      Container buildMoreCard(Map<String, Object> e1) {
        return Container(
          decoration: const BoxDecoration(color: Colors.white),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                padding: const EdgeInsets.all(4),
                child: e1["icon"] as Widget,
              ),
              const SizedBox(
                width: 5,
              ),
              if (e1["id"] == "update")
                Row(
                  children: [
                    Text(
                      e1["name"].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Container(
                      constraints: const BoxConstraints(minWidth: 25),
                      height: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                          color: const Color(0xFFD90001),
                          borderRadius: BorderRadius.circular(100)),
                      child: Center(
                        child: Text(
                          "v${homeController.newVersion.value}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11),
                        ),
                      ),
                    )
                  ],
                ),
              if (e1["id"] != "update")
                Text(
                  e1["name"].toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: e1["id"] == "delete" ? Colors.red : Colors.black),
                ),
              const Spacer(),
              if (e1["id"] != "update" &&
                  e1["id"] != "logout" &&
                  e1["id"] != "delete")
                const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFAF8FD),
          title: const Text(
            "Mở rộng",
            style: TextStyle(
                color: Color(0xFF1F2329),
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildProfileMenu(controller),
              ...moreItemList.map((e0) {
                return Column(
                  children: [
                    ...e0.map((e1) {
                      return Column(
                        children: [
                          ElevatedBtn(
                              onPressed: () async {
                                switch (e1["id"]) {
                                  case "org_create":
                                    Get.to(() => const RegisterOrgPage(
                                        isPersonal: false));
                                    break;
                                  case "org_join":
                                    Get.to(() => const JoinOrgPage());
                                    break;

                                  case "org_invite":
                                    Get.to(() => const AcceptRequestPage());

                                    break;

                                  case "coka_info":
                                    Get.to(() => const CokaInfo());

                                    break;
                                  case "update":
                                    InAppReview.instance.openStoreListing(
                                      appStoreId: "6447948044",
                                    );

                                    break;
                                  case "account_setting":
                                    Get.toNamed("/updateProfile");
                                    break;

                                  case "account_upgrade":
                                    break;

                                  case "support":
                                    break;

                                  case "terms":
                                    break;

                                  case "privacy":
                                    break;
                                  case "delete":
                                    warningAlert(
                                        title: "Xóa tài khoản",
                                        desc:
                                            "Thao tác này sẽ xóa tài khoản khỏi hệ thống. Bạn có chắc muốn xóa tài khoản?",
                                        btnOkOnPress: () async {
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          prefs.clear();
                                          Future.delayed(
                                              const Duration(milliseconds: 50),
                                              () => showLoadingDialog(
                                                  Get.context!));
                                          try {
                                            UserApi().updateFcmToken({
                                              "deviceId": await getDeviceId(),
                                              "version": await getVersion(),
                                              "fcmToken":
                                                  await FirebaseMessaging
                                                      .instance
                                                      .getToken(),
                                              "status": 0
                                            });
                                            FirebaseAuth.instance.signOut();
                                            await FirebaseMessaging.instance
                                                .deleteToken();
                                          } catch (e) {
                                            print(e);
                                          }
                                          Get.back();
                                          Get.offAllNamed("/login");
                                        });

                                    break;
                                  case "logout":
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.clear();
                                    Future.delayed(
                                        const Duration(milliseconds: 50),
                                        () => showLoadingDialog(Get.context!));
                                    try {
                                      UserApi().updateFcmToken({
                                        "deviceId": await getDeviceId(),
                                        "fcmToken": await FirebaseMessaging
                                            .instance
                                            .getToken(),
                                        "status": 0
                                      });
                                      FirebaseAuth.instance.signOut();
                                      await FirebaseMessaging.instance
                                          .deleteToken();
                                    } catch (e) {
                                      print(e);
                                    }
                                    Get.back();
                                    Get.offAllNamed("/login");
                                    break;
                                }
                              },
                              paddingAllValue: 0,
                              circular: 0,
                              child: buildMoreCard(e1)),
                          if (e1 != e0.last)
                            const Divider(
                              height: 1,
                              color: Colors.transparent,
                            )
                        ],
                      );
                    }),
                    const SizedBox(
                      height: 20,
                    )
                  ],
                );
              }),
              Center(
                child: Text(
                    "v${controller.currentVersion.value}(${controller.buildNumber.value})",
                    style: const TextStyle(
                        color: Color(0xFF646A72),
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      );
    });
  }

  Column buildProfileMenu(HomeController controller) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        InkWell(
          onTap: () {
            Get.to(() => DetailMember(
                  dataItem: controller.userData,
                  isMyProfile: true,
                ));
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                controller.userData["avatar"] == "" ||
                        controller.userData["avatar"] == null
                    ? createCircleAvatar(
                        name: controller.userData["fullName"] ?? ".",
                        radius: 22)
                    : CircleAvatar(
                        backgroundImage:
                            getAvatarProvider(controller.userData["avatar"]),
                        radius: 22,
                      ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.userData["fullName"] ?? "",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF44474F)),
                    ),
                    const Text(
                      "Xem profile của bạn",
                      style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF44474F),
                          decoration: TextDecoration.underline),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
