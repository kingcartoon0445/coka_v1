import 'dart:async';
import 'dart:convert';

import 'package:coka/api/team.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/border_textfield.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/constants.dart';
import 'package:coka/models/chip_data.dart';
import 'package:coka/models/find_child.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/workspace/getx/team_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as g;
import 'package:get/get.dart';

import '../../../components/chip_input.dart';

const categoryMenu = <ChipData>[
  ChipData('ce7f42cf-f10f-49d2-b57e-0c75f8463c82', 'Nhập vào'),
  ChipData('3b70970b-e448-46fa-af8f-6605855a6b52', 'Form'),
  ChipData('38b353c3-ecc8-4c62-be27-229ef47e622d', 'AIDC'),
];
const sourceMenu = <ChipData>[
  ChipData('Khách cũ', 'Khách cũ'),
  ChipData('Được giới thiệu', 'Được giới thiệu'),
  ChipData('Trực tiếp', 'Trực tiếp'),
  ChipData('Hotline', 'Hotline'),
  ChipData('Google', 'Google'),
  ChipData('Facebook', 'Facebook'),
  ChipData('Zalo', 'Zalo'),
  ChipData('Tiktok', 'Tiktok'),
  ChipData('Khác', 'Khác'),
];

class AddTeam extends StatefulWidget {
  final String? parentId;
  const AddTeam({super.key, this.parentId});

  @override
  State<AddTeam> createState() => _AddTeamState();
}

class _AddTeamState extends State<AddTeam> {
  TextEditingController nameController = TextEditingController();
  TextEditingController desController = TextEditingController();
  String selectedDistribution = 'Phân phối tự động';
  bool isAutoAssignToNew = true;
  var sourceList = <ChipData>[];
  var categoryList = <ChipData>[];
  final sourceChipKey = GlobalKey<ChipsInputState>();
  final categoryChipKey = GlobalKey<ChipsInputState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Tạo đội",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2329)),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              BorderTextField(
                name: "Tên team",
                nameHolder: "Tên team",
                controller: nameController,
                isRequire: true,
              ),
              // const SizedBox(
              //   height: 20,
              // ),
              // const Text(
              //   "Phân phối khách hàng",
              //   style: TextStyle(
              //       color: Color(0xFF1F2329),
              //       fontWeight: FontWeight.bold,
              //       fontSize: 16),
              // ),
              // RadioListTile(
              //   title: const Text('Phân phối tự động',
              //       style: TextStyle(fontWeight: FontWeight.w500)),
              //   value: 'Phân phối tự động',
              //   contentPadding: EdgeInsets.zero,
              //   groupValue: selectedDistribution,
              //   subtitle: GestureDetector(
              //       onTap: () {
              //         showModalBottomSheet(
              //           context: context,
              //           isScrollControlled: true,
              //           shape: const RoundedRectangleBorder(
              //               borderRadius: BorderRadius.vertical(
              //                   top: Radius.circular(12))),
              //           builder: (context) => ConfigAssignBottomSheet(
              //             onRatioChange: () {},
              //             onSwitchChange: (isAuto) {
              //               setState(() {
              //                 isAutoAssignToNew = isAuto;
              //               });
              //             },
              //             parentId: "add",
              //             isAutoAssignToNew: isAutoAssignToNew,
              //             teamList: const [],
              //             countObject: const [],
              //           ),
              //         );
              //       },
              //       child: const Text("Tuỳ chỉnh",
              //           style: TextStyle(
              //             fontSize: 12,
              //             fontWeight: FontWeight.w500,
              //             color: Color(0xFF5A48F1),
              //             decoration: TextDecoration.underline,
              //           ))),
              //   onChanged: (value) {
              //     setState(() {
              //       selectedDistribution = value!;
              //     });
              //   },
              // ),
              // RadioListTile(
              //   title: const Text('Phân phối thủ công',
              //       style: TextStyle(fontWeight: FontWeight.w500)),
              //   value: 'Phân phối thủ công',
              //   contentPadding: EdgeInsets.zero,
              //   groupValue: selectedDistribution,
              //   onChanged: (value) {
              //     setState(() {
              //       selectedDistribution = value!;
              //     });
              //   },
              // ),
              // const SizedBox(
              //   height: 20,
              // ),
              // buildChipInput(
              //   sourceChipKey,
              //   categoryChipKey,
              //   onCategoryChange: (data) {
              //     setState(() {
              //       categoryList = data;
              //     });
              //   },
              //   onSourceChange: (data) {
              //     setState(() {
              //       sourceList = data;
              //     });
              //   },
              //   categoryInitValue: categoryList,
              //   sourceInitValue: sourceList,
              // ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            HomeController homeController = g.Get.put(HomeController());
            showLoadingDialog(context);
            final categoryIdList = [...categoryList.map((e) => e.id)];
            final sourceIdList = [...sourceList.map((e) => e.id)];
            TeamApi().createTeam(homeController.workGroupCardDataValue["id"], {
              "name": nameController.text,
              // "managers": [],
              if (widget.parentId != null) "parentId": widget.parentId,
              // "isAutomation":
              //     selectedDistribution == 'Phân phối tự động' ? true : false,
              // "isAutoAssignRule": isAutoAssignToNew,
              // "categoryList": categoryIdList,
              // "sourceList": sourceIdList,
            }).then((res) {
              g.Get.back();
              if (isSuccessStatus(res["code"])) {
                TeamController teamController = g.Get.put(TeamController());
                teamController.fetchTeamList("");
                g.Get.back();
                successAlert(
                  title: "Thành công",
                  desc: "Bạn đã tạo đội ${nameController.text}",
                  btnOkOnPress: () {},
                );
              } else {
                errorAlert(title: "Thất bại", desc: res["message"]);
              }
            });
          },
          shape: const CircleBorder(),
          backgroundColor: const Color(0xFF5C33F0),
          child: const Icon(
            Icons.check,
            color: Colors.white,
          )),
    );
  }
}

