import 'dart:async';

import 'package:coka/api/workspace.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/placeholders.dart';
import 'package:coka/components/workspace_item.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/workspace/getx/dashboard_controller.dart';
import 'package:coka/screen/workspace/getx/team_controller.dart';
import 'package:coka/screen/workspace/main_binding.dart';
import 'package:coka/screen/workspace/main_controller.dart';
import 'package:coka/screen/workspace/main_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/search_bar.dart';
import '../pages/add_workspace_page.dart';

void showMoreWorkspace(bool isHome) {
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
  final Function? funcAutomation;

  const MoreWorkspaceBottomSheet(
      {super.key, required this.isHome, this.funcAutomation});

  @override
  State<MoreWorkspaceBottomSheet> createState() =>
      _MoreWorkspaceBottomSheetState();
}

class _MoreWorkspaceBottomSheetState extends State<MoreWorkspaceBottomSheet> {
  List workspaceList = [];
  bool isFetching = false;
  Timer? _debounce;
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchWorkspaceList("");
  }

  Future fetchWorkspaceList(searchText) async {
    setState(() {
      isFetching = true;
    });
    await WorkspaceApi().getWorkspaceList(searchText).then((res) {
      setState(() {
        isFetching = false;
      });
      if (isSuccessStatus(res['code'])) {
        setState(() {
          workspaceList = res["content"];
        });
      } else {
        errorAlert(title: "Lỗi", desc: res['message']);
      }
    });
  }

  void onDebounce(Function(String) searchFunction, int debounceTime) {
    // Hủy bỏ bất kỳ timer nào nếu có
    _debounce?.cancel();

    // Tạo mới timer với thời gian debounce
    _debounce = Timer(Duration(milliseconds: debounceTime), () {
      // Lấy dữ liệu từ trường văn bản và gọi hàm tìm kiếm
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
                  "Nhóm làm việc",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2329)),
                ),
                const Spacer(),
                IconButton(
                    onPressed: () {
                      Get.to(() => AddWorkSpacePage(
                            onSuccess: () {
                              fetchWorkspaceList("");
                            },
                          ));
                    },
                    icon: const Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 30,
                    ))
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
              hintText: "Tìm kiếm nhóm làm việc",
              onQueryChanged: (value) {
                onDebounce((v) {
                  fetchWorkspaceList(value);
                }, 800);
              },
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: isFetching
                ? const ListPlaceholder(length: 10)
                : RefreshIndicator(
                    onRefresh: () {
                      return fetchWorkspaceList(searchController.text);
                    },
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return WorkspaceItem(
                          isShort: true,
                          dataItem: workspaceList[index],
                          onTap: () {
                            if (widget.funcAutomation != null) {
                              widget.funcAutomation!(workspaceList[index]);
                              return;
                            }
                            final homeController = Get.put(HomeController());
                            homeController.workGroupCardDataValue.value =
                                workspaceList[index];
                            homeController.update();
                            if (widget.isHome) {
                              Get.to(() => const WorkspaceMainPage(),
                                  binding: WorkspaceMainBinding(),
                                  routeName: homeController
                                      .workGroupCardDataValue["id"]);
                            } else {
                              final dashboardController =
                                  Get.put(DashboardController());
                              final wmController =
                                  Get.put(WorkspaceMainController());
                              final teamController =
                                  Get.put(Get.put(TeamController()));
                              teamController.fetchTeamList("");
                              wmController.getHintCustomer();
                              wmController.onRefresh();
                              dashboardController.onRefresh();
                              Get.back();
                            }
                          },
                        );
                      },
                      itemCount: workspaceList.length,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
