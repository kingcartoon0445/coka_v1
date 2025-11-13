import 'dart:async';

import 'package:coka/api/organization.dart';
import 'package:coka/api/team.dart';
import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/components/placeholders.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../getx/team_controller.dart';

void showAddLeader2Team(teamId) {
  showModalBottomSheet(
    context: Get.context!,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    constraints: BoxConstraints(maxHeight: Get.height - 45),
    shape: const RoundedRectangleBorder(
      // <-- SEE HERE
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(14.0),
      ),
    ),
    builder: (BuildContext context) {
      return AddLeader2TeamBottomSheet(
        teamId: teamId,
      );
    },
  );
}

class AddLeader2TeamBottomSheet extends StatefulWidget {
  final String teamId;

  const AddLeader2TeamBottomSheet({
    super.key,
    required this.teamId,
  });

  @override
  State<AddLeader2TeamBottomSheet> createState() =>
      _AddLeader2TeamBottomSheetState();
}

class _AddLeader2TeamBottomSheetState extends State<AddLeader2TeamBottomSheet> {
  TeamController teamController = Get.put(TeamController());

  List memberList = [];
  bool isFetching = false;
  Timer? _debounce;
  int offset = 0;
  bool isLoadingMore = false;
  ScrollController sc = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchMemberList("");
    sc.addListener(() {
      if (sc.position.pixels >= sc.position.maxScrollExtent) {
        if (memberList.isNotEmpty && !isFetching && !isLoadingMore) {
          setState(() {
            isLoadingMore = true;
          });
          fetchMemberList(searchController.text).then((value) {
            Timer(const Duration(milliseconds: 100), () {
              setState(() {
                isLoadingMore = false;
              });
            });
          });
        }
      }
    });
  }

  Future onRefresh() async {
    offset = 0;
    memberList.clear();
    await fetchMemberList(searchController.text);
  }

  Future fetchMemberList(searchText) async {
    setState(() {
      isFetching = true;
    });
    await OrganApi().getOrganMembers(searchText, offset, status: 1).then((res) {
      setState(() {
        isFetching = false;
      });
      if (isSuccessStatus(res['code'])) {
        offset += 20;
        memberList.addAll(res['content']);
      } else {
        errorAlert(title: 'Lỗi', desc: res['message']);
      }
    });
  }

  void onDebounce(Function(String) searchFunction, int debounceTime) {
    // Hủy bỏ bất kỳ timer nào nếu có
    _debounce?.cancel();

    // Tạo mới timer với thời gian debounce
    _debounce = Timer(Duration(milliseconds: debounceTime), () {
      offset = 0;
      memberList.clear();
      searchFunction(searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
      child: Column(
        children: [
          const SizedBox(
            height: 4,
          ),
          Container(
            width: Get.width,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Row(
              children: [
                SizedBox(
                  width: 16,
                ),
                Text(
                  "Thêm trưởng nhóm",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2329)),
                ),
                Spacer(),
              ],
            ),
          ),
          const Divider(
            height: 1,
            color: Color(0xFFFAF8FD),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SearchBar(
              leading: const Icon(Icons.search),
              backgroundColor:
                  const WidgetStatePropertyAll(Color(0xFFF8F8F8)),
              hintText: "Nhập tên thành viên",
              controller: searchController,
              onChanged: (value) {
                onDebounce(fetchMemberList, 800);
              },
            ),
          ),
          Expanded(
              child: isFetching && !isLoadingMore
                  ? const ListPlaceholder(length: 10)
                  : Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        RefreshIndicator(
                          onRefresh: onRefresh,
                          child: ListView.builder(
                            controller: sc,
                            itemBuilder: (context, index) {
                              final profile = memberList[index];
                              final title = profile["fullName"];
                              final subTitle = memberList[index]["email"];
                              final avatar = profile["avatar"];
                              return ListTile(
                                contentPadding:
                                    const EdgeInsets.only(left: 16, right: 8),
                                dense: true,
                                title: Text(title,
                                    style: const TextStyle(fontSize: 14)),
                                subtitle: Text(subTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                leading: avatar == null
                                    ? createCircleAvatar(
                                        name: title, radius: 20)
                                    : CircleAvatar(
                                        backgroundImage:
                                            getAvatarProvider(avatar),
                                        radius: 20,
                                      ),
                                trailing: IconButton(
                                    onPressed: () {
                                      final homeController =
                                          Get.put(HomeController());
                                      warningAlert(
                                          title: "Đặt làm trưởng nhóm",
                                          nameOkBtn: "Đồng ý",
                                          desc:
                                              "Bạn có chắc muốn đặt ${profile["fullName"]} làm trưởng nhóm?",
                                          btnOkOnPress: () {
                                            showLoadingDialog(context);
                                            TeamApi()
                                                .setRole(
                                                    homeController
                                                            .workGroupCardDataValue[
                                                        "id"],
                                                    widget.teamId,
                                                    profile["profileId"],
                                                    "TEAM_LEADER")
                                                .then((res) {
                                              Get.back();
                                              if (isSuccessStatus(
                                                  res["code"])) {
                                                teamController
                                                    .fetchTeamList("");
                                                teamController.fetchMemberList(
                                                    widget.teamId, "");
                                                successAlert(
                                                    title: "Thành công",
                                                    desc:
                                                        "Đã đặt ${profile["fullName"]} làm trưởng nhóm");
                                              } else {
                                                errorAlert(
                                                    title: "Thất bại",
                                                    desc: res["message"]);
                                              }
                                            });
                                          });
                                    },
                                    icon:
                                        const Icon(Icons.person_add_outlined)),
                              );
                            },
                            itemCount: memberList.length,
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                          ),
                        ),
                        if (isLoadingMore)
                          const Positioned(
                              bottom: 0, child: CircularProgressIndicator())
                      ],
                    )),
        ],
      ),
    );
  }
}