class EditTeam extends StatefulWidget {
  final bool? isRaw;
  final Map dataItem;
  final String? teamId;
  const EditTeam(
      {super.key, required this.dataItem, this.isRaw = false, this.teamId});

  @override
  State<EditTeam> createState() => _EditTeamState();
}

class _EditTeamState extends State<EditTeam> {
  TextEditingController nameController = TextEditingController();
  TextEditingController desController = TextEditingController();
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    teamController.memberList.clear();
    nameController.text = widget.dataItem["name"] ?? "";
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.isRaw! ? "Cấu hình phân phối" : "Sửa team",
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2329)),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.isRaw!)
                BorderTextField(
                  name: "Tên team",
                  nameHolder: "Tên team",
                  controller: nameController,
                  isRequire: true,
                ),
              // const SizedBox(
              //   height: 20,
              // ),
              // const Text(
              //   "Phân phối",
              //   style: TextStyle(
              //       color: Color(0xFF1F2329),
              //       fontWeight: FontWeight.bold,
              //       fontSize: 16),
              // ),
              // RadioListTile(
              //   title: const Text('Phân phối tự động',
              //       style: TextStyle(fontWeight: FontWeight.w500)),
              //   value: 'Phân phối tự động',
              //   contentPadding: EdgeInsets.zero,
              //   groupValue: selectedDistribution,
              //   subtitle: GestureDetector(
              //       onTap: () {
              //         showModalBottomSheet(
              //           context: context,
              //           isScrollControlled: true,
              //           shape: const RoundedRectangleBorder(
              //               borderRadius: BorderRadius.vertical(
              //                   top: Radius.circular(12))),
              //           builder: (context) => ConfigAssignBottomSheet(
              //             onSwitchChange: (isAuto) {
              //               setState(() {
              //                 isAutoAssignToNew = isAuto;
              //               });
              //             },
              //             isAutoAssignToNew: isAutoAssignToNew,
              //             parentId: widget.teamId,
              //             onRatioChange: (value) {
              //               countObject = value;
              //             },
              //             teamList: teamList,
              //             countObject: countObject,
              //           ),
              //         );
              //       },
              //       child: const Text("Tuỳ chỉnh",
              //           style: TextStyle(
              //             fontSize: 12,
              //             fontWeight: FontWeight.w500,
              //             color: Color(0xFF5A48F1),
              //             decoration: TextDecoration.underline,
              //           ))),
              //   onChanged: (value) {
              //     setState(() {
              //       selectedDistribution = value!;
              //     });
              //   },
              // ),
              // RadioListTile(
              //   title: const Text('Phân phối thủ công',
              //       style: TextStyle(fontWeight: FontWeight.w500)),
              //   value: 'Phân phối thủ công',
              //   contentPadding: EdgeInsets.zero,
              //   groupValue: selectedDistribution,
              //   onChanged: (value) {
              //     setState(() {
              //       selectedDistribution = value!;
              //     });
              //   },
              // ),
              // const SizedBox(
              //   height: 20,
              // ),
              // if (!(widget.isRaw ?? false))
              //   buildChipInput(
              //     sourceChipKey,
              //     categoryChipKey,
              //     onCategoryChange: (data) {
              //       setState(() {
              //         categoryList = data;
              //       });
              //     },
              //     onSourceChange: (data) {
              //       setState(() {
              //         sourceList = data;
              //       });
              //     },
              //     categoryInitValue: categoryList,
              //     sourceInitValue: sourceList,
              //   ),
              // const SizedBox(
              //   height: 30,
              // )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            HomeController homeController = g.Get.put(HomeController());
            showLoadingDialog(context);
            if (widget.dataItem["id"] != null) {
              final categoryIdList = [...categoryList.map((e) => e.id)];
              final sourceIdList = [...sourceList.map((e) => e.id)];
              // print({
              //   "name": nameController.text,
              //   "parentId": widget.teamId,
              //   "ratio": countObject,
              //   "IsAutoAssignRule": isAutoAssignToNew,
              //   "isAutomation":
              //       selectedDistribution == 'Phân phối tự động' ? true : false,
              //   "categoryList": categoryIdList,
              //   "sourceList": sourceIdList
              // });

              TeamApi().updateTeam(homeController.workGroupCardDataValue["id"],
                  widget.dataItem["id"], {
                "name": nameController.text,
                "parentId": widget.teamId,
                // "ratio": countObject,
                // "IsAutoAssignRule": isAutoAssignToNew,
                // "isAutomation":
                //     selectedDistribution == 'Phân phối tự động' ? true : false,
                // "categoryList": categoryIdList,
                // "sourceList": sourceIdList
              }).then((res) {
                g.Get.back();
                if (isSuccessStatus(res["code"])) {
                  TeamController teamController = g.Get.put(TeamController());
                  teamController.fetchTeamList("");
                  g.Get.back();
                  successAlert(
                    title: "Thành công",
                    desc: "Bạn đã sửa team ${nameController.text}",
                    btnOkOnPress: () {},
                  );
                } else {
                  errorAlert(title: "Thất bại", desc: res["message"]);
                }
              });
            } else {
              // WorkspaceApi().updateAutomationWorkspace({
              //   "ratio": countObject,
              //   "IsAutoAssignRule": isAutoAssignToNew,
              //   "isAutomation":
              //       selectedDistribution == 'Phân phối tự động' ? true : false,
              // }, homeController.workGroupCardDataValue["id"]).then((res) {
              //   g.Get.back();
              //   if (isSuccessStatus(res["code"])) {
              //     WorkspaceMainController wmController =
              //         g.Get.put(WorkspaceMainController());
              //     wmController.fetchWorkspaceDetail();
              //     TeamController teamController = g.Get.put(TeamController());
              //     teamController.fetchTeamList("");
              //     g.Get.back();
              //     successAlert(
              //       title: "Thành công",
              //       desc: "Bạn đã sửa cấu hình phân phối",
              //       btnOkOnPress: () {},
              //     );
              //   } else {
              //     errorAlert(title: "Thất bại", desc: res["message"]);
              //   }
              // });
            }
          },
          shape: const CircleBorder(),
          backgroundColor: const Color(0xFF5C33F0),
          child: const Icon(
            Icons.check,
            color: Colors.white,
          )),
    );
  }
}

