import 'package:coka/components/elevated_btn.dart';
import 'package:coka/components/placeholders.dart';
import 'package:coka/components/seemore_widget.dart';
import 'package:coka/components/workspace_item.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/home/pages/add_workspace_page.dart';
import 'package:coka/screen/home/components/more_workspace_bottomsheet.dart';
import 'package:coka/screen/workspace/main_binding.dart';
import 'package:coka/screen/workspace/main_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkspaceCard extends StatelessWidget {
  const WorkspaceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (controller) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: controller.isWorkspaceFetching.value
            ? const WorkspaceFetching()
            : controller.workGroupCardDataList.isEmpty
                ? const EmptyWorkspace()
                : WorkspaceList(dataList: controller.workGroupCardDataList),
      );
    });
  }
}

class WorkspaceList extends StatelessWidget {
  final List dataList;

  const WorkspaceList({super.key, required this.dataList});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (controller) {
      return Column(
        children: [
          const SizedBox(
            height: 15,
          ),
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
                if (controller.oData["type"] == "OWNER" ||
                    controller.oData["type"] == "ADMIN")
                  ElevatedBtn(
                      onPressed: () {
                        Get.to(() => AddWorkSpacePage(
                              onSuccess: () {},
                            ));
                      },
                      circular: 50,
                      paddingAllValue: 0,
                      child: const Icon(
                        Icons.add,
                        color: Colors.black,
                        size: 24,
                      )),
                const SizedBox(
                  width: 14,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          const Divider(
            color: Color(0xFFFAF8FD),
            height: 1,
          ),
          ListView.builder(
            itemBuilder: (context, index) {
              return Column(
                children: [
                  WorkspaceItem(
                    dataItem: dataList[index],
                    onTap: () {
                      controller.workGroupCardDataValue.value = dataList[index];
                      controller.update();
                      Get.to(() => const WorkspaceMainPage(),
                          binding: WorkspaceMainBinding(),
                          routeName: controller.workGroupCardDataValue["id"]);
                    },
                  ),
                  if (index == 3)
                    SeeMore(
                      onTap: () {
                        showMoreWorkspace(true);
                      },
                    )
                ],
              );
            },
            itemCount: dataList.length <= 4 ? dataList.length : 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          )
        ],
      );
    });
  }
}

class WorkspaceFetching extends StatelessWidget {
  const WorkspaceFetching({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 15,
        ),
        SizedBox(
          width: Get.width,
          child: const Row(
            children: [
              SizedBox(
                width: 14,
              ),
              Text(
                "Nhóm làm việc",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2329)),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        const Divider(
          color: Color(0xFFFAF8FD),
          height: 1,
        ),
        const ListPlaceholder(length: 2, avatarSize: 40, contentHeight: 12)
      ],
    );
  }
}

class EmptyWorkspace extends StatelessWidget {
  const EmptyWorkspace({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (controller) {
      return Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            width: Get.width,
            child: const Row(
              children: [
                SizedBox(
                  width: 14,
                ),
                Text(
                  "Nhóm làm việc",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2329)),
                ),
                Spacer(),
              ],
            ),
          ),
          Image.asset("assets/images/workspace_empty.png"),
          const Text(
            "Hiện chưa có nhóm làm việc nào",
            style: TextStyle(fontSize: 15, color: Colors.black),
          ),
          const SizedBox(
            height: 15,
          ),
          if (controller.oData["type"] == "OWNER" ||
              controller.oData["type"] == "ADMIN")
            ElevatedButton.icon(
              icon: const Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                Get.to(() => AddWorkSpacePage(onSuccess: () {}));
              },
              label: const Text(
                "Thêm nhóm",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5c33f0)),
            ),
          const SizedBox(
            height: 15,
          ),
        ],
      );
    });
  }
}
