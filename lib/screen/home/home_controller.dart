import 'dart:convert';
import 'dart:io';

import 'package:coka/api/auth.dart';
import 'package:coka/api/callcenter.dart';
import 'package:coka/api/conversation.dart';
import 'package:coka/api/organization.dart';
import 'package:coka/api/workspace.dart';
import 'package:coka/components/update_alert.dart';
import 'package:coka/constants.dart';
import 'package:coka/main.dart';
import 'package:coka/screen/main/getx/notification_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

import '../../api/api_url.dart';
import '../../api/user.dart';
import '../../components/awesome_alert.dart';
import '../authentication/register_screen/profile_page.dart';

class HomeController extends GetxController {
  final oData = {}.obs;
  final orgList = [].obs;
  final memberList = [].obs;
  final isMemberFetching = false.obs;
  final isWorkspaceFetching = false.obs;
  final workGroupCardDataList = <Map>[].obs;
  final workGroupCardDataValue = {}.obs;
  final userData = {}.obs;
  final navDrawerIndex = 0.obs;
  final currentVersion = "".obs;
  final newVersion = "".obs;
  final buildNumber = "".obs;
  final isDevMode = true.obs;
  ScrollController sc = ScrollController();
  final isCallAble = false.obs;
  final callData = {}.obs;
  final isUpdateAble = false.obs;
  final badgeList = [].obs;

  Future<void> checkCallAble() async {
    try {
      final res = await CallCenterApi().getSetting();
      final data = res["content"];
      if (data.isNotEmpty) {
        isCallAble.value = true;
        callData.value = data[0];
      } else {
        isCallAble.value = false;
      }
    } catch (e) {
      isCallAble.value = false;
    }
  }

  Future fetchConvUnread() async {
    try {
      final res = await ConvApi().getConvUnread();
      if (isSuccessStatus(res['code'])) {
        badgeList.value = res['content'];
        update();
      } else {
        print(res["message"]);
      }
    } catch (e) {}
  }

