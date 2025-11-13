import 'package:coka/api/workspace.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/elevated_btn.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/components/placeholders.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/main/pages/detail_member.dart';
import 'package:coka/screen/workspace/components/add_member2workspace_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/auto_avatar.dart';

class WorkspaceMemberPage extends StatefulWidget {
  final Map dataItem;

  const WorkspaceMemberPage({super.key, required this.dataItem});

  @override
  State<WorkspaceMemberPage> createState() => _WorkspaceMemberPageState();
}

class _WorkspaceMemberPageState extends State<WorkspaceMemberPage> {
  var memberList = [];
  var isFetching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchMemberList();
  }

  Future fetchMemberList() async {
    setState(() {
      isFetching = true;
    });
    WorkspaceApi()
        .getWorkspaceMembersList(widget.dataItem["id"], "")
        .then((res) {
      setState(() {
        isFetching = false;
      });
      if (isSuccessStatus(res["code"])) {
        setState(() {
          memberList = res["content"];
        });
      } else {
        errorAlert(title: "Lỗi", desc: res["message"]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Danh sách thành viên",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2329)),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
              onPressed: () {
                showAddMember2Workspace(widget.dataItem, () {
                  fetchMemberList();
                });
              },
              icon: const Icon(Icons.person_add_outlined))
        ],
      ),
      body: isFetching
          ? const ListPlaceholder(length: 10)
          : RefreshIndicator(
              onRefresh: () {
                return fetchMemberList();
              },
              child: ListView.builder(
                  itemCount: memberList.length,
                  itemBuilder: (context, index) {
                    final profile = memberList[index]["profile"];
                    final title = profile?["fullName"] ?? "";
                    final subTitle = memberList[index]["type"] == "MEMBER"
                        ? "Thành viên"
                        : "Quản trị viên";
                    final avatar = profile?["avatar"];
                    return title == ""
                        ? Container()
                        : ListTile(
                            onTap: () {
                              Get.to(() => DetailMember(
                                  dataItem: profile, isMyProfile: false));
                            },
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 16),
                            dense: true,
                            title: Text(title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(subTitle),
                            leading: avatar == null
                                ? createCircleAvatar(name: title, radius: 20)
                                : CircleAvatar(
                                    backgroundImage: getAvatarProvider(avatar),
                                    radius: 20,
                                  ),
                            trailing: MenuAnchor(
                              alignmentOffset: const Offset(-110, 0),
                              menuChildren: [
                                SubmenuButton(menuChildren: [
                                  if (memberList[index]["type"] != "OWNER")
                                    MenuItemButton(
                                      child: const Text("Quản trị viên",
                                          style:
                                              TextStyle(color: Colors.black)),
                                      onPressed: () {
                                        showLoadingDialog(context);
                                        WorkspaceApi()
                                            .grantRole(widget.dataItem["id"],
                                                profile["id"], "OWNER")
                                            .then((res) {
                                          Get.back();
                                          if (isSuccessStatus(res["code"])) {
                                            fetchMemberList();
                                            successAlert(
                                                title: "Thành công",
                                                desc:
                                                    "$title đã trở thành quản trị viên");
                                          } else {
                                            errorAlert(
                                                title: "Thất bại",
                                                desc: res["message"]);
                                          }
                                        });
                                      },
                                    ),
                                  if (memberList[index]["type"] != "MEMBER")
                                    MenuItemButton(
                                        child: const Text(
                                          "Thành viên",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        onPressed: () {
                                          showLoadingDialog(context);
                                          WorkspaceApi()
                                              .grantRole(widget.dataItem["id"],
                                                  profile["id"], "MEMBER")
                                              .then((res) {
                                            Get.back();
                                            if (isSuccessStatus(res["code"])) {
                                              fetchMemberList();
                                              successAlert(
                                                  title: "Thành công",
                                                  desc:
                                                      "$title đã bị hạ cấp xuống thành viên");
                                            } else {
                                              errorAlert(
                                                  title: "Thất bại",
                                                  desc: res["message"]);
                                            }
                                          });
                                        }),
                                ], child: const Text("Phân quyền")),
                                MenuItemButton(
                                    child: const Text(
                                      "Xoá thành viên",
                                      style:
                                          TextStyle(color: Color(0xFFB2261F)),
                                    ),
                                    onPressed: () {
                                      warningAlert(
                                          title: "Xoá thành viên?",
                                          desc: "Bạn có chắc muốn xoá $title ?",
                                          btnOkOnPress: () {
                                            showLoadingDialog(context);
                                            WorkspaceApi()
                                                .deleteMemberWorkspace(
                                                    profile["id"])
                                                .then((res) {
                                              Get.back();
                                              if (isSuccessStatus(
                                                  res["code"])) {
                                                fetchMemberList();
                                                successAlert(
                                                    title: "Thành công",
                                                    desc:
                                                        "Đã xóa $title ra khỏi nhóm làm việc");
                                              } else {
                                                errorAlert(
                                                    title: "Thất bại",
                                                    desc: res["message"]);
                                              }
                                            });
                                          });
                                    }),
                              ],
                              builder: (context, controller, child) =>
                                  ElevatedBtn(
                                      onPressed: () {
                                        if (controller.isOpen) {
                                          controller.close();
                                        } else {
                                          controller.open();
                                        }
                                      },
                                      paddingAllValue: 2,
                                      circular: 50,
                                      child: const Icon(
                                        Icons.more_vert,
                                        size: 25,
                                      )),
                            ),
                          );
                  },
                  shrinkWrap: true),
            ),
    );
  }
}
