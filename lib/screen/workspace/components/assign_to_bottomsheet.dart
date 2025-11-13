import 'dart:async';

import 'package:coka/api/team.dart';
import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/placeholders.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AssignToBottomSheet extends StatefulWidget {
  final Function onSelected;
  const AssignToBottomSheet({super.key, required this.onSelected});

  @override
  State<AssignToBottomSheet> createState() => _AssignToBottomSheetState();
}

class _AssignToBottomSheetState extends State<AssignToBottomSheet> {
  var memberList = [];
  var teamList = [];
  var filteredTeam = [];
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
    await TeamApi()
        .getMemberInWorkspaceList(
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
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Chuyển phụ trách",
                      style: TextStyle(
                          color: Color(0xFF1F2329),
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
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
                                          ["profile"]["avatar"];
                                      final fullName = memberList[index]
                                          ["profile"]["fullName"];
                                      final subtitle =
                                          memberList[index]["team"]["name"];
                                      return buildListTile(
                                          avatar, fullName, subtitle,
                                          onTap: () {
                                        widget.onSelected({
                                          "teamId": memberList[index]["team"]
                                              ["id"],
                                          "assignTo": memberList[index]
                                              ["profileId"]
                                        });
                                      }, isMember: true);
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
                                      return buildListTile(
                                        avatar,
                                        name,
                                        subtitle,
                                        onTap: () {
                                          widget.onSelected({
                                            "teamId": filteredTeam[index]["id"],
                                          });
                                        },
                                      );
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

  ListTile buildListTile(avatar, name, subtitle,
      {required VoidCallback onTap, bool? isMember}) {
    return ListTile(
      leading: avatar == null
          ? createCircleAvatar(name: name, radius: 20)
          : Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x663949AB), width: 1),
                  color: Colors.white),
              child: CircleAvatar(
                backgroundImage: getAvatarProvider(avatar),
              ),
            ),
      title: Text(name,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)),
      subtitle: Row(
        children: [
          if (isMember ?? false)
            const Padding(
              padding: EdgeInsets.only(right: 3.0),
              child: Icon(Icons.group_outlined, size: 16),
            ),
          Text(
            subtitle,
            style:
                TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 13),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
