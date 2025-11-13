import 'dart:async';

import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/inc_dec_widget.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/crm_automation/components/add_applet/add_applet_controller.dart';
import 'package:coka/screen/crm_automation/components/add_applet/components/path/path_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'assign_team_bottomsheet.dart';

class AssignTeamAction extends StatefulWidget {
  final String id;
  final int index;
  final bool isPath;
  const AssignTeamAction(
      {super.key, required this.id, required this.index, required this.isPath});

  @override
  State<AssignTeamAction> createState() => _AssignTeamActionState();
}

class _AssignTeamActionState extends State<AssignTeamAction> {
  var selectedTeamList = [];
  var selectedList = [];
  var countObject = {};


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isPath) {
      PathController pathController = Get.put(PathController());
      final index = pathController.currentIndex.value;

      if (pathController.actionDataList[index]["stepsData"] != null) {
        setState(() {
          selectedTeamList = pathController.actionDataList[index]["stepsData"]
              ["params"]["selectedTeamList"];
          selectedList = pathController.actionDataList[index]["stepsData"]
              ["params"]["selectedList"];
          countObject = pathController.actionDataList[index]["stepsData"]
              ["params"]["countObject"];
        });
      }
    } else {
      AddAppletController appletController = Get.put(AddAppletController());
      final index = appletController.currentIndex.value;

      if (appletController.actionDataList[index]["stepsData"] != null) {
        setState(() {
          selectedTeamList = appletController.actionDataList[index]["stepsData"]
              ["params"]["selectedTeamList"];
          selectedList = appletController.actionDataList[index]["stepsData"]
              ["params"]["selectedList"];
          countObject = appletController.actionDataList[index]["stepsData"]
              ["params"]["countObject"];
        });
      }
    }
    Timer(const Duration(milliseconds: 100), () {
      buildShowModalBottomSheet(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Chia tỉ lệ",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        const SizedBox(
          height: 10,
        ),
        ListView.builder(
          itemCount: selectedTeamList.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final avatar = selectedTeamList[index]["avatar"];
            final name = selectedTeamList[index]["name"];
            final subtitle = selectedTeamList[index]["managers"].length == 0
                ? "Chưa có trưởng nhóm"
                : selectedTeamList[index]["managers"][0]["fullName"];
            return buildListTile(index, avatar, name, subtitle, isMember: false,
                onChange: (value) {
              countObject[selectedTeamList[index]["id"]] = value;
            });
          },
        ),
        buildAddTeamBtn(context),
        const SizedBox(
          height: 30,
        ),
        if (selectedTeamList.isNotEmpty)
          SizedBox(
            width: Get.width - 40,
            height: 50,
            child: ElevatedButton(
                onPressed: () {
                  if (widget.isPath) {
                    PathController pathController = Get.put(PathController());
                    final index = pathController.currentIndex.value;
                    final isEdit = pathController.actionDataList[index]
                            ["stepsData"] ==
                        null;
                    final stepsData = {
                      "app": "assign",
                      "type": "write",
                      "action": "assign_team",
                      "params": {
                        "selectedTeamList": selectedTeamList,
                        "selectedList": selectedList,
                        "countObject": countObject
                      }
                    };

                    pathController.actionDataList[index] = {
                      "type": "assign",
                      "stepsData": stepsData,
                      "index": widget.index
                    };
                    pathController.update();
                    if (isEdit) {
                      Get.back();
                      Get.back();
                    }
                  } else {
                    AddAppletController appletController =
                        Get.put(AddAppletController());
                    final index = appletController.currentIndex.value;
                    final isEdit = appletController.actionDataList[index]
                            ["stepsData"] ==
                        null;
                    final stepsData = {
                      "app": "assign",
                      "type": "write",
                      "action": "assign_team",
                      "params": {
                        "selectedTeamList": selectedTeamList,
                        "selectedList": selectedList,
                        "countObject": countObject
                      }
                    };

                    appletController.actionDataList[index] = {
                      "type": "assign",
                      "stepsData": stepsData,
                      "index": widget.index
                    };
                    appletController.update();
                    if (isEdit) {
                      Get.back();
                      Get.back();
                    }
                  }
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white),
                child: const Text(
                  "Tiếp tục",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                )),
          )
      ],
    );
  }

  Container buildListTile(index, avatar, name, subtitle,
      {bool? isMember, required Function onChange}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(index == 0 ? 12 : 0),
              bottom: Radius.circular(
                  index == selectedTeamList.length - 1 ? 12 : 0))),
      child: ListTile(
        contentPadding:
            const EdgeInsets.only(left: 16, right: 10, bottom: 0, top: 0),
        leading: avatar == null
            ? createCircleAvatar(name: name, radius: 20)
            : Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0x663949AB), width: 1),
                    color: Colors.white),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: getAvatarWidget(avatar),
                ),
              ),
        title: Text(name,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 13),
        ),
        trailing: IncrementDecrementWidget(
            onChange: (value) {
              onChange(value);
            },
            initValue: countObject[selectedTeamList[index]["id"]] ?? 1),
      ),
    );
  }

  SizedBox buildAddTeamBtn(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          buildShowModalBottomSheet(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          foregroundColor: Colors.black,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add),
            SizedBox(
              width: 4,
            ),
            Text(
              "Thêm team để chia",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> buildShowModalBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (context) => AssignTeamBottomSheet(
        onSubmit: (members, selects) {
          setState(() {
            selectedTeamList = members;
            selectedList = selects;
            for (var x in selectedTeamList) {
              countObject[x["id"]] ??= 1;
            }
            var deleteList = {};
            for (var x in countObject.keys) {
              deleteList[x] = true;
              for (var y in selectedTeamList) {
                if (y["id"] == x) deleteList[x] = false;
              }
            }
            for (var x in deleteList.entries) {
              final key = x.key;
              final value = x.value;
              if (value) countObject.remove(key);
            }
          });
        },
        selectedList: selectedList,
      ),
    );
  }
}
