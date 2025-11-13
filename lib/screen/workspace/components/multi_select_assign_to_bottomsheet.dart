import 'dart:async';

import 'package:coka/api/team.dart';
import 'package:coka/api/workspace.dart';
import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/elevated_btn.dart';
import 'package:coka/components/placeholders.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';

import 'package:coka/screen/workspace/main_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MultiSelectAssignToBottomSheet extends StatefulWidget {
  const MultiSelectAssignToBottomSheet({
    super.key,
  });

  @override
  State<MultiSelectAssignToBottomSheet> createState() =>
      _MultiSelectAssignToBottomSheetState();
}

class _MultiSelectAssignToBottomSheetState
    extends State<MultiSelectAssignToBottomSheet> {
  final wmController = Get.put(WorkspaceMainController());
  var memberList = [];
  var teamList = [];
  var filteredTeam = [];
  var memberSelectedList = [];
  var teamSelectedList = [];
  Timer? _debounce;

  var isMemberFetching = false;
  var isTeamFetching = false;

  TextEditingController searchMemberController = TextEditingController();
  TextEditingController searchTeamController = TextEditingController();
  final homeController = Get.put(HomeController());

  void onMemberDebounce(Function(String) searchFunction, int debounceTime) {
    // Hủy bỏ bất kỳ timer nào nếu có
    _debounce?.cancel();

    // Tạo mới timer với thời gian debounce
    _debounce = Timer(Duration(milliseconds: debounceTime), () {
      // Lấy dữ liệu từ trường văn bản và gọi hàm tìm kiếm
      searchFunction(searchMemberController.text);
    });
  }

  Future fetchMemberList(searchText) async {
    setState(() {
      isMemberFetching = true;
    });
    await WorkspaceApi()
        .getWorkspaceMembersList(
            homeController.workGroupCardDataValue["id"], searchText)
        .then((res) {
      setState(() {
        isMemberFetching = false;
      });
      if (isSuccessStatus(res['code'])) {
        memberList = res['content'];
      } else {
        errorAlert(title: 'Lỗi', desc: res['message']);
      }
    });
  }

  onSearchChanged(String query) {
    if (query == "") {
      setState(() {
        filteredTeam = teamList;
      });
    }
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (query.isEmpty) {
        // show all contacts when the search query is empty
        filteredTeam = teamList;
        return;
      }

      // filter the list of contacts based on the search query
      List filtered = [];
      for (var team in teamList) {
        if (team["name"].toLowerCase().contains(query.toLowerCase()) == true) {
          filtered.add(team);
        }
      }
      setState(() {
        filteredTeam = filtered;
      });
    });
  }

  Future fetchTeamList(searchText) async {
    setState(() {
      isTeamFetching = true;
    });

    await TeamApi()
        .getTeamList(homeController.workGroupCardDataValue["id"], searchText,
            isTreeView: false)
        .then((res) {
      if (!isSuccessStatus(res["code"])) {
        return errorAlert(title: "Lỗi", desc: res["message"]);
      }
      teamList = res["content"];
      setState(() {
        filteredTeam = teamList;
        isTeamFetching = false;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    teamSelectedList = List.from(wmController.teamFilterList.value);
    memberSelectedList = List.from(wmController.memberFilterList.value);

    fetchMemberList("");
    fetchTeamList("");
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height - 100,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Text("Phụ trách",
                          style: TextStyle(
                              color: Color(0xFF1F2329),
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      ElevatedBtn(
                          onPressed: () {
                            wmController.teamFilterList.value =
                                teamSelectedList;
                            wmController.memberFilterList.value =
                                memberSelectedList;
                            wmController.update();
                            Get.back();
                          },
                          circular: 50,
                          paddingAllValue: 2,
                          child: const Icon(
                            CupertinoIcons.checkmark_alt,
                            color: Color(0xFF5C33F0),
                            size: 32,
                          ))
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFEBEBEB)),
                const TabBar(
                  indicatorColor: Color(0xFF0F5ABF),
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [
                    Tab(
                      child: Text("Thành viên",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                    ),
                    Tab(
                      child: Text("Đội Sale",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SearchBar(
                            leading: const Icon(Icons.search),
                            backgroundColor: const WidgetStatePropertyAll(
                                Color(0xFFF8F8F8)),
                            hintText: "Nhập tên thành viên",
                            controller: searchMemberController,
                            onChanged: (value) {
                              onMemberDebounce(fetchMemberList, 800);
                            },
                          ),
                        ),
                        Expanded(
                            child: isMemberFetching
                                ? const ListPlaceholder(length: 10)
                                : ListView.builder(
                                    itemBuilder: (context, index) {
                                      final avatar = memberList[index]
                                          ["profile"]?["avatar"];

                                      final fullName = memberList[index]
                                              ["profile"]?["fullName"] ??
                                          "";
                                      // final subtitle =
                                      //     memberList[index]["team"]["name"];
                                      final profileId =
                                          memberList[index]["profileId"];
                                      final isSelected = memberSelectedList.any(
                                          (e) => e["profileId"] == profileId);
                                      return buildListTile(avatar, fullName, "",
                                          isMember: true,
                                          isSelected: isSelected,
                                          onChange: (value) {
                                        if (value) {
                                          setState(() {
                                            memberSelectedList
                                                .add(memberList[index]);
                                          });
                                        } else {
                                          setState(() {
                                            memberSelectedList.removeWhere(
                                                (e) =>
                                                    e["profileId"] ==
                                                    profileId);
                                          });
                                        }
                                      });
                                    },
                                    itemCount: memberList.length,
                                    shrinkWrap: true,
                                    physics: const ClampingScrollPhysics(),
                                  ))
                      ],
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SearchBar(
                            leading: const Icon(Icons.search),
                            backgroundColor: const WidgetStatePropertyAll(
                                Color(0xFFF8F8F8)),
                            hintText: "Nhập tên đội",
                            controller: searchTeamController,
                            onChanged: (value) {
                              onSearchChanged(value);
                            },
                          ),
                        ),
                        Expanded(
                            child: isTeamFetching
                                ? const ListPlaceholder(length: 10)
                                : ListView.builder(
                                    itemBuilder: (context, index) {
                                      final avatar =
                                          filteredTeam[index]["avatar"];
                                      final name = filteredTeam[index]["name"];
                                      final subtitle =
                                          teamList[index]["managers"].length ==
                                                  0
                                              ? "Chưa có trưởng nhóm"
                                              : teamList[index]["managers"][0]
                                                  ["fullName"];
                                      final teamId = filteredTeam[index]["id"];
                                      final isSelected = teamSelectedList
                                          .any((e) => e["id"] == teamId);
                                      return buildListTile(
                                          avatar, name, subtitle,
                                          isSelected: isSelected,
                                          onChange: (value) {
                                        if (value) {
                                          setState(() {
                                            teamSelectedList
                                                .add(filteredTeam[index]);
                                          });
                                        } else {
                                          setState(() {
                                            teamSelectedList.removeWhere(
                                                (e) => e["id"] == teamId);
                                          });
                                        }
                                      });
                                    },
                                    itemCount: filteredTeam.length,
                                    shrinkWrap: true,
                                    physics: const ClampingScrollPhysics(),
                                  ))
                      ],
                    ),
                  ]),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildListTile(avatar, name, subtitle,
      {bool? isMember, required bool? isSelected, required Function onChange}) {
    return name == ""
        ? Container()
        : ListTile(
            leading: avatar == null
                ? createCircleAvatar(name: name, radius: 20)
                : Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0x663949AB), width: 1),
                        color: Colors.white),
                    child: CircleAvatar(
                      backgroundImage: getAvatarProvider(avatar),
                    ),
                  ),
            title: Text(name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black)),
            subtitle: (subtitle == "")
                ? null
                : Row(
                    children: [
                      if (isMember ?? false)
                        const Padding(
                          padding: EdgeInsets.only(right: 3.0),
                          child: Icon(Icons.group_outlined, size: 16),
                        ),
                      Text(
                        subtitle,
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.7), fontSize: 13),
                      ),
                    ],
                  ),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (value) {
                onChange(value);
              },
            ),
          );
  }
}