  Future<void> _showNotification(message) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('coka_notification', 'coka_notification',
            channelDescription: 'Check',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            sound: RawResourceAndroidNotificationSound("notify"));
    NotificationDetails notificationDetails =
        const NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        id++, message['title'], message['body'], notificationDetails,
        payload: jsonEncode(message));
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    sc.addListener(() {
      print(sc.position.pixels);
      if (sc.position.pixels >= sc.position.maxScrollExtent) {}
    });
    getVersion();
    checkUpdate(true);
    onRefresh();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      try {
        print("========== Notify ==========");

        print(message.data);
        final notifyController = Get.put(NotificationController());
        _showNotification(message.data);
        fetchConvUnread();
        notifyController.onRefresh();
      } catch (e) {
        print(e);
      }
    });
  }

  Future checkUpdate(bool isShowPopup) async {
    try {
      if (Platform.isIOS) {
        final iTunes = ITunesSearchAPI();
        final resultsFuture = iTunes.lookupById('6447948044', country: "VN");
        resultsFuture.then((results) {
          newVersion.value = results?["results"][0]["version"];
          isUpdateAble.value =
              isVersionOlder(currentVersion.value, newVersion.value);
          if (isUpdateAble.value && isShowPopup) {
            Get.dialog(const UpdateAlert());
          }

          update();
        });
      } else if (Platform.isAndroid) {
        final playStore = PlayStoreSearchAPI();
        final resultsFuture = playStore.lookupById('com.azvidi.coka');
        resultsFuture.then((results) {
          newVersion.value = playStore.version(results!) ?? "";
          isUpdateAble.value =
              isVersionOlder(currentVersion.value, newVersion.value);
          if (isUpdateAble.value && isShowPopup) {
            Get.dialog(const UpdateAlert());
          }
          update();
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    currentVersion.value = packageInfo.version;
    buildNumber.value = packageInfo.buildNumber;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("version", currentVersion.value);
    update();
  }

  Future<void> onRefresh({bool? isInside}) async {
    isMemberFetching.value = true;
    isWorkspaceFetching.value = true;
    update();
    await Future.wait([
      fetchOrganDetail(),
      fetchMemberList(),
      fetchOrganList(),
      fetchConvUnread(),
      fetchUserData(),
      fetchWorkspaceList(""),
      checkCallAble(),
      checkUpdate(false)
    ]);
    if (workGroupCardDataValue != {} && (isInside ?? false)) {
      workGroupCardDataValue.value = workGroupCardDataList.firstWhere(
          (element) => element["id"] == workGroupCardDataValue["id"]);
    }
    update();
  }

  Future getOrgData() async {
    final data = await getOData();
    oData.value = jsonDecode(data);
    update();
  }

  Future fetchWorkspaceList(searchText) async {
    try {
      await WorkspaceApi().getWorkspaceList(searchText).then((res) {
        if (isSuccessStatus(res['code'])) {
          workGroupCardDataList.value = res['content'].cast<Map>();
          isWorkspaceFetching.value = false;
        } else {
          isWorkspaceFetching.value = false;
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future fetchUserData() async {
    try {
      await UserApi().getProfile().then((res) {
        userData.value = res["content"];
        if (isValidId(userData["id"]) && isDevMode.value == true) {
          apiBaseUrl = "https://dev.coka.ai";
        }
        if (userData["fullName"] == userData["email"] ||
            userData["fullName"] == userData["phone"]) {
          return Get.off(() => const RegisterProfilePage(
                isUpdateProfile: false,
              ));
        }
      });
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final String? refreshToken = prefs.getString("refreshToken");
      try {
        await AuthApi().refreshToken(refreshToken).then((res) async {
          if (isSuccessStatus(res["code"])) {
            prefs.setString("refreshToken", res["content"]["refreshToken"]);
            prefs.setString("accessToken", res["content"]["accessToken"]);
            await UserApi().getProfile().then((res) {
              userData.value = res["content"];
            });
            onRefresh();
          } else if (res?["message"]?.contains("accessToken") ||
              res?["message"]?.contains("Refresh Token") ||
              res?["message"]?.contains("refreshToken") ||
              res?["message"]?.contains("RefreshToken")) {
            prefs.clear();
            UserApi().updateFcmToken({
              "deviceId": await getDeviceId(),
              "version": await getVersion(),
              "fcmToken": await FirebaseMessaging.instance.getToken(),
              "status": 0
            });
            await FirebaseMessaging.instance.deleteToken();
            Get.back();
            Get.offAllNamed("/login");
          }
        });
      } catch (e) {
        // prefs.clear();
        // UserApi().updateFcmToken({
        //   "deviceId": await getDeviceId(),
        //   "fcmToken": await FirebaseMessaging.instance.getToken(),
        //   "status": 0
        // });
        // await FirebaseMessaging.instance.deleteToken();
        Get.back();
        // Get.offAllNamed("/login");
      }
    }
  }

  Future fetchOrganDetail() async {
    try {
      oData.clear();
      await OrganApi().getOrgan().then((res) async {
        if (isSuccessStatus(res['code'])) {
          oData.value = res['content'];
          final prefs = await SharedPreferences.getInstance();
          prefs.setString("oData", jsonEncode(oData));
        } else {
          final homeController = Get.put(HomeController());

          final prefs = await SharedPreferences.getInstance();
          homeController.navDrawerIndex.value =
              homeController.navDrawerIndex.value == 0 ? 1 : 0;
          prefs.setString(
              'oData',
              jsonEncode(
                  homeController.orgList[homeController.navDrawerIndex.value]));
          homeController.update();
          homeController.onRefresh();
          errorAlert(title: 'Lỗi', desc: res['message']);
        }
      });
    } catch (e) {}
  }

  Future fetchOrganList() async {
    try {
      await OrganApi().getListOrgan().then((res) async {
        if (isSuccessStatus(res['code'])) {
          orgList.value = res['content'];
        } else {
          errorAlert(title: 'Lỗi', desc: res['message']);
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future fetchMemberList() async {
    try {
      await OrganApi().getOrganMembers("", 0).then((res) {
        if (isSuccessStatus(res['code'])) {
          memberList.value = res['content'];
          isMemberFetching.value = false;
        } else {
          isMemberFetching.value = false;
          errorAlert(title: 'Lỗi', desc: res['message']);
        }
      });
    } catch (e) {}
  }
}
