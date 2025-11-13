import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';


class MainController extends GetxController {
  final selectedIndex = 0.obs;
  final history = [0].obs;
  bool isLastUpdate = true;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  Future<void> onRefresh() async {
    update();
  }

  Future<bool> onWillPop() async {
    if (history.length > 1) {
      history.removeLast();
      selectedIndex.value = history.last;
      update();
      return false;
    } else {
      return true;
    }
  }

  Future? onTapped(int index) {
    if (index != 3) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFE3DFFF),
        ),
      );
    }
    if (history.length == 3) {
      history.removeAt(1);
      history.add(index);
    } else {
      history.add(index);
    }
    selectedIndex.value = index;
    update();
    // final notifyController = Get.put(NotificationController());
    // if (index == 2) {
    //   notifyController.onRefresh();
    // }
    return null;
  }
}
