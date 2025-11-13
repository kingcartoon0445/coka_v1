import 'dart:async';

import 'package:coka/api/team.dart';
import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/placeholders.dart';
import 'package:coka/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../add_applet_controller.dart';

class AssignUserBottomSheet extends StatefulWidget {
  final Function onSubmit;
  final List selectedList;

  const AssignUserBottomSheet(
      {super.key, required this.onSubmit, required this.selectedList});

  @override
  State<AssignUserBottomSheet> createState() => _AssignUserBottomSheetState();
}

class _AssignUserBottomSheetState extends State<AssignUserBottomSheet> {
  var memberList = [];
  var selectedList = [];
  Timer? _debounce;
  List<bool>? selected;
  var isMemberFetching = false;

  TextEditingController searchMemberController = TextEditingController();
  final addAppletController = Get.put(AddAppletController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchMemberList("").then((value) {
      selected = createFalseList(memberList.length);
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
            addAppletController.currentWorkspace["id"], searchText)
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
                const Text("Chọn thành viên để chia tỉ lệ",
                    style: TextStyle(
                        color: Color(0xFF1F2329),
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                    onPressed: () {
                      selectedList.clear();
                      for (var x = 0; x < memberList.length; x++) {
                        if (selected![x]) {
                          selectedList.add(memberList[x]);
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
                        final avatar = memberList[index]["profile"]["avatar"];
                        final fullName =
                            memberList[index]["profile"]["fullName"];
                        final subtitle = memberList[index]["team"]["name"];
                        return buildListTile(avatar, fullName, subtitle,
                            isMember: true,
                            isSelected: selected?[index], onChange: (value) {
                          setState(() {
                            selected?[index] = value;
                          });
                        });
                      },
                      itemCount: memberList.length,
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
