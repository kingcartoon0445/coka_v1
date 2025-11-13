import 'dart:async';
import 'dart:math';
import 'package:coka/api/team.dart';
import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/custom_expansion_title.dart';
import 'package:coka/components/elevated_btn.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/components/placeholders.dart';
import 'package:coka/constants.dart';
import 'package:coka/models/find_child.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/workspace/components/add_leader2team_bottomsheet.dart';
import 'package:coka/screen/workspace/getx/team_controller.dart';
import 'package:coka/screen/workspace/pages/customer_route_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../components/search_bar.dart';
import '../components/invite_m2t_bottomsheet.dart';
import 'add_team.dart';
import 'multi_connect.dart';

class TeamPage extends StatefulWidget {
  final String? parentId;

  const TeamPage({super.key, this.parentId});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  TeamController teamController = Get.put(TeamController());
  final homeController = Get.put(HomeController());
  final searchText = TextEditingController();
  Map teamChild = {};
  List teamList = [];
  List leadList = [];
  var filteredTeam = [];

  Timer? _debounce;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    teamController.memberList.clear();

    if (teamList.isEmpty && widget.parentId != null) {
      Timer(const Duration(milliseconds: 100),
          () => teamController.fetchMemberList(widget.parentId, ""));
    }
  }

  onTeamSearchChanged(String query) {
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
      print(filteredTeam.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TeamController>(builder: (controller) {
      teamList = (widget.parentId == null)
          ? teamController.teamList
          : findBranchWithParentId(
                  teamController.teamList, widget.parentId!)?["childs"] ??
              [];
      teamChild = (widget.parentId == null)
          ? {
              "isAutoAssignRule":
                  homeController.workGroupCardDataValue["isAutoAssignRule"],
              "isAutomation":
                  homeController.workGroupCardDataValue["isAutomation"]
            }
          : findBranchWithParentId(teamController.teamList, widget.parentId) ??
              {};
      teamList = teamChild["childs"] ?? teamList;
      leadList = teamChild["managers"] ?? [];
      final isTeamEmpty =
          (teamList.isEmpty && widget.parentId == null) ? true : false;
      if (searchText.text == "") filteredTeam = teamList;
      final teamMenuList = [
        if (widget.parentId != null)
          {
            "id": "edit",
            "icon": const Icon(Icons.edit),
            "name": "Chỉnh sửa đội sale",
            "onPress": () {
              Get.to(() => EditTeam(
                    teamId: widget.parentId,
                    dataItem: teamChild,
                  ));
            }
          },
        {
          "id": "route_config",
          "icon": const Icon(
            Icons.route,
            color: Colors.black,
          ),
          "name": "Cấu hình định tuyến",
          "onPress": () {
            Get.to(() => CustomerRouteConfig(
                  teamId: widget.parentId,
                  isRaw: widget.parentId != null ? false : true,
                  dataItem: teamChild,
                ));
          }
        },
        if (widget.parentId != null)
          {
            "id": "add_leader",
            "icon": const Icon(Icons.manage_accounts),
            "name": "Thêm trưởng nhóm",
            "onPress": () {
              showAddLeader2Team(widget.parentId);
            }
          },
        if (widget.parentId != null)
          {
            "id": "delete",
            "icon": const Icon(Icons.person),
            "name": "Xoá đội sale",
            "onPress": () {
              warningAlert(
                  title: "Xóa đội sale?",
                  desc: "Bạn có chắc muốn xóa đội sale này?",
                  btnOkOnPress: () {
                    showLoadingDialog(context);
                    TeamApi()
                        .deleteTeam(homeController.workGroupCardDataValue["id"],
                            widget.parentId)
                        .then((res) {
                      Get.back();
                      try {
                        if (isSuccessStatus(res["code"])) {
                          teamController.fetchTeamList(searchText.text);
                          Get.back();
                        } else {
                          errorAlert(title: "Lỗi", desc: res["message"]);
                        }
                      } catch (e) {
                        print(e);
                      }
                    });
                  });
            }
          },
      ];

      return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: InkWell(
            onTap: () {
              if (teamList.isNotEmpty) {
                showTreeViewBottomSheet(context);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: Get.width - 180,
                  child: Text(
                    widget.parentId == null ? "Đội sale" : teamChild["name"],
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2329)),
                  ),
                ),
                const SizedBox(
                  width: 3,
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFF1F2329),
                )
              ],
            ),
          ),
          actions: [
            MenuAnchor(
              alignmentOffset: const Offset(-165, 0),
              menuChildren: [
                ...teamMenuList.map((e) {
                  return MenuItemButton(
                    leadingIcon: e["icon"] as Widget,
                    onPressed: e["onPress"] as Function(),
                    child: Text(
                      e["name"] as String,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  );
                })
              ],
              builder: (context, controller, child) {
                return ElevatedBtn(
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  circular: 50,
                  paddingAllValue: 4,
                  child: const Icon(
                    Icons.more_vert,
                    size: 30,
                  ),
                );
              },
            ),
            const SizedBox(
              width: 16,
            ),
          ],
          centerTitle: true,
          automaticallyImplyLeading: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16, top: 16),
              child: Row(
                children: [
                  CustomSearchBar(
                    width: Get.width - 110,
                    hintText: "Tìm kiếm",
                    onQueryChanged: (value) {
                      searchText.text = value;
                      onTeamSearchChanged(value);
                    },
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      if (widget.parentId == null || teamList.isNotEmpty) {
                        Get.to(() => AddTeam(
                              parentId: widget.parentId,
                            ));
                      } else if (controller.memberList.isNotEmpty) {
                        showInviteM2TMember(widget.parentId);
                      } else {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) =>
                              AddConnectLayout(parentId: widget.parentId),
                        );
                      }
                    },
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF2F3F5),
                        minimumSize: const Size(55, 55)),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
                child: controller.isFetching.value
                    ? const ListPlaceholder(
                        length: 10,
                        avatarSize: 44,
                      )
                    : RefreshIndicator(
                        onRefresh: () {
                          return controller.fetchTeamList("");
                        },
                        child: isTeamEmpty
                            ? SingleChildScrollView(
                                child: SizedBox(
                                  height: 600,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16.0, horizontal: 8),
                                        child: Image.asset(
                                          "assets/images/team_empty.png",
                                        ),
                                      ),
                                      const Text(
                                        "Hiện chưa có đội sale nào",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 16),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : filteredTeam.isNotEmpty
                                ? SingleChildScrollView(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                          minHeight: Get.height - 120),
                                      child: ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) =>
                                            MenuAnchor(
                                                alignmentOffset:
                                                    const Offset(16, 0),
                                                menuChildren: [
                                                  MenuItemButton(
                                                      onPressed: () {
                                                        Get.to(() => EditTeam(
                                                              teamId:
                                                                  filteredTeam[
                                                                          index]
                                                                      ["id"],
                                                              dataItem:
                                                                  filteredTeam[
                                                                      index],
                                                            ));
                                                      },
                                                      child: const Row(
                                                        children: [
                                                          Icon(
                                                            Icons.edit,
                                                            color: Colors.black,
                                                          ),
                                                          SizedBox(
                                                            width: 4,
                                                          ),
                                                          Text("Chỉnh sửa team",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black)),
                                                        ],
                                                      )),
                                                  MenuItemButton(
                                                      onPressed: () {
                                                        Get.to(() =>
                                                            CustomerRouteConfig(
                                                              teamId:
                                                                  filteredTeam[
                                                                          index]
                                                                      ["id"],
                                                              isRaw: false,
                                                              dataItem:
                                                                  filteredTeam[
                                                                      index],
                                                            ));
                                                      },
                                                      child: const Row(
                                                        children: [
                                                          Icon(
                                                            Icons.route,
                                                            color: Colors.black,
                                                          ),
                                                          SizedBox(
                                                            width: 4,
                                                          ),
                                                          Text(
                                                              "Cấu hình định tuyến",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black)),
                                                        ],
                                                      )),
                                                  MenuItemButton(
                                                      onPressed: () {
                                                        showAddLeader2Team(
                                                            filteredTeam[index]
                                                                ["id"]);
                                                      },
                                                      child: const Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .manage_accounts,
                                                            color: Colors.black,
                                                          ),
                                                          SizedBox(
                                                            width: 4,
                                                          ),
                                                          Text(
                                                              "Thêm trưởng nhóm",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black)),
                                                        ],
                                                      )),
                                                  MenuItemButton(
                                                      onPressed: () {
                                                        warningAlert(
                                                            title:
                                                                "Xóa đội sale?",
                                                            desc:
                                                                "Bạn có chắc muốn xóa đội sale này?",
                                                            btnOkOnPress: () {
                                                              showLoadingDialog(
                                                                  context);
                                                              TeamApi()
                                                                  .deleteTeam(
                                                                      homeController
                                                                              .workGroupCardDataValue[
                                                                          "id"],
                                                                      filteredTeam[
                                                                              index]
                                                                          [
                                                                          "id"])
                                                                  .then((res) {
                                                                Get.back();
                                                                try {
                                                                  if (isSuccessStatus(
                                                                      res["code"])) {
                                                                    teamController
                                                                        .fetchTeamList(
                                                                            searchText.text);
                                                                  } else {
                                                                    errorAlert(
                                                                        title:
                                                                            "Lỗi",
                                                                        desc: res[
                                                                            "message"]);
                                                                  }
                                                                } catch (e) {
                                                                  print(e);
                                                                  Get.back();
                                                                }
                                                              });
                                                            });
                                                      },
                                                      child: const Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .delete_outline,
                                                            color: Colors.black,
                                                          ),
                                                          SizedBox(
                                                            width: 4,
                                                          ),
                                                          Text("Xóa team",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black)),
                                                        ],
                                                      ))
                                                ],
                                                builder: (context, c, child) {
                                                  final itemData =
                                                      filteredTeam[index];
                                                  return ListTile(
                                                      title: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          SizedBox(
                                                            width:
                                                                Get.width - 160,
                                                            child: Text(
                                                              itemData["name"],
                                                              style: const TextStyle(
                                                                  fontSize: 14,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Color(
                                                                      0xFF1F2329)),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          if (itemData[
                                                              "isAutomation"])
                                                            Tooltip(
                                                              triggerMode:
                                                                  TooltipTriggerMode
                                                                      .tap,
                                                              waitDuration:
                                                                  const Duration(
                                                                      seconds:
                                                                          4),
                                                              message: itemData[
                                                                      "isAutomation"]
                                                                  ? "Phân phối khách hàng tự động"
                                                                  : "Phân phối khách hàng thủ công",
                                                              child: Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        6,
                                                                    vertical:
                                                                        3),
                                                                decoration: BoxDecoration(
                                                                    color: const Color(
                                                                        0xFFE3DEF7),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12)),
                                                                child: Text(
                                                                  itemData[
                                                                          "isAutomation"]
                                                                      ? "Tự động"
                                                                      : "Thủ công",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          9,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ),
                                                            )
                                                        ],
                                                      ),
                                                      subtitle: Text(itemData[
                                                                      "managers"]
                                                                  .length ==
                                                              0
                                                          ? "Chưa có trưởng nhóm"
                                                          : itemData["managers"]
                                                              [0]["fullName"]),
                                                      onTap: () {
                                                        Get.to(
                                                            () => TeamPage(
                                                                  parentId:
                                                                      itemData[
                                                                          "id"],
                                                                ),
                                                            routeName: itemData[
                                                                    "id"]
                                                                .toString());
                                                      },
                                                      onLongPress: () {
                                                        if (c.isOpen) {
                                                          c.close();
                                                        } else {
                                                          c.open();
                                                        }
                                                      },
                                                      leading:
                                                          createCircleAvatar(
                                                              name: itemData[
                                                                  "name"],
                                                              radius: 22));
                                                }),
                                        shrinkWrap: true,
                                        itemCount: filteredTeam.length,
                                      ),
                                    ),
                                  )
                                : leadList.isNotEmpty
                                    ? RefreshIndicator(
                                        onRefresh: () {
                                          controller.fetchTeamList("");
                                          return controller.fetchMemberList(
                                              widget.parentId, "");
                                        },
                                        child: SingleChildScrollView(
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                                minHeight: Get.height - 120),
                                            child: Column(
                                              children: [
                                                buildLeaderListView(controller),
                                                const Divider(),
                                                buildMemberListView(controller),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : RefreshIndicator(
                                        onRefresh: () {
                                          return controller.fetchMemberList(
                                              widget.parentId, "");
                                        },
                                        child: SingleChildScrollView(
                                          child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  minHeight: Get.height - 120),
                                              child: buildMemberListView(
                                                  controller)),
                                        ),
                                      ),
                      )),
          ],
        ),
      );
    });
  }

  void showTreeViewBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return DraggableScrollableSheet(
            expand: false,
            snap: false,
            minChildSize: 0.4,
            builder: (context, controller) {
              return Theme(
                data: ThemeData(
                  dividerColor: Colors.transparent,
                ),
                child: SingleChildScrollView(
                  controller: controller,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 14,
                      ),
                      Text(
                        widget.parentId == null
                            ? "Đội sale"
                            : teamChild["name"],
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2329)),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      // const Divider(),
                      ...buildMultiWidgetList(
                        teamList,
                        (data) {
                          Get.to(
                              () => TeamPage(
                                    parentId: data["id"],
                                  ),
                              routeName: data["id"].toString());
                        },
                      ),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }

  ListView buildLeaderListView(TeamController controller) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final profile = leadList[index];
        final role =
            profile["role"] == "TEAM_LEADER" ? "Trưởng nhóm" : "Phó nhóm";
        return ListTile(
            title: Text(
              profile["fullName"],
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, color: Color(0xFF1F2329)),
            ),
            subtitle: Text(role),
            onTap: () {},
            trailing: MenuAnchor(
                builder: (context, controller, child) {
                  return ElevatedBtn(
                    paddingAllValue: 0,
                    circular: 50,
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    child: const Icon(
                      Icons.more_vert,
                      size: 30,
                    ),
                  );
                },
                menuChildren: [
                  SubmenuButton(
                    menuChildren: [
                      MenuItemButton(
                        child: const Text(
                          "Trưởng nhóm",
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () {
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
                                            .workGroupCardDataValue["id"],
                                        widget.parentId,
                                        profile["profileId"],
                                        "TEAM_LEADER")
                                    .then((res) {
                                  Get.back();
                                  if (isSuccessStatus(res["code"])) {
                                    controller.fetchTeamList("");
                                    controller.fetchMemberList(
                                        widget.parentId, searchText.text);
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
                      ),
                      MenuItemButton(
                        child: const Text(
                          "Phó nhóm",
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () {
                          warningAlert(
                              title: "Đặt làm phó nhóm",
                              nameOkBtn: "Đồng ý",
                              desc:
                                  "Bạn có chắc muốn đặt ${profile["fullName"]} làm phó nhóm?",
                              btnOkOnPress: () {
                                showLoadingDialog(context);
                                TeamApi()
                                    .setRole(
                                        homeController
                                            .workGroupCardDataValue["id"],
                                        widget.parentId,
                                        profile["profileId"],
                                        "VICE_TEAM")
                                    .then((res) {
                                  Get.back();
                                  if (isSuccessStatus(res["code"])) {
                                    controller.fetchTeamList("");
                                    controller.fetchMemberList(
                                        widget.parentId, searchText.text);
                                    successAlert(
                                        title: "Thành công",
                                        desc:
                                            "Đã đặt ${profile["fullName"]} làm phó nhóm");
                                  } else {
                                    errorAlert(
                                        title: "Thất bại",
                                        desc: res["message"]);
                                  }
                                });
                              });
                        },
                      ),
                      MenuItemButton(
                        child: const Text(
                          "Thành viên",
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () {
                          warningAlert(
                              title: "Đặt làm thành viên",
                              nameOkBtn: "Đồng ý",
                              desc:
                                  "Bạn có chắc muốn hạ ${profile["fullName"]} làm thành viên?",
                              btnOkOnPress: () {
                                showLoadingDialog(context);
                                TeamApi()
                                    .setRole(
                                        homeController
                                            .workGroupCardDataValue["id"],
                                        widget.parentId,
                                        profile["profileId"],
                                        "MEMBER")
                                    .then((res) {
                                  Get.back();
                                  if (isSuccessStatus(res["code"])) {
                                    controller.fetchTeamList("");
                                    controller.fetchMemberList(
                                        widget.parentId, searchText.text);
                                    successAlert(
                                        title: "Thành công",
                                        desc:
                                            "Đã hạ ${profile["fullName"]} làm thành viên");
                                  } else {
                                    errorAlert(
                                        title: "Thất bại",
                                        desc: res["message"]);
                                  }
                                });
                              });
                        },
                      )
                    ],
                    leadingIcon: const Icon(Icons.manage_accounts),
                    child: const Text(
                      "Phân quyền",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.delete),
                    onPressed: () {
                      warningAlert(
                          title: "Xóa trưởng nhóm",
                          desc: "Bạn có chắc muốn xóa ${profile["fullName"]}?",
                          btnOkOnPress: () {
                            showLoadingDialog(context);

                            TeamApi()
                                .deleteManager(
                                    homeController.workGroupCardDataValue["id"],
                                    widget.parentId,
                                    profile["profileId"])
                                .then((res) {
                              Get.back();
                              if (isSuccessStatus(res["code"])) {
                                controller.fetchTeamList("");
                                controller.fetchMemberList(widget.parentId, "");
                                successAlert(
                                    title: "Thành công",
                                    desc: "Đã xóa người này");
                              } else {
                                errorAlert(
                                    title: "Thất bại", desc: res["message"]);
                              }
                            });
                          });
                    },
                    child: const Text(
                      "Xóa trưởng nhóm",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ]),
            leading: profile['avatar'] == null
                ? createCircleAvatar(name: profile["fullName"], radius: 22)
                : CircleAvatar(
                    backgroundImage:
                        getAvatarProvider(profile['avatar'] ?? defaultAvatar),
                    radius: 22,
                  ));
      },
      shrinkWrap: true,
      itemCount: leadList.length,
    );
  }

  ListView buildMemberListView(TeamController controller) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final profile = controller.memberList[index]["profile"];
        return ListTile(
            title: Text(
              profile["fullName"],
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, color: Color(0xFF1F2329)),
            ),
            subtitle: const Text("Thành viên"),
            onTap: () {},
            trailing: MenuAnchor(
                builder: (context, controller, child) {
                  return ElevatedBtn(
                    paddingAllValue: 0,
                    circular: 50,
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    child: const Icon(
                      Icons.more_vert,
                      size: 30,
                    ),
                  );
                },
                menuChildren: [
                  SubmenuButton(
                    menuChildren: [
                      MenuItemButton(
                        child: const Text(
                          "Trưởng nhóm",
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () {
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
                                            .workGroupCardDataValue["id"],
                                        widget.parentId,
                                        profile["id"],
                                        "TEAM_LEADER")
                                    .then((res) {
                                  Get.back();
                                  if (isSuccessStatus(res["code"])) {
                                    controller.fetchTeamList("");
                                    controller.fetchMemberList(
                                        widget.parentId, searchText.text);
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
                      ),
                      MenuItemButton(
                        child: const Text(
                          "Phó nhóm",
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () {
                          warningAlert(
                              title: "Đặt làm phó nhóm",
                              nameOkBtn: "Đồng ý",
                              desc:
                                  "Bạn có chắc muốn đặt ${profile["fullName"]} làm phó nhóm?",
                              btnOkOnPress: () {
                                showLoadingDialog(context);
                                TeamApi()
                                    .setRole(
                                        homeController
                                            .workGroupCardDataValue["id"],
                                        widget.parentId,
                                        profile["id"],
                                        "VICE_TEAM")
                                    .then((res) {
                                  Get.back();
                                  if (isSuccessStatus(res["code"])) {
                                    controller.fetchTeamList("");
                                    controller.fetchMemberList(
                                        widget.parentId, searchText.text);
                                    successAlert(
                                        title: "Thành công",
                                        desc:
                                            "Đã đặt ${profile["fullName"]} làm phó nhóm");
                                  } else {
                                    errorAlert(
                                        title: "Thất bại",
                                        desc: res["message"]);
                                  }
                                });
                              });
                        },
                      ),
                    ],
                    leadingIcon: const Icon(Icons.manage_accounts),
                    child: const Text(
                      "Phân quyền",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.delete),
                    onPressed: () {
                      warningAlert(
                          title: "Xóa thành viên",
                          desc: "Bạn có chắc muốn xóa ${profile["fullName"]}?",
                          btnOkOnPress: () {
                            showLoadingDialog(context);
                            TeamApi()
                                .deleteMember(
                                    homeController.workGroupCardDataValue["id"],
                                    widget.parentId,
                                    profile["id"])
                                .then((res) {
                              Get.back();
                              if (isSuccessStatus(res["code"])) {
                                controller.fetchMemberList(widget.parentId, "");
                                successAlert(
                                    title: "Thành công",
                                    desc: "Đã xóa thành viên này");
                              } else {
                                errorAlert(
                                    title: "Thất bại", desc: res["message"]);
                              }
                            });
                          });
                    },
                    child: const Text(
                      "Xóa thành viên",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ]),
            leading: profile['avatar'] == null
                ? createCircleAvatar(name: profile["fullName"], radius: 22)
                : CircleAvatar(
                    backgroundImage:
                        getAvatarProvider(profile['avatar'] ?? defaultAvatar),
                    radius: 22,
                  ));
      },
      shrinkWrap: true,
      itemCount: controller.memberList.length,
    );
  }
}

class AddConnectLayout extends StatelessWidget {
  final String? parentId;

  const AddConnectLayout({super.key, this.parentId});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(18.0),
              child: Text("Thêm đội hoặc thành viên",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ),
            Divider(
              height: 1,
              color: Colors.black.withOpacity(0.2),
            ),
            const SizedBox(
              height: 14,
            ),
            buildConnectBtn(
              icon: const Icon(Icons.group_add_outlined,
                  size: 40, color: Color(0xFF4C4C4C)),
              name: "Tạo đội",
              onTap: () {
                Get.back();
                Get.to(() => AddTeam(
                      parentId: parentId,
                    ));
              },
            ),
            buildConnectBtn(
              icon: const Icon(Icons.person_add_alt_1_outlined,
                  size: 40, color: Color(0xFF4C4C4C)),
              name: "Thêm thành viên",
              onTap: () {
                Get.back();
                showInviteM2TMember(parentId);
              },
            ),
            const SizedBox(
              height: 14,
            ),
          ],
        ),
      ],
    );
  }
}

Iterable buildMultiWidgetList(List childs, dynamic Function(Map)? onTap) {
  return childs.map((e) {
    final name = e["name"];
    final managers = e["managers"] ?? [];
    final List childs_1 = e["childs"] ?? [];
    return CExpansionTile(
        name: name,
        childs: childs_1,
        managers: managers,
        onTap: () => onTap!(e));
  });
}

class CExpansionTile extends StatefulWidget {
  final String name;
  final List managers, childs;
  final Function()? onTap;
  const CExpansionTile(
      {super.key,
      required this.name,
      required this.managers,
      required this.childs,
      this.onTap});

  @override
  State<CExpansionTile> createState() => _CExpansionTileState();
}

class _CExpansionTileState extends State<CExpansionTile>
    with SingleTickerProviderStateMixin {
  late Animation angleAni;
  late AnimationController _controller;
  bool isExpanded = false;
  CustomExpansionTileController cETController = CustomExpansionTileController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    angleAni = Tween(begin: 0.0, end: pi / 2).animate(_controller);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomExpansionTile(
      controller: cETController,
      childrenPadding: const EdgeInsets.only(left: 26),
      tilePadding: const EdgeInsets.only(
        left: 4,
      ),
      collapsedIconColor: Colors.transparent,
      iconColor: Colors.transparent,
      onListTileTap: widget.onTap,
      title: Text(
        widget.name,
        style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1F2329),
            fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        widget.managers.isEmpty
            ? "Chưa có trưởng nhóm"
            : widget.managers[0]["fullName"],
        style: const TextStyle(fontSize: 12, color: Color(0xFF646A72)),
      ),
      initiallyExpanded: isExpanded,
      onExpansionChanged: (value) {
        setState(() {
          isExpanded = value;
        });
        if (isExpanded) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      },
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (cETController.isExpanded) {
                cETController.collapse();
              } else {
                cETController.expand();
              }
            },
            child: Container(
              height: double.infinity,
              width: 38,
              color: Colors.transparent,
              child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: angleAni.value,
                      child: const Icon(
                        Icons.arrow_right,
                        size: 28,
                        color: Colors.black,
                      ),
                    );
                  }),
            ),
          ),
          createCircleAvatar(name: widget.name, radius: 18),
        ],
      ),
      children: [
        ...buildMultiWidgetList(
          widget.childs,
          (data) {
            Get.to(
                () => TeamPage(
                      parentId: data["id"],
                    ),
                routeName: data["id"].toString());
          },
        )
      ],
    );
  }
}
