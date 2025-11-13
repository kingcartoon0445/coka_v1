import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/team.dart';
import '../../../components/awesome_alert.dart';
import '../../../constants.dart';
import '../../home/home_controller.dart';
import '../pages/team.dart';

class RecallTargetBottomsheet extends StatefulWidget {
  final Map initData;
  final void Function(dynamic) onSubmit;
  const RecallTargetBottomsheet(
      {super.key, required this.onSubmit, required this.initData});

  @override
  State<RecallTargetBottomsheet> createState() =>
      _RecallTargetBottomsheetState();
}

class _RecallTargetBottomsheetState extends State<RecallTargetBottomsheet> {
  HomeController homeController = Get.put(HomeController());

  var selected = 0;
  List teamList = [];
  Map? teamData;
  List types = [
    "Đội sale của người phụ trách",
    "Chỉ định cụ thể",
    "Nhóm làm việc"
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selected = widget.initData["type"];
    if (widget.initData["teamData"] != null) {
      teamData = widget.initData["teamData"];
    }
    fetchTeamList("");
  }

  Future fetchTeamList(searchText) async {
    await TeamApi()
        .getTeamList(homeController.workGroupCardDataValue["id"], searchText)
        .then((res) {
      if (!isSuccessStatus(res["code"])) {
        return errorAlert(title: "Lỗi", desc: res["message"]);
      }
      setState(() {
        teamList = res["content"];
      });
    });
  }

  Future showTeamList() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return DraggableScrollableSheet(
            expand: false,
            snap: false,
            minChildSize: 0.4,
            builder: (context, controller) {
              return Theme(
                data: ThemeData(
                  dividerColor: Colors.transparent,
                ),
                child: SingleChildScrollView(
                  controller: controller,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 14,
                      ),
                      // const Divider(),
                      ...buildMultiWidgetList(
                        teamList,
                        (data) {
                          Get.back();
                          setState(() {
                            teamData = data;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        ListTile(
          contentPadding: const EdgeInsets.only(left: 16, top: 16, right: 4),
          title: const Text(
            "Đội sale của người phụ trách",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: const Text(
              "Thu hồi dữ liệu khách hàng về đội sale của người phụ trách",
              style: TextStyle(fontSize: 12)),
          leading: const Icon(Icons.people_alt_outlined),
          trailing: Radio(
            value: 0,
            groupValue: selected,
            onChanged: (value) {
              setState(() {
                selected = 0;
              });
            },
          ),
        ),
        ListTile(
          title: const Text(
            "Chỉ định cụ thể",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          onTap: () async {
            showTeamList();
          },
          subtitle: Text(teamData != null ? teamData!["name"] : "Chọn đội sale",
              style: const TextStyle(fontSize: 12)),
          contentPadding: const EdgeInsets.only(left: 16, right: 4),
          leading: const Icon(Icons.assignment_turned_in_outlined),
          trailing: Radio(
            value: 1,
            groupValue: selected,
            onChanged: (value) async {
              if (teamData == null) {
                await showTeamList();
                if (teamData != null) {
                  setState(() {
                    selected = 1;
                  });
                }
              } else {
                setState(() {
                  selected = 1;
                });
              }
            },
          ),
        ),
        ListTile(
          contentPadding: const EdgeInsets.only(left: 16, right: 4),
          title: const Text(
            "Nhóm làm việc",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: const Text("Thu hồi dữ liệu khách hàng về nhóm làm việc",
              style: TextStyle(fontSize: 12)),
          leading: const Icon(Icons.groups_outlined),
          trailing: Radio(
            value: 2,
            groupValue: selected,
            onChanged: (value) {
              setState(() {
                selected = 2;
              });
            },
          ),
        ),
        const Spacer(),
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  widget.onSubmit({
                    "type": selected,
                    "teamData": teamData,
                    "name": types[selected]
                  });
                  Get.back();
                },
                child: const Text(
                  "Hoàn thành",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                )))
      ],
    );
  }
}