Column buildChipInput(sourceChipKey, categoryChipKey,
    {required Function(List<ChipData>) onCategoryChange,
    required Function(List<ChipData>) onSourceChange,
    required List<ChipData> categoryInitValue,
    required List<ChipData> sourceInitValue,
    List<ChipData>? itemMenu}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Theo phân loại",
        style: TextStyle(
            color: Color(0xFF1F2329),
            fontWeight: FontWeight.bold,
            fontSize: 14),
      ),
      const SizedBox(
        height: 10,
      ),
      ChipsInput(
        initialSuggestions: categoryMenu,
        initialValue: categoryInitValue,
        key: categoryChipKey,
        keyboardAppearance: Brightness.dark,
        textCapitalization: TextCapitalization.words,
        textStyle: const TextStyle(height: 1.5, fontSize: 16),
        allowChipEditing: false,
        suggestionsBoxMaxHeight: 400,
        decoration: InputDecoration(
            hintText: 'Tất cả',
            suffixIcon: const Icon(Icons.keyboard_arrow_down),
            filled: true,
            fillColor: const Color(0xFFF8F8F8),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none)),
        findSuggestions: (String query) {
          if (query.isNotEmpty) {
            var lowercaseQuery = query.toLowerCase();
            return categoryMenu.where((profile) {
              return profile.name.toLowerCase().contains(query.toLowerCase()) ||
                  profile.id.toLowerCase().contains(query.toLowerCase());
            }).toList(growable: false)
              ..sort((a, b) => a.name
                  .toLowerCase()
                  .indexOf(lowercaseQuery)
                  .compareTo(b.name.toLowerCase().indexOf(lowercaseQuery)));
          }
          // return <AppProfile>[];
          return categoryMenu;
        },
        onChanged: onCategoryChange,
        chipBuilder: (context, state, dynamic profile) {
          return InputChip(
            key: ObjectKey(profile),
            label: Text(profile.name),
            onDeleted: () => state.deleteChip(profile),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
        suggestionBuilder: (context, state, dynamic profile) {
          return ListTile(
            key: ObjectKey(profile),
            title: Text(profile.name),
            onTap: () => state.selectSuggestion(profile),
          );
        },
      ),
      const SizedBox(
        height: 14,
      ),
      const Text(
        "Theo nguồn",
        style: TextStyle(
            color: Color(0xFF1F2329),
            fontWeight: FontWeight.bold,
            fontSize: 14),
      ),
      const SizedBox(
        height: 10,
      ),
      ChipsInput(
        initialSuggestions: itemMenu ?? sourceMenu,
        key: sourceChipKey,
        initialValue: sourceInitValue,
        keyboardAppearance: Brightness.dark,
        textCapitalization: TextCapitalization.words,
        textStyle: const TextStyle(height: 1.5, fontSize: 16),
        allowChipEditing: true,
        suggestionsBoxMaxHeight: 400,
        decoration: InputDecoration(
            hintText: 'Tất cả',
            suffixIcon: const Icon(Icons.keyboard_arrow_down),
            filled: true,
            fillColor: const Color(0xFFF8F8F8),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none)),
        findSuggestions: (String query) {
          if (query.isNotEmpty) {
            var lowercaseQuery = query.toLowerCase();
            return (itemMenu ?? sourceMenu).where((profile) {
              return profile.name.toLowerCase().contains(query.toLowerCase()) ||
                  profile.id.toLowerCase().contains(query.toLowerCase());
            }).toList(growable: false)
              ..sort((a, b) => a.name
                  .toLowerCase()
                  .indexOf(lowercaseQuery)
                  .compareTo(b.name.toLowerCase().indexOf(lowercaseQuery)));
          }
          // return <AppProfile>[];
          return (itemMenu ?? sourceMenu);
        },
        onChanged: onSourceChange,
        chipBuilder: (context, state, dynamic profile) {
          return InputChip(
            key: ObjectKey(profile),
            label: Text(profile.name),
            onDeleted: () => state.deleteChip(profile),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
        suggestionBuilder: (context, state, dynamic profile) {
          return ListTile(
            key: ObjectKey(profile),
            title: Text(profile.name),
            onTap: () => state.selectSuggestion(profile),
          );
        },
      ),
    ],
  );
}
