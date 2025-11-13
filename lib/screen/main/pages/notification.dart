import 'dart:convert';

import 'package:coka/api/notification.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/elevated_btn.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/components/placeholders.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/home/pages/accept_request_page.dart';
import 'package:coka/screen/main/getx/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../home/pages/accept_invite_page.dart';
import '../../workspace/pages/chat_room.dart';

final notifyMenuList = [
  {
    "id": "setAllRead",
    "icon": const Icon(Icons.check_rounded),
    "name": "Đánh dấu tất cả là đã đọc",
    "onPress": (controller) {
      NotificationApi().updateAllRead().then((value) {
        controller.onRefresh();
      });
    }
  },
];

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFAF8FD),
          title: const Text(
            "Thông báo",
            style: TextStyle(
                color: Color(0xFF1F2329),
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            MenuAnchor(
              alignmentOffset: const Offset(-225, 0),
              menuChildren: [
                ...notifyMenuList.map((e) {
                  return MenuItemButton(
                    leadingIcon: e["icon"] as Widget,
                    onPressed: () {
                      (e["onPress"] as Function)(controller);
                    },
                    child: Text(
                      e["name"] as String,
                    ),
                  );
                })
              ],
              builder: (context, controller, child) {
                return ElevatedBtn(
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  circular: 50,
                  paddingAllValue: 4,
                  child: const Icon(
                    Icons.more_vert,
                    size: 30,
                  ),
                );
              },
            )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () {
            return controller.onRefresh();
          },
          child: controller.isFetching.value && !controller.isLoadingMore.value
              ? const ListPlaceholder(length: 10)
              : ConstrainedBox(
                  constraints: BoxConstraints(minHeight: Get.height - 120),
                  child: ListView.builder(
                      controller: controller.sc,
                      itemBuilder: (context, index) {
                        final dataNotify = controller.notifyList[index];
                        String snipTime =
                            diffFunc(DateTime.parse(dataNotify['createdDate']));
                        String title =
                            dataNotify["contentHtml"] ?? dataNotify["content"];
                        // String subtitle = dataNotify["content"];
                        bool isRead = dataNotify["status"] == 0 ? true : false;
                        String category = dataNotify["category"];
                        Widget avatar = Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(0x663949AB), width: 1),
                              color: Colors.white),
                          child: dataNotify["avatar"] == null
                              ? const CircleAvatar(
                                  radius: 25,
                                  backgroundImage:
                                      AssetImage("assets/images/icon_app.png"),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: getAvatarWidget(dataNotify["avatar"]),
                                ),
                        );
                        return Column(
                          children: [
                            ListTile(
                              tileColor:
                                  isRead ? null : const Color(0xFFE4EEFE),
                              onTap: () async {
                                try {
                                  final homeController =
                                      Get.put(HomeController());
                                  final prefs =
                                      await SharedPreferences.getInstance();

                                  if (!isRead) {
                                    NotificationApi()
                                        .updateRead(dataNotify["id"])
                                        .then((res) {
                                      if (isSuccessStatus(res["code"])) {
                                        dataNotify["status"] = 0;
                                        controller.readCount.value--;
                                        controller.update();
                                      } else {
                                        errorAlert(
                                            title: "Lỗi", desc: res["message"]);
                                      }
                                    });
                                  }
                                  if (category == "ADD_USER_TEAM") {
                                    await changeWorkspace(
                                        homeController, dataNotify, prefs);
                                    Get.toNamed('/workspaceMain');
                                  } else if (category ==
                                      "REQUEST_ORGANIZATION") {
                                    await changeWorkspace(
                                        homeController, dataNotify, prefs);
                                    Get.to(() => const AcceptInvitePage());
                                  } else if (category == "INVITE_MEMBER") {
                                    Get.to(() => const AcceptRequestPage());
                                  } else if (category == "NEW_CONVERSATION") {
                                    final context = Get.context;
                                    // if (context != null)
                                    //   showLoadingDialog(Get.context!);
                                    homeController.navDrawerIndex.value =
                                        (homeController.orgList.indexWhere(
                                      (e) =>
                                          e["id"] ==
                                          (dataNotify?["organizationId"] ??
                                              dataNotify?["OrganizationId"]),
                                    ));
                                    prefs.setString(
                                        'oData',
                                        jsonEncode(homeController.orgList[
                                            homeController
                                                .navDrawerIndex.value]));
                                    homeController.update();
                                    final channelData =
                                        (jsonDecode(dataNotify?["json"]));

                                    if (channelData != null) {
                                      Get.to(
                                        () => ChatRoomPage(
                                            pageName: channelData["PageName"],
                                            pageAvatar:
                                                channelData["PageAvatar"],
                                            pageId: channelData[
                                                "IntegrationAuthId"],
                                            provider: channelData["Provider"] ??
                                                "FACEBOOK"),
                                      );
                                    }
                                    await homeController.onRefresh();
                                  } else if (category ==
                                      "EXPIRED_ACCESSTOKEN_FACEBOOK") {
                                    await changeWorkspace(
                                        homeController, dataNotify, prefs);
                                    Get.toNamed('/workspaceMain');
                                  } else if (category == "ADD_USER_WORKSPACE") {
                                    await changeWorkspace(
                                        homeController, dataNotify, prefs);
                                    Get.toNamed('/workspaceMain');
                                  } else if (category == "ADD_USER_WORKSPACE") {
                                    await changeWorkspace(
                                        homeController, dataNotify, prefs);
                                    Get.toNamed('/workspaceMain');
                                  } else if (category == "ASSIGN_CONTACT") {
                                    await changeWorkspace(
                                        homeController, dataNotify, prefs);
                                    Get.toNamed('/workspaceMain',
                                        arguments: {"defaultIndex": 1});
                                  } else if (category == "ADD_USER_TEAM") {
                                    await changeWorkspace(
                                        homeController, dataNotify, prefs);
                                    Get.toNamed('/workspaceMain',
                                        arguments: {"defaultIndex": 3});
                                  } else if (category == "ADD_TEAM_MANAGER") {
                                    await changeWorkspace(
                                        homeController, dataNotify, prefs);
                                    Get.toNamed('/workspaceMain',
                                        arguments: {"defaultIndex": 3});
                                  } else if (category ==
                                      "GRANT_ROLE_USER_TEAM") {
                                    await changeWorkspace(
                                        homeController, dataNotify, prefs);
                                    Get.toNamed('/workspaceMain',
                                        arguments: {"defaultIndex": 3});
                                  } else if (category ==
                                      "GRANT_ROLE_WORKSPACE") {
                                    await changeWorkspace(
                                        homeController, dataNotify, prefs);
                                    Get.toNamed('/workspaceMain');
                                  } else if (category == "NEW_CONTACT") {
                                    await changeWorkspace(
                                        homeController, dataNotify, prefs);
                                    Get.toNamed('/workspaceMain',
                                        arguments: {"defaultIndex": 1});
                                  }
                                } catch (e) {
                                  print(e);
                                  Get.back();
                                }
                              },
                              leading: avatar,
                              title: Html(data: title, style: {
                                "body": Style(
                                    margin: Margins.all(0),
                                    maxLines: 4,
                                    textOverflow: TextOverflow.ellipsis,
                                    fontSize: FontSize.medium,
                                    lineHeight: LineHeight.number(1.2))
                              }),
                              subtitle: Text(snipTime,
                                  style: const TextStyle(height: 1.5)),
                            ),
                            if (controller.isLoadingMore.value &&
                                index == controller.notifyList.length - 1)
                              const CircularProgressIndicator()
                          ],
                        );
                      },
                      shrinkWrap: true,
                      itemCount: controller.notifyList.length),
                ),
        ),
      );
    });
  }
}

Future changeWorkspace(
    HomeController homeController, dataNotify, SharedPreferences prefs) async {
  final context = Get.context;
  if (context != null) showLoadingDialog(Get.context!);
  homeController.navDrawerIndex.value = (homeController.orgList.indexWhere(
    (e) =>
        e["id"] ==
        (dataNotify?["organizationId"] ?? dataNotify?["OrganizationId"]),
  ));
  prefs.setString('oData',
      jsonEncode(homeController.orgList[homeController.navDrawerIndex.value]));
  homeController.update();
  await homeController.onRefresh();
  print(homeController.workGroupCardDataList);

  if (dataNotify["workspaceId"] != null || dataNotify["WorkspaceId"] != null) {
    print("change");
    homeController.workGroupCardDataValue.value =
        homeController.workGroupCardDataList.firstWhere((p0) =>
            p0["id"] ==
            (dataNotify["workspaceId"] ?? dataNotify?["WorkspaceId"]));
    homeController.update();
  }
  if (context != null) Get.back();
}
