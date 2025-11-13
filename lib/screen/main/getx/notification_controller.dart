import 'dart:async';

import 'package:coka/api/notification.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  final notifyList = [].obs;
  final readCount = 0.obs;
  final isFetching = false.obs;
  final isLoadingMore = false.obs;

  final sc = ScrollController();
  int offset = 0;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    onRefresh();
    sc.addListener(() {
      if (sc.position.pixels >= sc.position.maxScrollExtent) {
        if (notifyList.isNotEmpty &&
            !isFetching.value &&
            !isLoadingMore.value) {
          isLoadingMore.value = true;

          update();
          fetchNotification().then((value) {
            Timer(const Duration(milliseconds: 100), () {
              isLoadingMore.value = false;
              update();
            });
          });
        }
      }
    });
  }

  Future onRefresh() async {
    isFetching.value = true;
    notifyList.clear();
    offset = 0;
    update();
    await fetchNotification();
    isFetching.value = false;
    update();
  }

  Future fetchNotification() async {
    try {
      await NotificationApi().getNotificationList(offset).then((res) {
        if (isSuccessStatus(res["code"])) {
          offset += 15;
          notifyList.addAll(res["content"]);
          // readCount.value = res["metadata"]["count"];
        } else {
          errorAlert(title: "Lỗi", desc: res["message"]);
        }
      });
      await NotificationApi().getNotificationListUnread(offset).then(( res) {
        if (isSuccessStatus(res["code"])) {
          readCount.value = res["content"];
        }
      });
    } catch (e) {}
  }
}
