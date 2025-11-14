import 'package:coka/components/placeholders.dart';
import 'package:coka/screen/main/customer_controlller.dart';
import 'package:coka/screen/workspace/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'customer_item.dart';

class CustomerList extends StatelessWidget {
  final int groupIndex;
  const CustomerList({super.key, required this.groupIndex});

  @override
  Widget build(BuildContext context) {
    // 先尝试使用 CustomerHomeController，如果不存在则使用 WorkspaceMainController
    if (Get.isRegistered<CustomerHomeController>()) {
      return GetBuilder<CustomerHomeController>(
          builder: (controller) => _buildContent(controller));
    } else if (Get.isRegistered<WorkspaceMainController>()) {
      return GetBuilder<WorkspaceMainController>(
          builder: (controller) => _buildContent(controller));
    } else {
      // 如果两个控制器都不存在，返回空组件
      return const SizedBox.shrink();
    }
  }

  // 辅助方法：构建内容（两个控制器有相同的接口）
  Widget _buildContent(dynamic controller) {
      return Obx(() {
        return RefreshIndicator(
          onRefresh: () async {
            controller.onRefresh();
          },
          child: controller.isLoading[groupIndex]
              ? const ListCustomerPlaceholder(
                  length: 10,
                )
              : controller.isRoomEmpty.value
                  ? SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: Get.height - 120),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 50.0, right: 50, top: 20),
                              child: Image.asset(
                                "assets/images/null_customer.png",
                              ),
                            ),
                            const Text(
                              "Hiện chưa có khách hàng nào",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            )
                          ],
                        ),
                      ),
                    )
                  : Stack(
                      children: [
                        SingleChildScrollView(
                          controller: controller.sc,
                          physics: const ClampingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints:
                                BoxConstraints(minHeight: Get.height - 120),
                            child: Column(
                              children: [
                                ...controller.roomList[groupIndex]
                                    .map((e) => RoomItem(
                                          itemData: e,
                                          index: controller.roomList[groupIndex]
                                              .indexOf(e),
                                        ))
                              ],
                            ),
                          ),
                        ),
                        if (controller.isLoadingMore[groupIndex])
                          const Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 8.0),
                                child: CircularProgressIndicator(),
                              ))
                      ],
                    ),
        );
      });
  }
}
