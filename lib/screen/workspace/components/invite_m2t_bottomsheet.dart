import 'dart:async';

import 'package:coka/api/organization.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/member_m2t_item.dart';
import 'package:coka/components/placeholders.dart';
import 'package:coka/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../getx/team_controller.dart';

void showInviteM2TMember(teamId) {
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
      return InviteM2TBottomSheet(
        teamId: teamId,
      );
    },
  );
}

class InviteM2TBottomSheet extends StatefulWidget {
  final String teamId;

  const InviteM2TBottomSheet({
    super.key,
    required this.teamId,
  });

  @override
  State<InviteM2TBottomSheet> createState() => _InviteM2TBottomSheetState();
}

class _InviteM2TBottomSheetState extends State<InviteM2TBottomSheet> {
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
                  "Thêm vào nhóm",
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
                              return MemberM2TItem(
                                isInvited: teamController.memberList
                                        .where((e) =>
                                            e["profile"]["id"] ==
                                            memberList[index]["profileId"])
                                        .isNotEmpty
                                    ? true
                                    : false,
                                teamId: widget.teamId,
                                dataItem: memberList[index],
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
