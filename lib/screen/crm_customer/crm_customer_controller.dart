import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../main/main_controller.dart';

class CrmCustomerController extends GetxController {
  MainController mainController = Get.put(MainController());
  final currentPage = 0.obs;

  final PageController pageController = PageController(initialPage: 0);
  final isReadList = [
    ['Tất cả', ''],
    ['Form', ''],
    ['Social', ''],
    ['AIDC', ''],
    ['Import', '']
  ].obs;
  final isLoading = false.obs;
  final roomList = [].obs;
  final lastMessage = {}.obs;
  final isSyncing = false.obs;
  final isHubBlank = true.obs;
  final isRoomEmpty = false.obs;
  late StreamSubscription onValueListener;
  late StreamSubscription onChangedListener;
  late StreamSubscription onAddedListener;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    fetchCustomer();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  void onRefresh() {}

  void updateSnippet(data) {
    final index = roomList
        .indexWhere((e) => e['conversationId'] == data['ConversationId']);
    roomList[index].addAll({
      "snippet": data['Message'],
      "unreadCount": ++roomList[index]['unreadCount'],
      "updatedTime": data['Timestamp']
    });
    final tempData = roomList[index];
    roomList.removeAt(index);
    roomList.insert(0, tempData);
    update();
  }

  Future fetchCustomer() async {
    roomList.clear();
    isLoading.value = true;
    update();
    // CustomerApi()
    //     .getCustomerList(mainController.workGroupCardDataValue['id'])
    //     .then((res) {
    //   if (isSuccessStatus(res['code'])) {
    //     roomList.value = res['content'];
    //     updatePersonAvatarList(roomList);
    //     updatePageAvatarList(roomList);
    //     if (res['content'].length == 0) {
    //       isRoomEmpty.value = true;
    //     }
    //     isLoading.value = false;
    //
    //     update();
    //   } else {
    //     isLoading.value = false;
    //     errorAlert(title: 'Lỗi', desc: res['message']);
    //   }
    // });
  }
}
