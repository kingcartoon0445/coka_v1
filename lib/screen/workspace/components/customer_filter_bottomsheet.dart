import 'package:coka/api/customer.dart';
import 'package:coka/components/custom_chip_input.dart';
import 'package:coka/components/elevated_btn.dart';
import 'package:coka/models/chip_data.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/workspace/components/multi_select_assign_to_bottomsheet.dart';
import 'package:coka/screen/workspace/components/multi_select_rating_select_bottomsheet.dart';
import 'package:coka/screen/workspace/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../pages/add_customer.dart';
import '../pages/add_team.dart';
import 'multi_select_stage_select_bottomsheet.dart';

void showCustomerFilterBottomSheet() {
  WorkspaceMainController wmController = Get.put(WorkspaceMainController());
  wmController.isDismiss = false;
  showModalBottomSheet(
          context: Get.context!,
          builder: (context) => const CustomerFilterBottomSheet(),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.white,
          isScrollControlled: true)
      .then((value) => wmController.isDismiss = true);
}

class CustomerFilterBottomSheet extends StatefulWidget {
  const CustomerFilterBottomSheet({super.key});

  @override
  State<CustomerFilterBottomSheet> createState() =>
      _CustomerFilterBottomSheetState();
}

class _CustomerFilterBottomSheetState extends State<CustomerFilterBottomSheet> {
  List<ChipData> bonusTags = <ChipData>[];
  List<ChipData> bonusSources = <ChipData>[];
  bool isLoaded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final homeController = Get.put(HomeController());
    Future.wait([
      CustomerApi()
          .getTagList(homeController.workGroupCardDataValue["id"])
          .then((value) {
        setState(() {
          bonusTags =
              (value["content"] as List).map((e) => ChipData(e, e)).toList();
        });
      }),
      CustomerApi()
          .getSourceList(homeController.workGroupCardDataValue["id"])
          .then((value) {
        setState(() {
          bonusSources =
              (value["content"] as List).map((e) => ChipData(e, e)).toList();
        });
      })
    ]).then((value) {
      setState(() {
        isLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WorkspaceMainController>(builder: (controller) {
      return Container(
          height: Get.height - 100,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Text(
                      "Lọc khách hàng",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    ElevatedBtn(
                      circular: 8,
                      paddingAllValue: 2,
                      onPressed: () {
                        controller.clearFilter();
                        Get.back();
                        controller.onRefresh();
                      },
                      child: const Text(
                        "Xóa bộ lọc",
                        style:
                            TextStyle(fontSize: 12, color: Color(0xB21A1C1E)),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              const Divider(
                height: 1,
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isLoaded)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: buildChipInput(
                                    controller.sourceChipKey,
                                    controller.categoryChipKey,
                                    itemMenu: <ChipData>{
                                      ...sourceMenu,
                                      ...bonusSources
                                    }.toSet().toList(),
                                    onCategoryChange: (data) {
                                      controller.categoryList.value = data;
                                    },
                                    onSourceChange: (data) {
                                      controller.sourceList.value = data;
                                    },
                                    categoryInitValue:
                                        controller.categoryList.value,
                                    sourceInitValue:
                                        controller.sourceList.value,
                                  ),
                                ),
                              const SizedBox(
                                height: 8,
                              ),
                              buildFilterItem(
                                name: 'Đối tượng phụ trách',
                                title: "Chọn đối tượng phụ trách",
                                dataFilterList: [
                                  ...controller.memberFilterList,
                                  ...controller.teamFilterList
                                ],
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(12))),
                                    builder: (context) =>
                                        const MultiSelectAssignToBottomSheet(),
                                  );
                                },
                              ),
                              buildFilterItem(
                                  name: 'Trạng thái',
                                  title: "Chọn trạng thái",
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(12))),
                                      builder: (context) =>
                                          const MultiStageSelectBottomSheet(),
                                    );
                                  },
                                  dataFilterList: controller.stageFilterList),
                              if (isLoaded) buildTagFilterItem(controller),
                              buildFilterItem(
                                  name: 'Đánh giá',
                                  title: "Chọn đánh giá",
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(12))),
                                      builder: (context) =>
                                          const MultiRatingSelectBottomSheet(),
                                    );
                                  },
                                  dataFilterList: controller.ratingFilterList),
                              const Gap(300),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        bottom: 20,
                        right: 20,
                        child: ElevatedBtn(
                          onPressed: () {
                            Get.back();
                            controller.onRefresh();
                          },
                          circular: 50,
                          paddingAllValue: 0,
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF5C33F0)),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ))
                  ],
                ),
              ),
            ],
          ));
    });
  }

  Padding buildTagFilterItem(WorkspaceMainController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Nhãn",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(
            height: 6,
          ),
          CustomChipInput(
              itemInitValue:
                  controller.tagFilterList.map((e) => ChipData(e, e)).toList(),
              onItemChange: (p0) {
                controller.tagFilterList.value = p0.map((e) => e.id).toList();
              },
              showArrowDown: true,
              itemsMenu: <ChipData>{...tagMenu, ...bonusTags}.toSet().toList(),
              hintText: "Chọn nhãn khách hàng"),
        ],
      ),
    );
  }

  Padding buildFilterItem({
    required String name,
    required String title,
    required VoidCallback onPressed,
    required List dataFilterList,
  }) {
    final wmController = Get.put(WorkspaceMainController());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2329))),
          const SizedBox(
            height: 4,
          ),
          GestureDetector(
            onTap: onPressed,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: dataFilterList.isEmpty
                  ? Row(
                      children: [
                        Text(title,
                            style: const TextStyle(
                                color: Color(0xFF727272),
                                fontWeight: FontWeight.w500,
                                fontSize: 16)),
                        const Spacer(),
                        const Icon(
                          Icons.keyboard_arrow_down,
                        )
                      ],
                    )
                  : Wrap(
                      spacing: 8,
                      children: [
                        ...dataFilterList.map((e1) {
                          final label = name == "Đối tượng phụ trách"
                              ? e1?["profile"]?["fullName"] ?? e1["name"]
                              : name == "Trạng thái"
                                  ? e1["name"]
                                  : e1["name"];

                          return Chip(
                            label: Text(label),
                            onDeleted: () {
                              name == "Đối tượng phụ trách"
                                  ? {
                                      wmController.memberFilterList.removeWhere(
                                          (e2) =>
                                              e2["profileId"] ==
                                              e1["profileId"]),
                                      wmController.teamFilterList.removeWhere(
                                          (e2) => e2["id"] == e1["id"])
                                    }
                                  : name == "Trạng thái"
                                      ? wmController.stageFilterList
                                          .removeWhere(
                                              (e2) => e2["id"] == e1["id"])
                                      : wmController.ratingFilterList
                                          .removeWhere((e2) =>
                                              e2["value"] == e1["value"]);

                              wmController.update();
                            },
                          );
                        })
                      ],
                    ),
            ),
          )
        ],
      ),
    );
  }
}
