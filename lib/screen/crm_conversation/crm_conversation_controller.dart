import 'dart:async';

import 'package:coka/screen/crm_customer/crm_customer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';


class CrmConversationController extends GetxController {
  CrmCustomerController cCController = Get.put(CrmCustomerController());
  final currentPage = 0.obs;
  final PageController pageController = PageController(initialPage: 0);
  final roomInfo = {}.obs;
  final onFocus = false.obs;
  final convList = [].obs;
  final messageContent = {}.obs;
  final formKey = GlobalKey<FormState>();
  final sendMessageState = <int>[].obs;
  late StreamSubscription listening;
  final ScrollController sc = ScrollController();
  final offset = 0.obs;
  final isLoadMore = false.obs;
  final canLoadMore = true.obs;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    roomInfo.value = Get.arguments;
    messageContent.clear();
    sc.addListener(() {
      if (sc.position.pixels == sc.position.maxScrollExtent &&
          canLoadMore.value) {
        offset.value += 15;
        isLoadMore.value = true;
        update();
        // fetchConvList(offset.value);
      }
    });
    // ConvApi().setRead(roomInfo['conversationId']).then((value) {
    //   cCController.roomList[roomInfo['index']]['unreadCount']=0;
    //   cCController.roomList.refresh();
    //   cCController.update();
    // });
    listening = cCController.lastMessage.listen((Map value) {
      addMessage(value);
    });
    // fetchConvList(offset.value);
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    listening.cancel();
  }

  Widget stateWidget(index) {
    if (index == null) {
      return Container();
    } else {
      return sendMessageState[index] == 0
          ? SvgPicture.asset(
              'assets/icons/error_icon.svg',
              width: 16,
              height: 16,
            )
          : sendMessageState[index] == 1
              ? SvgPicture.asset(
                  'assets/icons/check_circle_fill.svg',
                  width: 16,
                  height: 16,
                  color: const Color(0xFF565E6C),
                )
              : SvgPicture.asset(
                  'assets/icons/check_circle.svg',
                  width: 16,
                  height: 16,
                  color: const Color(0xFF565E6C),
                );
    }
  }

  void addMessage(Map data) {
    if (data['ConversationId'] == roomInfo['conversationId']) {
      if (data["From"] == roomInfo["personId"] || data["IsGpt"]) {
        convList.insert(0, {
          "from": data['From'],
          "message": data['Message'],
          "timestamp": data['Timestamp'],
        });
        print({
          "from": data['From'],
          "message": data['Message'],
          "timestamp": data['Timestamp'],
        });
      }
    }

    update();
  }

  // Future fetchConvList(offset) async{
  //   ConvApi().getConvList(roomInfo['hubId'],roomInfo['conversationId'],15,offset).then((res) {
  //     if(isSuccessStatus(res['code'])){
  //       convList.addAll(res['content']);
  //       if(res['content'].length<15){
  //         canLoadMore.value = false;
  //       }
  //       isLoadMore.value = false;
  //       update();
  //     }
  //   });
  // }
}
