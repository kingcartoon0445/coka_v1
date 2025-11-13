import 'package:coka/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../models/animation_list_model.dart';
import 'components/action_item.dart';

final pathDefaultData = {
  "name": "Trường hợp x",
  "id": "path",
  "description": "Chứa n bước"
};
final actionUiData = {
  "default": {
    "name": "Default action",
    "id": "default",
    "iconPath": "assets/icons/action.svg",
    "bgColor": const Color(0xFFF8F8F8),
    "iconColor": Colors.black,
    "iconBg": const Color(0xFFF8F8F8),
    "color": Colors.black,
    "description": "Một hành động sau khi bắt đầu"
  },
  "filter": {
    "type": "filter",
    "name": "Filter",
    "id": "filter",
    "iconPath": "assets/icons/filters.svg",
    "bgColor": Colors.deepOrangeAccent,
    "iconColor": Colors.white,
    "iconBg": Colors.deepOrangeAccent,
    "color": Colors.white,
    "description": "Chỉ tiếp tục khi...",
    "actions": [
      {"id": "filter", "title": "nếu thõa điều kiện"},
    ]
  },
  "path": {
    "type": "path",
    "name": "Path",
    "id": "path",
    "iconPath": "assets/icons/path.svg",
    "bgColor": Colors.white,
    "iconColor": Colors.black,
    "iconBg": Colors.white,
    "color": Colors.black,
  },
  "email": {
    "type": "action",
    "name": "Email",
    "id": "email",
    "iconPath": "assets/icons/gmail.svg",
    "bgColor": Colors.indigo,
    "iconColor": Colors.white,
    "iconBg": Colors.indigo,
    "color": Colors.white,
    "description": "Kết nối email để gửi một email",
    "actions": [
      {"id": "email_send", "title": "Gửi một email"},
    ]
  },
  "notify": {
    "type": "action",
    "name": "Thông báo",
    "id": "notify",
    "iconPath": "assets/icons/notifications.svg",
    "bgColor": Colors.blue,
    "iconColor": Colors.white,
    "iconBg": Colors.blue,
    "color": Colors.white,
    "description":
        "Nhận thông báo từ ứng dụng Coka với nội dung được cấu hình sẵn",
    "actions": [
      {"id": "notify_send", "title": "Gửi một thông báo từ ứng dụng Coka"},
    ]
  },
  "assign": {
    "type": "action",
    "name": "Phân phối",
    "id": "assign",
    "iconPath": "assets/icons/assign.svg",
    "bgColor": Colors.cyan,
    "iconColor": Colors.white,
    "iconBg": Colors.cyan,
    "color": Colors.white,
    "description": "Phân phối quản lý khách hàng cho các đội sale và seller",
    "actions": [
      {"id": "assign_team", "title": "Phân phối tới các đội sale"},
      {"id": "assign_user", "title": "Phân phối tới các nhân viên sale"},
    ]
  }
};
final triggerUiData = {
  "default": {
    "name": "Default trigger",
    "id": "default",
    "iconPath": "assets/icons/trigger.svg",
    "bgColor": null,
    "description": "Chọn trigger lắng nghe sự kiện"
  },
  "customer": {
    "name": "Khách hàng",
    "id": "customer",
    "iconPath": "assets/icons/customer_2_icon.svg",
    "bgColor": const Color(0xff3f51b5),
    "description":
        "Đây là nơi cho phép bạn quản lý khách hàng trong ứng dụng Coka",
    "triggers": [
      {
        "id": "CREATE_CONTACT",
        "title": "Khi có một khách hàng mới được thêm vào"
      },
      {
        "id": "UPDATE_CONTACT",
        "title": "Khi có sự thay đổi trong dữ liệu khách hàng"
      }
    ],
  },
};

class AddAppletController extends GetxController {
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  final triggerData = {}.obs;
  late ListModel<int> actionList;
  final currentIndex = 0.obs;
  final actionDataList = [].obs;
  final pathDataList = <Map>[].obs;
  final currentWorkspace = {}.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    final uiData = Get.arguments;
    if (uiData != null) {
      triggerData.value = uiData["triggerData"];
      actionDataList.value = uiData["actionDataList"];
      actionList = ListModel<int>(
        listKey: listKey,
        initialItems: generateList(actionDataList.length),
        removedItemBuilder: _buildRemovedItem,
      );
    } else {
      addOneAction(0);
      triggerData.value = {"type": "default"};
      actionList = ListModel<int>(
        listKey: listKey,
        initialItems: generateList(actionDataList.length),
        removedItemBuilder: _buildRemovedItem,
      );
    }
  }

  addOnePath(i1, i2) {
    actionDataList[i1]["pathList"][i2]
        .add({"type": "filter", "orList": '[[{}]]'});
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
