import 'dart:async';

import 'package:coka/api/organization.dart';
import 'package:coka/api/workspace.dart';
import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/components/placeholders.dart';
import 'package:coka/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showAddMember2Workspace(dataItem, isAdd) {
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
      return AddMemberBottomSheet(
        dataItem: dataItem,
        isAdd: isAdd,
      );
    },
  );
}

class AddMemberBottomSheet extends StatefulWidget {
  final Map dataItem;
  final Function isAdd;

  const AddMemberBottomSheet({
    super.key,
    required this.dataItem,
    required this.isAdd,
  });

  @override
  State<AddMemberBottomSheet> createState() => _AddMemberBottomSheetState();
}

class _AddMemberBottomSheetState extends State<AddMemberBottomSheet> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Nhân sự",
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SearchBar(
            leading: const Icon(Icons.search),
            hintText: "Tìm kiếm nhân sự",
            controller: searchController,
            backgroundColor: const WidgetStatePropertyAll(Color(0xFFF2F3F5)),
            onChanged: (value) {
              onDebounce(fetchMemberList, 800);
            },
          ),
        ),
        const Divider(
          height: 1,
          color: Color(0xFFFAF8FD),
        ),
        isFetching && !isLoadingMore
            ? const Expanded(child: ListPlaceholder(length: 12))
            : Expanded(
                child: Stack(
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
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            leading: avatar == null
                                ? createCircleAvatar(name: title, radius: 20)
                                : CircleAvatar(
                                    backgroundImage: getAvatarProvider(avatar),
                                    radius: 20,
                                  ),
                            trailing: IconButton(
                                onPressed: () {
                                  showLoadingDialog(context);
                                  WorkspaceApi()
                                      .addMember(widget.dataItem["id"],
                                          profile["profileId"])
                                      .then((res) {
                                    Get.back();
                                    if (isSuccessStatus(res["code"])) {
                                      widget.isAdd();
                                      successAlert(
                                          title: "Thành công",
                                          desc:
                                              "Đã thêm $title vào nhóm làm việc");
                                    } else {
                                      errorAlert(
                                          title: "Thất bại",
                                          desc: res["message"]);
                                    }
                                  });
                                },
                                icon: const Icon(Icons.person_add_outlined)),
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
    );
  }
}
