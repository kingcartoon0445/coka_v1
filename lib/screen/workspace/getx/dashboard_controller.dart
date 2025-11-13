import 'dart:convert';

import 'package:coka/api/dashboard.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/screen/workspace/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants.dart';
import '../../home/home_controller.dart';

class DashboardController extends GetxController
    with GetSingleTickerProviderStateMixin {
  HomeController homeController = Get.put(HomeController());

  final isSummaryLoading = false.obs;
  final isChartByRatingLoading = false.obs;
  final isChartByStageLoading = false.obs;
  final isChartByUserLoading = false.obs;
  final isChartByTimeLoading = false.obs;
  final isChartBySourceLoading = false.obs;
  final dataCardObject = {}.obs;
  final isDeleteAble = false.obs;
  final valueCustomerChartObject = {
    "Import": <ChartModel>[],
    "Form": <ChartModel>[],
    "Other": <ChartModel>[],
  }.obs;
  final stageCountObject = {}.obs;
  final ratingCustomerChartList = <ChartModel>[].obs;
  final stageValueCustomerChartObject =
      Map.from(jsonDecode(jsonEncode(stageObject))).obs;
  final stageValueCustomerChartList = [].obs;
  final stageValueCustomerChartTotal = {}.obs;
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime toDate = DateTime.now().add(const Duration(days: 1));
  final dateString = "".obs;
  final currentTimeType = {"name": "Ngày", "id": "Day"}.obs;
  final currentStageCustomerChartType = "Phân loại".obs;
  final stageCustomerChartType = ["Nguồn", "Phân loại", "Thẻ"];
  final timeType = [
    {"name": "Ngày", "id": "Day"},
    {"name": "Tháng", "id": "MONTH"},
    {"name": "Năm", "id": "YEAR"}
  ];
  final statisticsUserData = [].obs;
  final isPercentShow = true.obs;
  late TabController tabController;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    tabController = TabController(length: 2, vsync: this);
    dataCardObject.value = {
      "customer": {
        "name": "Khách hàng",
        "icon": const Icon(Icons.person_outline, size: 22),
        "value": 0,
        "color": Colors.white,
        "onPressed": () {
          WorkspaceMainController w = Get.find<WorkspaceMainController>();

          w.onTapped(1);
          print(w.selectedIndex.value);
        }
      },
      "demand": {
        "name": "Nhu cầu",
        "icon": Image.asset("assets/images/demand_value_icon.png",
            height: 15, width: 15),
        "value": 0,
        "color": Colors.white,
        "onPressed": () {
          WorkspaceMainController w = Get.find<WorkspaceMainController>();
          w.onTapped(2);
          print(w.selectedIndex.value);
        }
      },
      "product": {
        "name": "Sản phẩm",
        "icon": Image.asset("assets/images/demand_outline_icon.png",
            height: 20, width: 20),
        "value": 0,
        "color": Colors.white,
        "onPressed": () {
          WorkspaceMainController w = Get.find<WorkspaceMainController>();
          w.onTapped(2);
          print(w.selectedIndex.value);
        }
      },
      "member": {
        "name": "Sales",
        "icon": Image.asset("assets/images/team_outline_icon.png",
            height: 20, width: 20),
        "value": 0,
        "color": Colors.white,
        "onPressed": () {
          WorkspaceMainController w = Get.find<WorkspaceMainController>();
          w.onTapped(3);
          print(w.selectedIndex.value);
        }
      },
    };
    dateString.value = "30 ngày qua";
    onRefresh();
  }

  Future onRefresh() async {
    ratingCustomerChartList.value = <ChartModel>[];
    update();
    fetchSummary();
    fetchOverTime();
    fetchByStage();
    if (isAdminOrOwner(homeController)) {
      fetchByUser();
    }
    fetchByRating();

    fetchBySource(firstLoad: true);
    update();
  }

  Future fetchOverTime() async {
    isChartByTimeLoading.value = true;
    valueCustomerChartObject["Other"]?.clear();
    valueCustomerChartObject["Form"]?.clear();
    valueCustomerChartObject["Import"]?.clear();
    fromDate = DateTime(fromDate.year, fromDate.month, fromDate.day, 0, 0, 0);
    toDate = DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59);
    await DashboardApi()
        .getOvertime(homeController.workGroupCardDataValue["id"], fromDate,
            toDate, currentTimeType["id"])
        .then((res) {
      isChartByTimeLoading.value = false;

      if (isSuccessStatus(res["code"])) {
        final listData = res["content"];
        for (var x in listData) {
          final dateString = x["date"];

          valueCustomerChartObject["Other"]
              ?.add(ChartModel(dateString, x["aidc"]));
          valueCustomerChartObject["Form"]
              ?.add(ChartModel(dateString, x["form"]));
          valueCustomerChartObject["Import"]
              ?.add(ChartModel(dateString, x["import"]));
        }
      } else {
        errorAlert(title: "Lỗi", desc: res["message"]);
      }
      update();
    });
  }

  Future fetchByUser() async {
    fromDate = DateTime(fromDate.year, fromDate.month, fromDate.day, 0, 0, 0);
    toDate = DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59);
    isChartByUserLoading.value = true;
    update();

    await DashboardApi()
        .getStatisticByUser(
            homeController.workGroupCardDataValue["id"], fromDate, toDate)
        .then((res) {
      isChartByUserLoading.value = false;

      if (isSuccessStatus(res["code"])) {
        statisticsUserData.clear();
        statisticsUserData.value = res["content"];
      } else {
        errorAlert(title: "Lỗi", desc: res["message"]);
      }
    });
    update();
  }

  Future fetchByStage() async {
    fromDate = DateTime(fromDate.year, fromDate.month, fromDate.day, 0, 0, 0);
    toDate = DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59);
    isChartByStageLoading.value = true;
    // update();
    // await DashboardApi()
    //     .getByStage(
    //         homeController.workGroupCardDataValue["id"], fromDate, toDate)
    //     .then((res) {
    //   isChartByStageLoading.value = false;

    //   if (isSuccessStatus(res["code"])) {
    //     stageCountObject.clear();
    //     List listData = res["content"];
    //     countGroupStage(listData);
    //   } else {
    //     errorAlert(title: "Lỗi", desc: res["message"]);
    //   }
    // });

    update();
  }

  Future fetchBySource({bool? firstLoad = false}) async {
    if (firstLoad!) {
      isChartByStageLoading.value = true;
    } else {
      isChartBySourceLoading.value = true;
    }
    update();
    try {
      fromDate = DateTime(fromDate.year, fromDate.month, fromDate.day, 0, 0, 0);
      toDate = DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59);
      if (currentStageCustomerChartType.value == "Nguồn") {
        await DashboardApi()
            .getStatisticByUtmSource(
                homeController.workGroupCardDataValue["id"], fromDate, toDate)
            .then((res) {
          if (isSuccessStatus(res["code"])) {
            stageValueCustomerChartList.value = res["content"];
            stageValueCustomerChartTotal.value = res["metadata"];
          } else {
            errorAlert(title: "Lỗi", desc: res["message"]);
          }
        });
      } else if (currentStageCustomerChartType.value == "Phân loại") {
        await DashboardApi()
            .getStatisticByDataSource(
                homeController.workGroupCardDataValue["id"], fromDate, toDate)
            .then((res) {
          if (isSuccessStatus(res["code"])) {
            stageValueCustomerChartList.value = res["content"];
            stageValueCustomerChartTotal.value = res["metadata"];
          } else {
            errorAlert(title: "Lỗi", desc: res["message"]);
          }
        });
      } else if (currentStageCustomerChartType.value == "Thẻ") {
        await DashboardApi()
            .getStatisticByTag(
                homeController.workGroupCardDataValue["id"], fromDate, toDate)
            .then((res) {
          if (isSuccessStatus(res["code"])) {
            stageValueCustomerChartList.value = res["content"];
            stageValueCustomerChartTotal.value = res["metadata"];
          } else {
            errorAlert(title: "Lỗi", desc: res["message"]);
          }
        });
      }
    } catch (e) {
      if (firstLoad) {
        isChartByStageLoading.value = false;
      } else {
        isChartBySourceLoading.value = false;
      }
      update();
    }
    if (firstLoad) {
      isChartByStageLoading.value = false;
    } else {
      isChartBySourceLoading.value = false;
    }
    update();
  }

  void countGroupStage(List<dynamic> listData) {
    for (var x in stageValueCustomerChartObject.entries) {
      var value = x.value;
      var count = 0;
      for (var y in value["data"] as List) {
        final name = y["name"];
        Map? matchingElement;
        try {
          matchingElement = listData.firstWhere((e) => e["stageName"] == name);
        } catch (e) {
          matchingElement = null;
        }

        var countValue = matchingElement != null ? matchingElement["count"] : 0;
        y["count"] = countValue;
        count += y["count"] as int;
      }
      value["count"] = count;
      stageCountObject[value["name"]] = count;
    }
    num allCount = 0;
    for (var x in stageCountObject.values) {
      allCount += x;
    }
    stageCountObject["Tất cả"] = allCount;
  }

  Future fetchByRating() async {
    fromDate = DateTime(fromDate.year, fromDate.month, fromDate.day, 0, 0, 0);
    toDate = DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59);
    isChartByRatingLoading.value = true;

    await DashboardApi()
        .getByRating(
            homeController.workGroupCardDataValue["id"], fromDate, toDate)
        .then((res) {
      isChartByRatingLoading.value = false;

      if (isSuccessStatus(res["code"])) {
        List listData = res["content"];
        final rating0 = listData.firstWhere(
          (e) => e["rating"] == 0,
          orElse: () => null,
        );
        final rating1 = listData.firstWhere(
          (e) => e["rating"] == 1,
          orElse: () => null,
        );
        final rating2 = listData.firstWhere(
          (e) => e["rating"] == 2,
          orElse: () => null,
        );
        final rating3 = listData.firstWhere(
          (e) => e["rating"] == 3,
          orElse: () => null,
        );
        final rating4 = listData.firstWhere(
          (e) => e["rating"] == 4,
          orElse: () => null,
        );
        final rating5 = listData.firstWhere(
          (e) => e["rating"] == 5,
          orElse: () => null,
        );
        ratingCustomerChartList.add(ChartModel("5 sao", rating5?["count"] ?? 0,
            color: const Color(0xff9B8CF7)));
        ratingCustomerChartList.add(ChartModel("4 sao", rating4?["count"] ?? 0,
            color: const Color(0xFFB6F1FD)));
        ratingCustomerChartList.add(ChartModel("3 sao", rating3?["count"] ?? 0,
            color: const Color(0xffA5F2AA)));
        ratingCustomerChartList.add(ChartModel("2 sao", rating2?["count"] ?? 0,
            color: const Color(0xffF0D5FC)));
        ratingCustomerChartList.add(ChartModel("1 sao", rating1?["count"] ?? 0,
            color: const Color(0xffF5C19E)));
        ratingCustomerChartList.add(ChartModel(
            "Chưa đánh giá", rating0?["count"] ?? 0,
            color: const Color(0xff554FE8)));
      } else {
        errorAlert(title: "Lỗi", desc: res["message"]);
      }
    });
    update();
  }

  Future fetchSummary() async {
    fromDate = DateTime(fromDate.year, fromDate.month, fromDate.day, 0, 0, 0);
    toDate = DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59);
    isSummaryLoading.value = true;
    await DashboardApi()
        .getSummary(
            homeController.workGroupCardDataValue["id"], fromDate, toDate)
        .then((res) {
      isSummaryLoading.value = false;
      if (isSuccessStatus(res["code"])) {
        dataCardObject["customer"]?["value"] =
            res["content"]["totalContact"] ?? 0;
        dataCardObject["demand"]?["value"] = res["content"]["totalDemand"] ?? 0;
        dataCardObject["product"]?["value"] =
            res["content"]["totalProduct"] ?? 0;
        dataCardObject["member"]?["value"] = res["content"]["totalMember"] ?? 0;
        if (dataCardObject["customer"]?["value"] == 0 &&
            dataCardObject["demand"]?["value"] == 0 &&
            dataCardObject["product"]?["value"] == 0 &&
            (dataCardObject["member"]?["value"] == 0 ||
                dataCardObject["member"]?["value"] == 1)) {
          isDeleteAble.value = true;
        }
      } else {
        errorAlert(title: "Lỗi", desc: res["message"]);
      }
    }).catchError((e) {});
    update();
  }
}
