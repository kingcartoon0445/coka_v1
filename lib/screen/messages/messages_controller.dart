import 'dart:async';
import 'dart:convert';

import 'package:coka/api/conversation.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessagesController extends GetxController {
  final selectedTab = 0.obs;
  final isRoomFetching = false.obs;
  final isRoomLoadMore = false.obs;
  final isRoomEmpty = false.obs;
  final roomList = [].obs;
  final offset = 0.obs;
  final ScrollController sc = ScrollController();
  final searchText = TextEditingController();
  Timer? _debounce;
  StreamSubscription? onChangedListener;

  @override
  void onInit() {
    super.onInit();
    onRefresh();
    setupScrollListener();
    setupFirebaseListener();
  }

  @override
  void onClose() {
    onChangedListener?.cancel();
    super.onClose();
  }

  void setupScrollListener() {
    sc.addListener(() async {
      if (sc.position.pixels == sc.position.maxScrollExtent) {
        if (!isRoomFetching.value) {
          offset.value += 20;
          isRoomLoadMore.value = true;
          await fetchRoomList("");
          isRoomLoadMore.value = false;
        }
      }
    });
  }

  void setupFirebaseListener() {
    getOData().then((value) {
      final oId = jsonDecode(value)["id"];
      DatabaseReference syncRef = FirebaseDatabase.instance.ref('root/OrganizationId: $oId');
      onChangedListener = syncRef.onChildChanged.listen((event) async {
        DataSnapshot snapshot = event.snapshot;
        Map data = ((snapshot.value ?? {}) as Map).values.first;
        try {
          var roomData = roomList.firstWhere((e) => e["id"] == data["ConversationId"]);
          roomData["snippet"] = data["Message"];
          roomData["updatedTime"] = DateTime.now().millisecondsSinceEpoch;
          roomData["isRead"] = false;
          roomList.refresh();
        } catch (e) {
          roomList.clear();
          offset.value = 0;
          await fetchRoomList("");
        }
      });
    });
  }

  Future onRefresh() async {
    roomList.clear();
    isRoomFetching.value = true;
    offset.value = 0;
    await fetchRoomList("");
    isRoomFetching.value = false;
  }

  Future fetchRoomList(String searchText) async {
    await ConvApi().getRoomList(null, null, offset.value, searchText: searchText).then((res) {
      if (isSuccessStatus(res["code"])) {
        roomList.addAll(res["content"]);
        isRoomEmpty.value = roomList.isEmpty;
      } else {
        errorAlert(title: "Lỗi", desc: res["message"]);
      }
    });
  }

  void onDebounce(Function(String) searchFunction, int debounceTime) {
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: debounceTime), () async {
      offset.value = 0;
      roomList.clear();
      isRoomFetching.value = true;
      await searchFunction(searchText.text);
      isRoomFetching.value = false;
    });
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }
}
