import 'package:coka/api/workspace.dart';
import 'package:coka/components/auto_avatar.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/components/custom_switch.dart';
import 'package:coka/components/dashboard_fetching_layout.dart';
import 'package:coka/components/elevated_btn.dart';
import 'package:coka/components/loading_dialog.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/components/more_workspace_bottomsheet.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/home/pages/add_workspace_page.dart';
import 'package:coka/screen/workspace/getx/dashboard_controller.dart';
import 'package:coka/screen/workspace/pages/rankingSale.dart';
import 'package:coka/screen/workspace/pages/workspace_members_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class WorkspaceDashboardPage extends StatefulWidget {
  const WorkspaceDashboardPage({super.key});

  @override
  State<WorkspaceDashboardPage> createState() => _WorkspaceDashboardPageState();
}

class _WorkspaceDashboardPageState extends State<WorkspaceDashboardPage> {
  HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (controller) {
      final dashboardMenuList = [
        {
          "id": "edit",
          "icon": const Icon(Icons.edit),
          "name": "Chỉnh sửa",
          "onPress": (dataItem) {
            Get.to(
                () => AddWorkSpacePage(dataItem: dataItem, onSuccess: () {}));
          }
        },
        {
          "id": "edit",
          "icon": const Icon(Icons.person),
          "name": "Danh sách thành viên",
          "onPress": (dataItem) {
            Get.to(() => WorkspaceMemberPage(dataItem: dataItem));
          }
        },
        if (controller.isDeleteAble.value)
          {
            "id": "delete",
            "icon": const Icon(Icons.delete_outline),
            "name": "Xóa nhóm làm việc",
            "onPress": (dataItem) {
              warningAlert(
                  title: "Xoá nhóm làm việc?",
                  desc: "Bạn có chắc muốn xoá nhóm làm việc này ?",
                  btnOkOnPress: () {
                    showLoadingDialog(Get.context!);
                    WorkspaceApi().deleteWorkspace().then((res) {
                      Get.back();
                      if (isSuccessStatus(res["code"])) {
                        final homeController = Get.put(HomeController());
                        Get.back();
                        homeController.workGroupCardDataValue.clear();
                        homeController.onRefresh();
                        successAlert(
                            title: "Thành công", desc: "Đã xóa nhóm làm việc");
                      } else {
                        errorAlert(title: "Thất bại", desc: res["message"]);
                      }
                    });
                  });
            }
          },
        if (homeController.workGroupCardDataValue["type"] != "ADMIN" &&
            homeController.workGroupCardDataValue["type"] != "OWNER")
          {
            "id": "leave",
            "icon": const Icon(Icons.delete_outline),
            "name": "Rời nhóm làm việc",
            "onPress": (dataItem) {
              warningAlert(
                  title: "Rời nhóm làm việc?",
                  desc: "Bạn có chắc muốn rời nhóm làm việc này ?",
                  nameOkBtn: "Rời",
                  btnOkOnPress: () {
                    showLoadingDialog(Get.context!);
                    WorkspaceApi().leaveWorkspace().then((res) {
                      Get.back();
                      if (isSuccessStatus(res["code"])) {
                        final homeController = Get.put(HomeController());
                        Get.back();
                        homeController.workGroupCardDataValue.clear();
                        homeController.onRefresh();
                        successAlert(
                            title: "Thành công", desc: "Đã rời nhóm làm việc");
                      } else {
                        errorAlert(title: "Thất bại", desc: res["message"]);
                      }
                    });
                  });
            }
          },
      ];
      return Scaffold(
        backgroundColor: const Color(0xFFF2F3F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: ElevatedBtn(
            onPressed: () {
              showMoreWorkspace(false);
            },
            paddingAllValue: 4,
            circular: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    homeController.workGroupCardDataValue["name"],
                    style: const TextStyle(
                        color: Color(0xFF1F2329),
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                const Icon(
                  Icons.keyboard_arrow_down_sharp,
                  size: 24,
                ),
              ],
            ),
          ),
          automaticallyImplyLeading: true,
          actions: [
            MenuAnchor(
              alignmentOffset: const Offset(-165, 0),
              menuChildren: [
                ...dashboardMenuList.map((e) {
                  return MenuItemButton(
                    leadingIcon: e["icon"] as Widget,
                    onPressed: () {
                      (e["onPress"]
                          as Function)(homeController.workGroupCardDataValue);
                    },
                    child: Text(
                      e["name"] as String,
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
        ),
        body: RefreshIndicator(
          onRefresh: () {
            return controller.onRefresh();
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: buildDatePickerBtn(context, controller, false, false),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    controller.isSummaryLoading.value
                        ? buildSummaryFetching()
                        : buildDashboardCard(controller),
                    const SizedBox(
                      height: 30,
                    ),
                    buildCustomerValueChart(controller),
                    const SizedBox(
                      height: 30,
                    ),
                    controller.isChartByRatingLoading.value
                        ? buildChartFetching(340.0)
                        : buildRatingChart(controller),
                    const SizedBox(
                      height: 30,
                    ),
                    controller.isChartByStageLoading.value
                        ? buildChartFetching(340.0)
                        : buildStageChart(controller),
                    const SizedBox(
                      height: 30,
                    ),
                    if (isAdminOrOwner(homeController))
                      Column(
                        children: [
                          buildStatisticUser(controller),
                          const SizedBox(
                            height: 30,
                          ),
                        ],
                      )
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Container buildStageChart(DashboardController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              offset: Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            )
          ]),
      child: Wrap(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Trạng thái khách hàng",
                    style: TextStyle(
                        color: Color(0XFF595A5C),
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  MenuAnchor(
                    menuChildren: [
                      ...controller.stageCustomerChartType
                          .map((e) => MenuItemButton(
                                child: Text(
                                  style: const TextStyle(fontSize: 14),
                                  e,
                                ),
                                onPressed: () {
                                  controller
                                      .currentStageCustomerChartType.value = e;
                                  controller.fetchBySource();
                                  controller.update();
                                },
                              ))
                    ],
                    style: const MenuStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.white),
                        padding: WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 12))),
                    builder: (context, c, child) => ElevatedBtn(
                        onPressed: () {
                          if (c.isOpen) {
                            c.close();
                          } else {
                            c.open();
                          }
                        },
                        circular: 12,
                        paddingAllValue: 0,
                        child: FittedBox(
                          child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3DFFF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    controller
                                        .currentStageCustomerChartType.value,
                                    style: const TextStyle(
                                        color: Color(0xFF2C160C),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 20,
                                  ),
                                ],
                              )),
                        )),
                  ),
                  const SizedBox(
                    width: 8,
                  )
                ],
              ),
              const SizedBox(
                height: 14,
              ),
              buildSourceLegend(controller),
              const SizedBox(
                height: 5,
              ),
              controller.isChartBySourceLoading.value
                  ? buildChartFetching(100.0)
                  : controller.stageValueCustomerChartList.isEmpty
                      ? const Center(
                          child: Text(
                            "Chưa có dữ liệu nào",
                            style: TextStyle(
                                fontSize: 16,
                                color: Color(0xB2000000),
                                fontWeight: FontWeight.w500),
                          ),
                        )
                      : Column(
                          children: [
                            ...controller.stageValueCustomerChartList
                                .map((element) {
                              final name = element["name"];
                              Map data = element["data"];
                              num totalPercentage = 0;
                              final chartWidth = Get.width - 100;
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Tooltip(
                                    message: capitalize(name),
                                    triggerMode: TooltipTriggerMode.tap,
                                    child: SizedBox(
                                        width: 70,
                                        child: Text(
                                          capitalize(name),
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  SizedBox(
                                    width: chartWidth,
                                    child: Row(
                                      children: [
                                        ...data.entries.map((e) {
                                          final groupName =
                                              getGroupNameFromKey(e.key);
                                          final bgColor =
                                              getColorFromKey(e.key);
                                          final isLastIndex =
                                              isLastElement(data, e.key);
                                          final percent = isLastIndex
                                              ? 100 - totalPercentage
                                              : getRoundedPercentage(
                                                  data, e.key);

                                          totalPercentage += percent;
                                          return percent == 0
                                              ? Container()
                                              : Column(
                                                  children: [
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    SizedOverflowBox(
                                                      size: const Size(0, 16),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                              e.value
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          if (controller
                                                              .isPercentShow
                                                              .value)
                                                            Text("($percent%)",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Color(
                                                                        0xFF646A73),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal)),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 3,
                                                    ),
                                                    Container(
                                                      width: chartWidth *
                                                          percent /
                                                          100,
                                                      height: 8,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(35),
                                                          color: bgColor),
                                                    ),
                                                    const SizedBox(
                                                      height: 2,
                                                    )
                                                  ],
                                                );
                                        })
                                      ],
                                    ),
                                  )
                                ],
                              );
                            }),
                          ],
                        ),
              const SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  const Spacer(),
                  SwitchRow(
                    onChanged: (p0) {
                      controller.isPercentShow.value = p0;
                      controller.update();
                    },
                  ),
                  const SizedBox(
                    width: 4,
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSourceLegend(DashboardController controller) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SizedBox(
            width: (Get.width - 32) / 2 + 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.circle,
                      color: Color(0xFF92F7A8),
                      size: 13,
                    ),
                    const SizedBox(
                      width: 3,
                    ),
                    const Text(
                      'Giao dịch',
                      style: TextStyle(
                          color: Color(0xB2000000),
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      "${controller.stageValueCustomerChartTotal["transaction"]}",
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                    if (controller.isPercentShow.value)
                      Text(
                          "(${getRoundedPercentage(controller.stageValueCustomerChartTotal, "transaction")}%)",
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xB2000000))),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.circle,
                      color: Color(0xFFFEBE99),
                      size: 13,
                    ),
                    const SizedBox(
                      width: 3,
                    ),
                    const Text(
                      'Không tiềm năng',
                      style: TextStyle(
                          color: Color(0xB2000000),
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                        "${controller.stageValueCustomerChartTotal["unpotential"]}",
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w500)),
                    if (controller.isPercentShow.value)
                      Text(
                          "(${getRoundedPercentage(controller.stageValueCustomerChartTotal, "unpotential")}%)",
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xB2000000))),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.circle,
                    color: Color(0xFFA4F3FF),
                    size: 13,
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  const Text(
                    'Tiềm năng',
                    style: TextStyle(
                        color: Color(0xB2000000),
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                      "${controller.stageValueCustomerChartTotal["potential"]}",
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w500)),
                  if (controller.isPercentShow.value)
                    Text(
                        "(${getRoundedPercentage(controller.stageValueCustomerChartTotal, "potential")}%)",
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xB2000000))),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.circle,
                    color: Color(0xFF9F87FF),
                    size: 13,
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  const Text(
                    'Không xác định',
                    style: TextStyle(
                        color: Color(0xB2000000),
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                      "${controller.stageValueCustomerChartTotal["undefined"]}",
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w500)),
                  if (controller.isPercentShow.value)
                    Text(
                      "(${getRoundedPercentage(controller.stageValueCustomerChartTotal, "undefined")}%)",
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xB2000000)),
                    ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  // Container buildStageChart(controller) {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.only(left: 16, top: 16),
  //     decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(8),
  //         boxShadow: const [
  //           BoxShadow(
  //             color: Color(0x0D000000),
  //             offset: Offset(0, 2),
  //             blurRadius: 8,
  //             spreadRadius: 0,
  //           )
  //         ]),
  //     child: Wrap(
  //       children: [
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const Text(
  //               "Thống kê các nhóm khách hàng",
  //               style: TextStyle(
  //                   color: Color(0XFF595A5C),
  //                   fontSize: 15,
  //                   fontWeight: FontWeight.bold),
  //             ),
  //             const SizedBox(
  //               height: 5,
  //             ),
  //             ...controller.stageValueCustomerChartObject.entries.map((e) {
  //               final value = e.value;
  //               return Theme(
  //                 data: ThemeData(
  //                   dividerColor: Colors.transparent,
  //                   fontFamily: "GoogleSans",
  //                 ),
  //                 child: ExpansionTile(
  //                   title: Row(
  //                     children: [
  //                       Text(
  //                         value["name"].toString(),
  //                         style: const TextStyle(
  //                             fontSize: 14,
  //                             fontWeight: FontWeight.bold,
  //                             color: Colors.black),
  //                       ),
  //                       const SizedBox(
  //                         width: 4,
  //                       ),
  //                       Container(
  //                         padding: const EdgeInsets.symmetric(
  //                             horizontal: 6, vertical: 1),
  //                         decoration: BoxDecoration(
  //                             color: const Color(0xffE3DFFF),
  //                             borderRadius: BorderRadius.circular(16)),
  //                         child: Text(
  //                           value["count"].toString(),
  //                           style: const TextStyle(
  //                               color: Colors.black, fontSize: 10),
  //                         ),
  //                       )
  //                     ],
  //                   ),
  //                   children: [
  //                     ...(value["data"] as List).map((data) {
  //                       return Padding(
  //                         padding: const EdgeInsets.symmetric(
  //                             horizontal: 36.0, vertical: 6),
  //                         child: Row(
  //                           children: [
  //                             Text(data["name"],
  //                                 style: const TextStyle(fontSize: 12)),
  //                             const Spacer(),
  //                             Text(
  //                               data["count"].toString(),
  //                               style: const TextStyle(fontSize: 12),
  //                             ),
  //                             const SizedBox(
  //                               width: 24,
  //                             )
  //                           ],
  //                         ),
  //                       );
  //                     })
  //                   ],
  //                 ),
  //               );
  //             }),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Container buildRatingChart(DashboardController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              offset: Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            )
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          const Text('Đánh giá khách hàng',
              style: TextStyle(
                  color: Color(0XFF595A5C),
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...controller.ratingCustomerChartList.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 15,
                              color: e.color,
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            SizedBox(
                              width: 85,
                              child: Text(
                                e.name,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            const Icon(
                              Icons.circle,
                              size: 5,
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            Text(
                              e.value.toString(),
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ))
                ],
              ),
              const Spacer(),
              ClipRect(
                child: Align(
                  heightFactor: 0.7,
                  widthFactor: 1,
                  child: SizedBox(
                    width: Get.width / 2,
                    child: SfCircularChart(
                        margin: EdgeInsets.zero,
                        tooltipBehavior: TooltipBehavior(enable: true),
                        annotations: <CircularChartAnnotation>[
                          CircularChartAnnotation(
                              widget: Wrap(
                            children: [
                              Column(
                                children: [
                                  const Text(
                                    "Tổng số khách hàng",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                      controller.dataCardObject["customer"]
                                              ["value"]
                                          .toString(),
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ))
                        ],
                        series: <CircularSeries<ChartModel, String>>[
                          DoughnutSeries<ChartModel, String>(
                              dataSource: controller.ratingCustomerChartList,
                              xValueMapper: (ChartModel data, _) => data.name,
                              yValueMapper: (ChartModel data, _) => data.value,
                              pointColorMapper: (ChartModel data, _) =>
                                  data.color,
                              strokeWidth: 1,
                              strokeColor: const Color(0xFFFAFEFF),
                              explode: true,
                              innerRadius: '70%')
                        ]),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  GridView buildDashboardCard(controller) {
    return GridView.count(
      shrinkWrap: true,
      childAspectRatio: 2.15,
      crossAxisCount: 2,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        ...controller.dataCardObject.entries.map(
          (e) => GestureDetector(
            onTap: e.value["onPressed"] as Function(),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: e.value["color"] as Color,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ignore: prefer_const_constructors
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: e.value["icon"],
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        e.value["value"].toString(),
                        style: const TextStyle(
                            color: Color(0xFF5A48F1),
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ],
                  ),
                  Text(
                    e.value["name"].toString(),
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Container buildCustomerValueChart(DashboardController controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              offset: Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            )
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Phân loại khách hàng',
                style: TextStyle(
                    color: Color(0XFF595A5C),
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 16,
              ),
              const Icon(
                Icons.circle,
                color: Color(0xFF9B8CF7),
                size: 13,
              ),
              const SizedBox(
                width: 5,
              ),
              const Text(
                'Form',
                style: TextStyle(
                    color: Color(0xB2000000),
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                width: 14,
              ),
              const Icon(
                Icons.circle,
                color: Color(0xFFA5F2AA),
                size: 13,
              ),
              const SizedBox(
                width: 5,
              ),
              const Text(
                'Import',
                style: TextStyle(
                    color: Color(0xB2000000),
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                width: 14,
              ),
              const Icon(
                Icons.circle,
                color: Color(0xFFF5C19E),
                size: 13,
              ),
              const SizedBox(
                width: 5,
              ),
              const Text(
                'Khác',
                style: TextStyle(
                    color: Color(0xB2000000),
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              MenuAnchor(
                menuChildren: [
                  ...controller.timeType.map((e) => MenuItemButton(
                        child: Text(e["name"]!,
                            style: const TextStyle(fontSize: 14)),
                        onPressed: () {
                          controller.currentTimeType.value = e;
                          controller.fetchOverTime();
                          controller.update();
                        },
                      ))
                ],
                style: const MenuStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.white),
                    padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 12))),
                builder: (context, c, child) => ElevatedBtn(
                    onPressed: () {
                      if (c.isOpen) {
                        c.close();
                      } else {
                        c.open();
                      }
                    },
                    circular: 12,
                    paddingAllValue: 0,
                    child: FittedBox(
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3DFFF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_month_sharp,
                                color: Color(0xFF5C33F0),
                                size: 20,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(
                                controller.currentTimeType["name"]!,
                                style: const TextStyle(
                                    color: Color(0xFF2C160C),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          )),
                    )),
              ),
              const SizedBox(
                width: 16,
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          controller.isChartByTimeLoading.value
              ? buildChartFetching(300.0)
              : SfCartesianChart(
                  enableSideBySideSeriesPlacement: false,
                  trackballBehavior: TrackballBehavior(
                      enable: true,
                      activationMode: ActivationMode.singleTap,
                      hideDelay: 2 * 1000,
                      lineColor: Colors.transparent,
                      tooltipDisplayMode: TrackballDisplayMode.groupAllPoints),
                  zoomPanBehavior: ZoomPanBehavior(
                      enablePanning: true,
                      zoomMode: ZoomMode.x,
                      enableMouseWheelZooming: true,
                      enablePinching: true),
                  primaryXAxis: CategoryAxis(
                      axisLabelFormatter: (axisLabelRenderArgs) {
                        return ChartAxisLabel(
                            axisLabelRenderArgs.text, const TextStyle());
                      },
                      labelStyle: const TextStyle(
                          fontSize: 11,
                          color: Colors.black,
                          fontStyle: FontStyle.italic),
                      labelRotation: 312),
                  primaryYAxis:
                      NumericAxis(numberFormat: NumberFormat.compact()),
                  series: [
                    StackedColumnSeries<ChartModel, String>(
                      dataSource: controller.valueCustomerChartObject["Form"]!,
                      xValueMapper: (ChartModel data, _) => data.name,
                      yValueMapper: (ChartModel data, _) => data.value,
                      width: 0.4,
                      color: const Color(0xFF9B8CF7),
                      name: 'Form',
                    ),
                    StackedColumnSeries<ChartModel, String>(
                      dataSource:
                          controller.valueCustomerChartObject["Import"]!,
                      xValueMapper: (ChartModel data, _) => data.name,
                      yValueMapper: (ChartModel data, _) => data.value,
                      width: 0.4,
                      name: 'Import',
                      color: const Color(0xFFA5F2AA),
                    ),
                    StackedColumnSeries<ChartModel, String>(
                      dataSource: controller.valueCustomerChartObject["Other"]!,
                      xValueMapper: (ChartModel data, _) => data.name,
                      yValueMapper: (ChartModel data, _) => data.value,
                      width: 0.4,
                      color: const Color(0xFFF5C19E),
                      name: 'Khác',
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  final categories = [
    "Xếp hạng Sale",
    "Xếp hạng Sàn",
  ];

  Widget buildStatisticUser(DashboardController controller) {
    return DefaultTabController(
      length: 2,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: controller.statisticsUserData.isEmpty
              ? 85
              : controller.statisticsUserData.length < 10
                  ? controller.statisticsUserData.length * 57 + 60
                  : 670,
        ),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                offset: Offset(0, 2),
                blurRadius: 8,
                spreadRadius: 0,
              )
            ]),
        child: Column(
          children: [
            TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                ...categories.map(
                  (e) {
                    return Tab(
                      child: Text(e,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ],
            ),
            Expanded(
              child: TabBarView(children: [
                controller.statisticsUserData.isEmpty
                    ? const Center(
                        child: Text(
                        "Chưa có thông tin",
                        style: TextStyle(fontSize: 16),
                      ))
                    : Column(
                        children: [
                          ...controller.statisticsUserData
                              .take(10)
                              .toList()
                              .map((userData) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  Text(
                                    userData["index"].toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  (userData?["avatar"] != null)
                                      ? CircleAvatar(
                                          backgroundImage: getAvatarProvider(
                                              userData?["avatar"]),
                                          radius: 20,
                                        )
                                      : createCircleAvatar(
                                          name: userData?["fullName"],
                                          radius: 20,
                                          fontSize: 14),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userData?["fullName"],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            userData["total"].toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF29315F),
                                                fontSize: 11),
                                          ),
                                          const Text(
                                            " Khách hàng",
                                            style: TextStyle(
                                                color: Color(0xFF29315F),
                                                fontSize: 11),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.all(6.0),
                                            child: Icon(
                                              Icons.circle,
                                              size: 3,
                                            ),
                                          ),
                                          Text(
                                            userData["potential"].toString(),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF29315F),
                                                fontSize: 11),
                                          ),
                                          const Text(
                                            " Tiềm năng",
                                            style: TextStyle(
                                                color: Color(0xFF29315F),
                                                fontSize: 11),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  const Spacer(),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "0 tỷ",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1F2329)),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        "0 Giao dịch",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF29315F)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          }),
                          if (controller.statisticsUserData.length >= 10)
                            ElevatedBtn(
                              paddingAllValue: 6,
                              circular: 50,
                              onPressed: () {
                                Get.to(() => RankingSalePage(
                                    userList: controller.statisticsUserData));
                              },
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Xem thêm",
                                    style: TextStyle(
                                        fontSize: 13, color: Color(0xB2000000)),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 13,
                                    color: Color(0xB2000000),
                                  )
                                ],
                              ),
                            )
                        ],
                      ),
                Container()
              ]),
            )
          ],
        ),
      ),
    );
  }
}

Widget buildDatePickerBtn(
    BuildContext context, controller, bool isExpanded, bool hideBg) {
  return MenuAnchor(
    style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(Colors.white),
        maximumSize: WidgetStatePropertyAll(Size(Get.width - 32, 350)),
        padding:
            const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30))),
    menuChildren: [
      MenuItemButton(
        child: const Text("Hôm nay",
            style: TextStyle(color: Colors.black, fontSize: 14)),
        onPressed: () {
          final now = DateTime.now();
          controller.fromDate = DateTime(now.year, now.month, now.day);
          controller.toDate = controller.fromDate.add(const Duration(days: 1));
          controller.dateString.value = "Hôm nay";
          controller.onRefresh();
        },
      ),
      MenuItemButton(
        child: const Text("Hôm qua",
            style: TextStyle(color: Colors.black, fontSize: 14)),
        onPressed: () {
          final now = DateTime.now();
          controller.fromDate = DateTime(now.year, now.month, now.day)
              .subtract(const Duration(days: 1));
          controller.toDate = DateTime(now.year, now.month, now.day - 1);
          controller.dateString.value = "Hôm qua";
          controller.onRefresh();
        },
      ),
      MenuItemButton(
        child: const Text("7 ngày qua",
            style: TextStyle(color: Colors.black, fontSize: 14)),
        onPressed: () {
          controller.fromDate =
              DateTime.now().subtract(const Duration(days: 7));
          controller.toDate = DateTime.now().add(const Duration(days: 1));
          controller.dateString.value = "7 ngày qua";
          controller.onRefresh();
        },
      ),
      MenuItemButton(
        child: const Text("30 ngày qua",
            style: TextStyle(color: Colors.black, fontSize: 14)),
        onPressed: () {
          controller.fromDate =
              DateTime.now().subtract(const Duration(days: 30));
          controller.toDate = DateTime.now().add(const Duration(days: 1));
          controller.dateString.value = "30 ngày qua";
          controller.onRefresh();
        },
      ),
      MenuItemButton(
        child: const Text("Năm nay",
            style: TextStyle(color: Colors.black, fontSize: 14)),
        onPressed: () {
          controller.fromDate =
              DateTime.now().subtract(const Duration(days: 365));
          controller.toDate = DateTime.now().add(const Duration(days: 1));
          controller.dateString.value = "Năm nay";
          controller.onRefresh();
        },
      ),
      MenuItemButton(
        child: const Text("Toàn bộ thời gian",
            style: TextStyle(color: Colors.black, fontSize: 14)),
        onPressed: () {
          controller.fromDate =
              DateTime.now().subtract(const Duration(days: 10000));
          controller.toDate = DateTime.now().add(const Duration(days: 10000));
          controller.dateString.value = "Toàn bộ thời gian";
          controller.onRefresh();
        },
      ),
      MenuItemButton(
        child: Text(
            "Phạm vị ngày tùy chỉnh${isExpanded ? "         "
                ""
                "                                               " : ""}",
            style: const TextStyle(color: Colors.black, fontSize: 14)),
        onPressed: () {
          showDateRangePicker(
                  context: context,
                  initialDateRange: DateTimeRange(
                    start: DateTime.now().subtract(const Duration(days: 30)),
                    end: DateTime.now().add(const Duration(days: 1)),
                  ),
                  firstDate: DateTime(2018),
                  lastDate: DateTime(2030))
              .then((dateRange) {
            if (dateRange != null) {
              controller.fromDate = dateRange.start;
              controller.toDate = dateRange.end;
              controller.dateString.value =
                  "${DateFormat("dd-MM-yyyy").format(dateRange.start)} đến ${DateFormat("dd-MM-yyyy").format(dateRange.end)}";
              controller.onRefresh();
            }
          });
        },
      )
    ],
    builder: (context, c, child) => ElevatedBtn(
      onPressed: () {
        if (c.isOpen) {
          c.close();
        } else {
          c.open();
        }
      },
      paddingAllValue: 0,
      circular: 12,
      child: FittedBox(
        child: Container(
            width: isExpanded ? Get.width - 32 : null,
            padding: isExpanded
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
                : const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hideBg ? null : const Color(0xFFE3DFFF),
              borderRadius: BorderRadius.circular(isExpanded ? 16 : 12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  color: Color(0xFF5C33F0),
                  size: 20,
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  controller.dateString.value,
                  style: const TextStyle(
                      color: Color(0xFF2C160C),
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                )
              ],
            )),
      ),
    ),
  );
}
