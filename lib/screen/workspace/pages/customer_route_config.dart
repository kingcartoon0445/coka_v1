import 'dart:async';
import 'dart:convert';

import 'package:coka/api/recall.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/workspace/components/recall_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/chip_input.dart';
import '../../../models/chip_data.dart';
import '../../../models/find_child.dart';
import '../../home/home_controller.dart';
import '../getx/team_controller.dart';
import 'add_team.dart';
import 'config_assign_bottomsheet.dart';
import 'route_config_log.dart';

List<ChipData> filterChipDataByIds(List<ChipData> chipDataList, List ids) {
  return chipDataList.where((chipData) => ids.contains(chipData.id)).toList();
}

class CustomerRouteConfig extends StatefulWidget {
  final bool isRaw;
  final Map dataItem;
  final String? teamId;
  const CustomerRouteConfig(
      {super.key, required this.isRaw, required this.dataItem, this.teamId});

  @override
  State<CustomerRouteConfig> createState() => _CustomerRouteConfigState();
}

class _CustomerRouteConfigState extends State<CustomerRouteConfig> {
  final teamController = Get.put(TeamController());
  final homeController = Get.put(HomeController());
  String selectedDistribution = 'Phân phối tự động';
  bool isAutoAssignToNew = true;
  var teamList = [];
  var countObject = [];
  var sourceList = <ChipData>[];
  var categoryList = <ChipData>[];
  final sourceChipKey = GlobalKey<ChipsInputState>();
  final categoryChipKey = GlobalKey<ChipsInputState>();
  var isRecall = false;
  bool isForce = false;
  bool isLoading = false;
  var recallConfig = <String, dynamic>{
    "condition": "",
    "rule": "TEAM",
    "duration": 10,
    "status": 0,
    "isForce": false
  };
  List types = [
    {"type": 0, "name": "Đội sale của người phụ trách"},
    {"type": 1, "name": "Chỉ định cụ thể"},
    {"type": 2, "name": "Nhóm làm việc"},
  ];
  Map targetConfig = {
    "time": const TimeOfDay(hour: 0, minute: 10),
    "category": ["Tất cả"],
    "source": ["Tất cả"],
    "isForce": false
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.teamId != null) {
      recallConfig["teamId"] = widget.teamId;
    }
    targetConfig["target"] = types[0];
    teamController.memberList.clear();
    getRecallConfig();
    isAutoAssignToNew = widget.dataItem["isAutoAssignRule"] ??
        homeController.workGroupCardDataValue["isAutoAssignRule"];
    selectedDistribution = widget.dataItem["isAutomation"] ??
            homeController.workGroupCardDataValue["isAutomation"]
        ? "Phân phối tự động"
        : "Phân phối thủ công";
    teamList = widget.teamId == "add"
        ? []
        : (widget.teamId == null)
            ? teamController.teamList
            : findBranchWithParentId(
                    teamController.teamList, widget.teamId!)?["childs"] ??
                [];
    generateRatioList(teamList, false);
    if (widget.dataItem["automationCategory"] != null) {
      categoryList = <ChipData>[
        ...(jsonDecode(widget.dataItem["automationCategory"]) as List)
            .map((e) => categoryMenu.firstWhere((element) => element.id == e))
      ];
    }
    if (widget.dataItem["automationSource"] != null) {
      sourceList = <ChipData>[
        ...(jsonDecode(widget.dataItem["automationSource"]) as List)
            .map((e) => ChipData(e, e))
      ];
    }

