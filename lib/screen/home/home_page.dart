import 'dart:convert';
import 'dart:io';

import 'package:coka/api/organization.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/authentication/register_screen/org_page.dart';
import 'package:coka/screen/home/components/drawer.dart';
import 'package:coka/screen/home/components/header_card.dart';
import 'package:coka/screen/home/components/member_card.dart';
import 'package:coka/screen/home/components/workspace_card.dart';

import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/home/pages/accept_invite_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:upgrader/upgrader.dart';

import '../../components/auto_avatar.dart';
import '../../components/update_alert.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> key = GlobalKey();
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state.name == "resumed") {
      HomeController homeController = Get.put(HomeController());
      if (Platform.isIOS) {
        final iTunes = ITunesSearchAPI();
        final resultsFuture = iTunes.lookupById('6447948044', country: "VN");
        resultsFuture.then((results) {
          homeController.newVersion.value = results?["results"][0]["version"];
          homeController.isUpdateAble.value = isVersionOlder(
              homeController.currentVersion.value,
              homeController.newVersion.value);
          if (homeController.isUpdateAble.value) {
            Get.dialog(const UpdateAlert());
          }

          homeController.update();
        });
      } else if (Platform.isAndroid) {
        final playStore = PlayStoreSearchAPI();
        final resultsFuture = playStore.lookupById('com.azvidi.coka');
        resultsFuture.then((results) {
          homeController.newVersion.value = playStore.version(results!) ?? "";
          homeController.isUpdateAble.value = isVersionOlder(
              homeController.currentVersion.value,
              homeController.newVersion.value);
          if (homeController.isUpdateAble.value) {
            Get.dialog(const UpdateAlert());
          }
          homeController.update();
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (controller) {
      Map dropdownItems = {
        if (controller.oData["type"] == "OWNER" ||
            controller.oData["type"] == "ADMIN")
          'Chỉnh sửa tổ chức':
              const Icon(Icons.account_tree_outlined, color: Colors.black),
        if (controller.oData["type"] == "OWNER" ||
            controller.oData["type"] == "ADMIN")
          'Yêu cầu tham gia':
              const Icon(Icons.person_add_outlined, color: Colors.black),
        if (controller.oData["type"] != "OWNER" &&
            controller.oData["type"] != "ADMIN")
          'Rời tổ chức': const Icon(Icons.output, color: Colors.black),
        if (controller.oData["type"] == "OWNER" ||
            controller.oData["type"] == "ADMIN")
          'Xóa tổ chức': const Icon(Icons.delete_outline, color: Colors.black),
      };
      return Scaffold(
          key: key,
          drawer: HomeDrawer(
              onCloseDrawer: () => {key.currentState!.closeDrawer()}),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: SizedBox(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        controller.userData["fullName"] == "" ||
                                controller.userData["fullName"] == null
                            ? Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                enabled: true,
                                child: const CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.white,
                                ))
                            : InkWell(
                                onTap: () {
                                  key.currentState!.openDrawer();
                                },
                                child: controller.userData["avatar"] == null
                                    ? createCircleAvatar(
                                        name: controller.userData["fullName"],
                                        radius: 20)
                                    : Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: const Color(0x663949AB),
                                                width: 1),
                                            color: Colors.white),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: getAvatarWidget(
                                              controller.userData["avatar"]),
                                        ),
                                      ),
                              ),
                        const SizedBox(
                          width: 15,
                        ),
                        Text(
                          controller.userData["fullName"] ?? "Chào mừng bạn",
                          style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        MenuAnchor(
                            alignmentOffset: Offset(
                                controller.oData["type"] != "OWNER" &&
                                        controller.oData["type"] != "ADMIN"
                                    ? -120
                                    : -168,
                                0),
                            builder: (context, controller, child) {
                              return InkWell(
                                onTap: () {
                                  if (controller.isOpen) {
                                    controller.close();
                                  } else {
                                    controller.open();
                                  }
                                },
                                child: const Icon(
                                  Icons.more_vert,
                                  size: 24,
                                ),
                              );
                            },
                            menuChildren: dropdownItems.entries.map((item) {
                              return controller
                                          .workGroupCardDataList.isNotEmpty &&
                                      controller.memberList.isNotEmpty &&
                                      item.key == "Xóa tổ chức"
                                  ? Container()
                                  : MenuItemButton(
                                      leadingIcon: item.value,
                                      onPressed: () {
                                        if (item.key == "Yêu cầu tham gia") {
                                          Get.to(
                                              () => const AcceptInvitePage());
                                        } else if (item.key ==
                                            "Chỉnh sửa tổ chức") {
                                          Get.to(() => const RegisterOrgPage(
                                                isPersonal: false,
                                                isEdit: true,
                                              ));
                                        } else if (item.key == "Xóa tổ chức") {
                                          warningAlert(
                                              title: "Xoá tổ chức ?",
                                              desc:
                                                  "Bạn có chắc rẳng muốn xoá tổ chức này?",
                                              btnOkOnPress: () {
                                                showLoadingDialog(context);
                                                OrganApi()
                                                    .deleteOrgan()
                                                    .then((res) async {
                                                  Get.back();
                                                  if (isSuccessStatus(
                                                      res["code"])) {
                                                    final prefs =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    controller.navDrawerIndex
                                                        .value = controller
                                                                .navDrawerIndex
                                                                .value ==
                                                            0
                                                        ? 1
                                                        : 0;
                                                    prefs.setString(
                                                        'oData',
                                                        jsonEncode(controller
                                                                .orgList[
                                                            controller
                                                                .navDrawerIndex
                                                                .value]));
                                                    controller.update();
                                                    controller.onRefresh();
                                                  } else {
                                                    errorAlert(
                                                        title: "Thất bại",
                                                        desc: res["message"]);
                                                  }
                                                });
                                              });
                                        } else if (item.key == "Rời tổ chức") {
                                          warningAlert(
                                              title: "Rời tổ chức ?",
                                              desc:
                                                  "Bạn có chắc rẳng muốn rời tổ chức này?",
                                              btnOkOnPress: () {
                                                showLoadingDialog(context);
                                                OrganApi()
                                                    .leaveOrgan()
                                                    .then((res) async {
                                                  Get.back();
                                                  if (isSuccessStatus(
                                                      res["code"])) {
                                                    final prefs =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    controller.navDrawerIndex
                                                        .value = controller
                                                                .navDrawerIndex
                                                                .value ==
                                                            0
                                                        ? 1
                                                        : 0;
                                                    prefs.setString(
                                                        'oData',
                                                        jsonEncode(controller
                                                                .orgList[
                                                            controller
                                                                .navDrawerIndex
                                                                .value]));
                                                    controller.update();
                                                    controller.onRefresh();
                                                  } else {
                                                    errorAlert(
                                                        title: "Thất bại",
                                                        desc: res["message"]);
                                                  }
                                                });
                                              });
                                        }
                                      },
                                      child: Text(
                                        item.key,
                                        style: TextStyle(
                                            color: item.key == "Xóa tổ chức"
                                                ? const Color(0xFFB3261E)
                                                : Colors.black),
                                      ),
                                    );
                            }).toList())
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      controller.onRefresh();
                    },
                    child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 14,
                            ),
                            HeaderCard(data: controller.oData),
                            const SizedBox(
                              height: 25,
                            ),
                            const WorkspaceCard(),
                            const SizedBox(
                              height: 25,
                            ),
                            const MemberCard(),
                            const SizedBox(
                              height: 30,
                            ),
                          ],
                        )),
                  ),
                ),
              ],
            ),
          ));
    });
  }
}
