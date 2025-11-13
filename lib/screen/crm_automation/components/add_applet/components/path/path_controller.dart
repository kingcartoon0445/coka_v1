import 'dart:convert';

import 'package:coka/constants.dart';
import 'package:coka/models/animation_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'components/action_item.dart';

class PathController extends GetxController {
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  late ListModel<int> actionList;
  final currentIndex = 0.obs;
  final actionDataList = [].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    actionDataList.value = jsonDecode(Get.arguments ?? "{}");

    actionList = ListModel<int>(
      listKey: listKey,
      initialItems: generateList(actionDataList.length),
      removedItemBuilder: _buildRemovedItem,
    );
  }

  addOnePath(i1, i2) {
    actionDataList[i1]["pathList"][i2].add({
      "type": "filter",
      "orList": [
        [{}]
      ]
    });
    actionDataList[i1]["pathList"][i2].add({"type": "default"});

    update();
  }

  deleteOneItemPath(i1, i2) {
    actionDataList[i1]["pathList"][i2] = [];
    print("remove $i1 $i2 : ${actionDataList[i1]["pathList"]}");

    update();
  }

  addOneAction(index) {
    actionDataList.insert(index, {"type": "default"});
    print("add $index : $actionDataList");
    update();
  }

  deleteOneAction(index) {
    actionDataList.removeAt(index);
    print("remove $index : $actionDataList");
    update();
  }

  Widget _buildRemovedItem(
      int index, BuildContext context, Animation<double> animation) {
    return ActionItem(animation: animation, index: index + 1);
  }
}
