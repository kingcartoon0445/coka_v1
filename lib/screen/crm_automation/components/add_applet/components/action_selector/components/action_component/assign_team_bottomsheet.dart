import 'dart:async';

import 'package:coka/api/team.dart';
import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/placeholders.dart';
import 'package:coka/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../add_applet_controller.dart';

class AssignTeamBottomSheet extends StatefulWidget {
  final Function onSubmit;
  final List selectedList;

  const AssignTeamBottomSheet(
      {super.key, required this.onSubmit, required this.selectedList});

  @override
  State<AssignTeamBottomSheet> createState() => _AssignTeamBottomSheetState();
}

class _AssignTeamBottomSheetState extends State<AssignTeamBottomSheet> {
  var teamList = [];
  var selectedList = [];
  Timer? _debounce;
  List? selected;
  var isTeamFetching = false;
  var filteredTeam = [];
  TextEditingController searchTeamController = TextEditingController();
  final addAppletController = Get.put(AddAppletController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchTeamList("").then((value) {
      selected = createFalseList(teamList.length);
    });
  }

  List<bool> createFalseList(int n) {
    return List<bool>.generate(n, (index) {
      if (widget.selectedList.isEmpty) {
        return false;
      } else {
        return widget.selectedList[index] ?? false;
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
        .getTeamList(addAppletController.currentWorkspace["id"], searchText,
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
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height - 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text("Chọn team để chia tỉ lệ",
                    style: TextStyle(
                        color: Color(0xFF1F2329),
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                    onPressed: () {
                      selectedList.clear();
                      for (var x = 0; x < teamList.length; x++) {
                        if (selected![x]) {
                          selectedList.add(teamList[x]);
                        }
                      }
                      widget.onSubmit(selectedList, selected);
                      Get.back();
                    },
                    icon: const Icon(
                      Icons.done_all_outlined,
                      size: 28,
                    ))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SearchBar(
              leading: const Icon(Icons.search),
              backgroundColor:
                  const WidgetStatePropertyAll(Color(0xFFF2F3F5)),
              hintText: "Nhập tên team",
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
                        final avatar = filteredTeam[index]["avatar"];
                        final name = filteredTeam[index]["name"];
                        final subtitle = teamList[index]["managers"].length == 0
                            ? "Chưa có trưởng nhóm"
                            : teamList[index]["managers"][0]["fullName"];
                        return buildListTile(avatar, name, subtitle,
                            isMember: false,
                            isSelected: selected?[index], onChange: (value) {
                          setState(() {
                            selected?[index] = value;
                          });
                        });
                      },
                      itemCount: teamList.length,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                    ))
        ],
      ),
    );
  }

  ListTile buildListTile(avatar, name, subtitle,
      {bool? isMember, required bool? isSelected, required Function onChange}) {
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: getAvatarWidget(avatar),
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
      trailing: Checkbox(
        value: isSelected,
        onChanged: (value) {
          onChange(value);
        },
      ),
    );
  }
}