    if (teamList.isEmpty && widget.teamId != null && widget.teamId != "add") {
      Timer(
          const Duration(milliseconds: 100),
          () => teamController.fetchMemberList(widget.teamId, "").then((value) {
                setState(() {
                  generateRatioList(teamController.memberList, true);
                });
              }));
    }
  }

  Future getRecallConfig() async {
    setState(() {
      isLoading = true;
    });
    final res = await RecallApi()
        .getRecall(homeController.workGroupCardDataValue["id"], widget.teamId);
    setState(() {
      isLoading = false;
    });
    if (res["content"] != null) {
      final content = res["content"]["workspaceRule"] ?? res["content"];
      if (res["content"]["workspaceRule"] != null) {
        setState(() {
          isForce = true;
        });
      }
      recallConfig["status"] = content["status"];
      if (res["content"]?["isForce"] != null) {
        recallConfig["isForce"] = content["isForce"];
        targetConfig["isForce"] = content["isForce"];
      }
      recallConfig["condition"] = content["condition"];
      recallConfig["rule"] = content["rule"];

      recallConfig["duration"] = content["duration"];
      final cond =
          jsonDecode(content["condition"])["conditions"][0]["conditions"];
      final categoryData = cond[0];
      final sourceData = cond[1];
      final category = categoryData["value"] == "*"
          ? ["Tất cả"]
          : filterChipDataByIds(categoryMenu, categoryData["extendValues"]);
      final source = sourceData["value"] == "*"
          ? ["Tất cả"]
          : filterChipDataByIds(sourceMenu, sourceData["extendValues"]);

      targetConfig["category"] = category;
      targetConfig["source"] = source;
      targetConfig["time"] = TimeOfDay(
          hour: recallConfig["duration"] ~/ 60,
          minute: recallConfig["duration"] % 60);
      targetConfig["target"] = recallConfig["rule"] == "TEAM"
          ? types[0]
          : recallConfig["rule"] == "ASSIGN_TO"
              ? types[1]
              : types[2];
      if (recallConfig["rule"] == "ASSIGN_TO") {
        targetConfig["target"]["teamData"] = {
          "id": res["content"]["assignTeamId"],
          "name": res["content"]["assignTeamName"],
        };
      }
      isRecall = recallConfig["status"] == 1;
      setState(() {});
    }
  }

  void generateRatioList(List dataList, bool isMemberList) {
    for (var x in dataList) {
      countObject.add({
        "refId": isMemberList ? x["profileId"] : x["id"],
        "ratio": x["ratio"]
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
              title: const Text(
                "Định tuyến khách hàng",
                style: TextStyle(
                    color: Color(0xFF1F2329),
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
              centerTitle: true,
              bottom: TabBar(tabs: [
                ...["Định tuyến", "Nhật ký"].map((e) => Tab(
                      text: e,
                    ))
              ]),
              automaticallyImplyLeading: true),
          body: TabBarView(children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: widget.isRaw ? Get.height - 160 : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!widget.isRaw)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Điều kiện nhận khách hàng",
                              style: TextStyle(
                                  color: Color(0xFF1F2329),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            buildChipInput(
                              sourceChipKey,
                              categoryChipKey,
                              onCategoryChange: (data) {
                                setState(() {
                                  categoryList = data;
                                });
                              },
                              onSourceChange: (data) {
                                setState(() {
                                  sourceList = data;
                                });
                              },
                              categoryInitValue: categoryList,
                              sourceInitValue: sourceList,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      const Text(
                        "Phân phối khách hàng",
                        style: TextStyle(
                            color: Color(0xFF1F2329),
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      RadioListTile(
                        title: const Text('Phân phối tự động',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        value: 'Phân phối tự động',
                        contentPadding: EdgeInsets.zero,
                        groupValue: selectedDistribution,
                        subtitle: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(12))),
                                builder: (context) => ConfigAssignBottomSheet(
                                  onSwitchChange: (isAuto) {
                                    setState(() {
                                      isAutoAssignToNew = isAuto;
                                    });
                                  },
                                  isAutoAssignToNew: isAutoAssignToNew,
                                  parentId: widget.teamId,
                                  onRatioChange: (value) {
                                    countObject = value;
                                  },
                                  teamList: teamList,
                                  countObject: countObject,
                                ),
                              );
                            },
                            child: const Text("Tuỳ chỉnh",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF5A48F1),
                                  decoration: TextDecoration.underline,
                                ))),
                        onChanged: (value) {
                          setState(() {
                            selectedDistribution = value!;
                          });
                        },
                      ),
                      RadioListTile(
                        title: const Text('Phân phối thủ công',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        value: 'Phân phối thủ công',
                        contentPadding: EdgeInsets.zero,
                        groupValue: selectedDistribution,
                        onChanged: (value) {
                          setState(() {
                            selectedDistribution = value!;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      const Text(
                        "Kịch bản thu hồi khách hàng",
                        style: TextStyle(
                            color: Color(0xFF1F2329),
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      if (!isLoading)
                        GestureDetector(
                          onTap: () {
                            if (!isForce || widget.teamId == null) {
                              showModalBottomSheet(
                                context: Get.context!,
                                backgroundColor: Colors.white,
                                isScrollControlled: true,
                                constraints:
                                    BoxConstraints(maxHeight: Get.height * .6),
                                shape: const RoundedRectangleBorder(
                                  // <-- SEE HERE
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(14.0),
                                  ),
                                ),
                                builder: (BuildContext context) {
                                  return RecallBottomsheet(
                                    isRaw: widget.isRaw ?? false,
                                    initConfig: targetConfig,
                                    onSubmit: (p0) {
                                      setState(() {
                                        targetConfig = p0;
                                      });
                                      print(p0);
                                    },
                                  );
                                },
                              );
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(
                                top: isForce && widget.teamId != null ? 14 : 6,
                                left: 16,
                                right: 10,
                                bottom: 16),
                            decoration: BoxDecoration(
                              color: isRecall
                                  ? kPrimaryColor
                                  : const Color(0xFFF3F5F8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    RotatedBox(
                                      quarterTurns: 3,
                                      child: Icon(
                                        Icons.call_merge,
                                        color: isRecall ? Colors.white : null,
                                        size: 26,
                                      ),
                                    ),
                                    isForce && widget.teamId != null
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                                "Áp dụng theo kịch bản quản trị viên",
                                                style: TextStyle(
                                                    color: kPrimaryColor,
                                                    fontSize: 12)),
                                          )
                                        : Transform.scale(
                                            scale: 0.8,
                                            child: Switch(
                                              activeTrackColor:
                                                  const Color(0xFF9B8CF7),
                                              value: isRecall,
                                              onChanged: (value) {
                                                setState(() {
                                                  isRecall = value;
                                                });
                                              },
                                            ),
                                          )
                                  ],
                                ),
                                if (isForce && widget.teamId != null)
                                  const SizedBox(
                                    height: 10,
                                  ),
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                        fontSize: 14,
                                        height: 1.4,
                                        fontFamily: 'GoogleSans',
                                        color: isRecall
                                            ? Colors.white
                                            : const Color(0xB2000000)),
                                    text:
                                        'Nếu người phụ trách nhận khách hàng thuộc phân loại ',
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: targetConfig["category"]
                                              .join(", "),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const TextSpan(text: ' và nguồn '),
                                      TextSpan(
                                          text:
                                              targetConfig["source"].join(", "),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const TextSpan(text: ', sau '),
                                      TextSpan(
                                          text:
                                              '${targetConfig["time"].hour} giờ ${targetConfig["time"].minute} phút',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const TextSpan(
                                        text: ' không cập nhật',
                                      ),
                                      const TextSpan(
                                          text: ' tình trạng chăm sóc '),
                                      const TextSpan(text: ' thu hồi về '),
                                      TextSpan(
                                          text: targetConfig["target"]
                                                      ["type"] ==
                                                  1
                                              ? 'Đội sale ${targetConfig["target"]["teamData"]["name"]}'
                                              : targetConfig["target"]["name"],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      widget.isRaw
                          ? const Spacer()
                          : const SizedBox(
                              height: 16,
                            ),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              onPressed: () async {
                                final targetType =
                                    targetConfig["target"]["type"];
                                print(targetConfig);
                                recallConfig["status"] = isRecall ? 1 : 0;
                                recallConfig["duration"] =
                                    targetConfig["time"].hour * 60 +
                                        targetConfig["time"].minute;
                                recallConfig["rule"] = targetType == 0
                                    ? "TEAM"
                                    : targetType == 1
                                        ? "ASSIGN_TO"
                                        : "WORKSPACE";
                                if (targetType == 1) {
                                  recallConfig["assignTeamId"] =
                                      targetConfig["target"]["teamData"]["id"];
                                }
                                if (widget.teamId == null) {
                                  recallConfig["isForce"] =
                                      targetConfig["isForce"];
                                }
                                recallConfig["condition"] = jsonEncode({
                                  "conjunction": "or",
                                  "conditions": [
                                    {
                                      "conjunction": "and",
                                      "conditions": [
                                        {
                                          "ColumnName": "SourceId",
                                          "operator": "IN",
                                          "value": targetConfig["category"]
                                                      [0] ==
                                                  "Tất cả"
                                              ? '*'
                                              : '',
                                          "extendValues":
                                              targetConfig["category"][0] ==
                                                      "Tất cả"
                                                  ? []
                                                  : targetConfig["category"]
                                                      .map((chipData) =>
                                                          chipData.id)
                                                      .toList()
                                        },
                                        {
                                          "ColumnName": "UtmSource",
                                          "operator": "IN",
                                          "value": targetConfig["source"][0] ==
                                                  "Tất cả"
                                              ? '*'
                                              : '',
                                          "extendValues": targetConfig["source"]
                                                      [0] ==
                                                  "Tất cả"
                                              ? []
                                              : targetConfig["source"]
                                                  .map(
                                                      (chipData) => chipData.id)
                                                  .toList()
                                        }
                                      ]
                                    }
                                  ]
                                });
                                showLoadingDialog(context);
                                final categoryIdList = [
                                  ...categoryList.map((e) => e.id)
                                ];
                                final sourceIdList = [
                                  ...sourceList.map((e) => e.id)
                                ];
                                final dataRes = {
                                  "automationRule": {
                                    "ratio": countObject,
                                    "isAutoAssignRule": isAutoAssignToNew,
                                    "isAutomation": selectedDistribution ==
                                            'Phân phối tự động'
                                        ? true
                                        : false,
                                    "categoryList": categoryIdList,
                                    "sourceList": sourceIdList
                                  },
                                  "evictionRule": recallConfig
                                };
                                final res = await RecallApi().updateRouting(
                                    homeController.workGroupCardDataValue["id"],
                                    widget.teamId,
                                    dataRes);
                                Get.back();
                                if (isSuccessStatus(res["code"])) {
                                  TeamController teamController =
                                      Get.put(TeamController());
                                  teamController.fetchTeamList("");
                                  Get.back();

                                  successAlert(
                                      title: "Thành công",
                                      desc: "Đã cập nhật cấu hình định tuyến");
                                } else {
                                  errorAlert(
                                      title: "Lỗi", desc: res["message"]);
                                }

                                print(res);
                              },
                              child: const Text(
                                "Hoàn thành",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'GoogleSans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ))),
                      const SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            RouteConfigLog(
              teamId: widget.teamId,
            )
          ])),
    );
  }
}
