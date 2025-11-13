import 'dart:async';
import 'dart:convert';

import 'package:coka/screen/main/getx/notification_controller.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screen/home/home_controller.dart';
import 'screen/home/pages/accept_invite_page.dart';
import 'screen/home/pages/accept_request_page.dart';
import 'screen/main/pages/notification.dart';

class Noti {
  @pragma('vm:entry-point')
  static void notificationTapBackground(
      NotificationResponse notificationResponse) {
    try {
      Timer(
        const Duration(seconds: 1),
        () async {
          final notifyData = jsonDecode(notificationResponse.payload ?? "{}");
          final dataNotify = jsonDecode(notifyData["metadata"]);
          print(dataNotify);
          final category = notifyData["category"];
          final homeController = Get.put(HomeController());
          final prefs = await SharedPreferences.getInstance();

          if (category == "ADD_USER_TEAM") {
            await changeWorkspace(homeController, dataNotify, prefs);
            Get.toNamed('/workspaceMain');
          } else if (category == "REQUEST_ORGANIZATION") {
            await changeWorkspace(homeController, dataNotify, prefs);
            Get.to(() => const AcceptInvitePage());
          } else if (category == "INVITE_MEMBER") {
            Get.to(() => const AcceptRequestPage());
          } else if (category == "NEW_CONVERSATION") {
            await changeWorkspace(homeController, dataNotify, prefs);
            Get.toNamed('/workspaceMain');
          } else if (category == "EXPIRED_ACCESSTOKEN_FACEBOOK") {
            await changeWorkspace(homeController, dataNotify, prefs);
            Get.toNamed('/workspaceMain');
          } else if (category == "ADD_USER_WORKSPACE") {
            await changeWorkspace(homeController, dataNotify, prefs);
            Get.toNamed('/workspaceMain');
          } else if (category == "ADD_USER_WORKSPACE") {
            await changeWorkspace(homeController, dataNotify, prefs);
            Get.toNamed('/workspaceMain');
          } else if (category == "ASSIGN_CONTACT") {
            await changeWorkspace(homeController, dataNotify, prefs);
            Get.toNamed('/workspaceMain', arguments: {"defaultIndex": 1});
          } else if (category == "ADD_USER_TEAM") {
            await changeWorkspace(homeController, dataNotify, prefs);
            Get.toNamed('/workspaceMain', arguments: {"defaultIndex": 3});
          } else if (category == "ADD_TEAM_MANAGER") {
            await changeWorkspace(homeController, dataNotify, prefs);
            Get.toNamed('/workspaceMain', arguments: {"defaultIndex": 3});
          } else if (category == "GRANT_ROLE_USER_TEAM") {
            await changeWorkspace(homeController, dataNotify, prefs);
            Get.toNamed('/workspaceMain', arguments: {"defaultIndex": 3});
          } else if (category == "GRANT_ROLE_WORKSPACE") {
            await changeWorkspace(homeController, dataNotify, prefs);
            Get.toNamed('/workspaceMain');
          } else if (category == "NEW_CONTACT") {
            await changeWorkspace(homeController, dataNotify, prefs);
            Get.toNamed('/workspaceMain', arguments: {"defaultIndex": 1});
          }
          final notifyController = Get.put(NotificationController());
          notifyController.onRefresh();
        },
      );
    } catch (e) {
      Get.back();
      print(e);
    }
  }

  static Future initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('launcher_icon');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    InitializationSettings initializationSettings =
        const InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: notificationTapBackground,
    );
  }
}
