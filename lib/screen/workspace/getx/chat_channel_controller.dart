import 'dart:async';
import 'dart:convert';

import 'package:coka/api/lead.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class ChatChannelController extends GetxController {
  final homeController = Get.put(HomeController());
  final isChannelEmpty = false.obs;
  final channelList = [].obs;
  final isChannelFetching = false.obs;
  StreamSubscription<DatabaseEvent>? onChangedListener;
  bool _hasReceivedInitialRealtimeEvent = false;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    onRefresh();
    // setupFirebaseListener();
  }

  @override
  void onClose() {
    onChangedListener?.cancel();
    super.onClose();
  }

  Future onRefresh() async {
    isChannelFetching.value = true;
    isChannelEmpty.value = false;
    channelList.clear();
    update();
    await Future.wait([fetchChannelList()]);
    isChannelFetching.value = false;
    update();
  }

  Future fetchChannelList() async {
    await LeadApi().getFbMessageList(subscribed: "messages").then((res) {
      if (isSuccessStatus(res["code"])) {
        channelList.value = res["content"];
        if (channelList.isEmpty) {
          isChannelEmpty.value = true;
        } else {
          isChannelEmpty.value = false;
        }
      } else {
        if (res["message"].contains("không có quyền")) {
          Get.back();
        }
        errorAlert(title: "Lỗi", desc: res["message"]);
      }
    });
  }

  // void setupFirebaseListener() {
  //   getOData().then((value) {
  //     if (value == null || value.toString().isEmpty) return;

  //     final oId = jsonDecode(value)["id"];
  //     if (!isValidId(oId)) return;

  //     final syncRef =
  //         FirebaseDatabase.instance.ref('root/OrganizationId: $oId');
  //     onChangedListener?.cancel();
  //     onChangedListener = syncRef.onValue.listen((event) async {
  //       if (!_hasReceivedInitialRealtimeEvent) {
  //         _hasReceivedInitialRealtimeEvent = true;
  //         return;
  //       }

  //       await onRefresh();
  //     });
  //   });
  // }
}
