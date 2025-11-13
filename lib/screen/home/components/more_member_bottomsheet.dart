import 'dart:async';

import 'package:coka/api/organization.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/member_item.dart';
import 'package:coka/components/placeholders.dart';
import 'package:coka/components/search_bar.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/pages/find_member_bottomsheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showMoreMember(bool isHome) {
  showModalBottomSheet(
    context: Get.context!,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    constraints: BoxConstraints(maxHeight: Get.height - 45),
    shape: const RoundedRectangleBorder(
      // <-- SEE HERE
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(14.0),
      ),
    ),
    builder: (BuildContext context) {
      return MoreWorkspaceBottomSheet(
        isHome: isHome,
      );
    },
  );
}

class MoreWorkspaceBottomSheet extends StatefulWidget {
  final bool isHome;
  const MoreWorkspaceBottomSheet({super.key, required this.isHome});

  @override
  State<MoreWorkspaceBottomSheet> createState() =>
      _MoreWorkspaceBottomSheetState();
}

class _MoreWorkspaceBottomSheetState extends State<MoreWorkspaceBottomSheet> {
  List memberList = [];
  bool isFetching = false;
  Timer? _debounce;
  bool isLoadingMore = false;
  int offset = 0;
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
    await OrganApi().getOrganMembers(searchText, offset).then((res) {
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
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
      child: Column(
        children: [
          SizedBox(
            width: Get.width,
            child: Row(
              children: [
                const SizedBox(
                  width: 14,
                ),
                const Text(
                  "Nhân sự",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2329)),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                            builder: (context) => const FindMemberBottomSheet(),
                            isScrollControlled: true,
                            context: context);
                      },
                      icon: const Icon(
                        CupertinoIcons.person_add,
                        color: Colors.black,
                        size: 24,
                      )),
                )
              ],
            ),
          ),
          const Divider(
            height: 1,
            color: Color(0xFFFAF8FD),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CustomSearchBar(
              width: double.infinity,
              hintText: "Tìm kiếm thành viên",
              onQueryChanged: (value) {
                onDebounce((v) {
                  fetchMemberList(value);
                }, 800);
              },
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: isFetching && !isLoadingMore
                ? const ListPlaceholder(length: 11)
                : Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      RefreshIndicator(
                        onRefresh: onRefresh,
                        child: ListView.builder(
                          controller: sc,
                          itemBuilder: (context, index) {
                            return MemberItem(
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
                  ),
          )
        ],
      ),
    );
  }
}
