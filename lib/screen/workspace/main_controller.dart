// BEGIN: FILE WorkspaceMainController.dart
import 'dart:async';
import 'dart:convert';

import 'package:coka/api/customer.dart';
import 'package:coka/api/workspace.dart';
import 'package:coka/components/search_anchor.dart';
import 'package:coka/main.dart';
import 'package:coka/models/chip_data.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/workspace/getx/dashboard_controller.dart';
import 'package:coka/screen/workspace/pages/customers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sip_ua/sip_ua.dart';

import '../../components/awesome_alert.dart';
import '../../components/chip_input.dart';
import '../../constants.dart';
import '../../utils/crypto_helper.dart';
import 'getx/customer_controller.dart';
import 'pages/callscreen.dart';

class WorkspaceMainController extends GetxController
    with GetSingleTickerProviderStateMixin
    implements SipUaHelperListener {
  final homeController = Get.put(HomeController());
  final dashboardController = Get.put(DashboardController());
  final history = [0].obs;

  // SỬA LỖI 1: Bỏ '?' (nullable), helper sẽ được khởi tạo ngay
  SIPUAHelper helper = SIPUAHelper();

  // SỬA LỖI 2: Thêm biến .obs để theo dõi trạng thái SIP
  final isSipRegistered = false.obs;

  ScrollController sc = ScrollController();
  late TabController tabController;
  final selectedIndex = 0.obs;
  final isLoading = [false, false, false, false, false].obs;
  final isLoadingMore = [false, false, false, false, false].obs;
  final roomList = [[], [], [], [], []].obs;
  final isRoomEmpty = false.obs;
  final limit = 10;
  final groupId = "".obs;
  final selectedGroupIndex = 0.obs;
  var offset = 0;
  final memberFilterList = [].obs;
  final teamFilterList = [].obs;
  final stageFilterList = [].obs;
  final ratingFilterList = [].obs;
  final tagFilterList = [].obs;
  final sourceList = <ChipData>[].obs;
  final categoryList = <ChipData>[].obs;
  final sourceChipKey = GlobalKey<ChipsInputState>();
  final categoryChipKey = GlobalKey<ChipsInputState>();
  final stageValueCustomerChartObject =
      Map.from(jsonDecode(jsonEncode(stageObject))).obs;
  Timer? timer;
  final timeLabel = '00:00'.obs;
  Timer? _debounce;
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 10000));
  DateTime toDate = DateTime.now().add(const Duration(days: 10000));
  final dateString = "".obs;
  CustomSearchController searchController = CustomSearchController();
  final hintCustomerList = [].obs;
  bool isDismiss = true;
  Map hintPrefsData = {};

  void clearFilter() {
    memberFilterList.clear();
    teamFilterList.clear();
    stageFilterList.clear();
    ratingFilterList.clear();
    tagFilterList.clear();
    sourceList.clear();
    categoryList.clear();
    fromDate = DateTime.now().subtract(const Duration(days: 10000));
    toDate = DateTime.now().add(const Duration(days: 10000));
    dateString.value = "Toàn bộ thời gian";
    update();
  }

  Future getHintCustomer() async {
    searchController.clear();
    final prefs = await SharedPreferences.getInstance();
    hintPrefsData = jsonDecode(prefs.getString("hintCustomerData") ?? "{}");
    hintCustomerList.value =
        hintPrefsData[homeController.workGroupCardDataValue["id"]] ?? [];
  }

  bool isNotFilter() {
    if (memberFilterList.isEmpty &&
        teamFilterList.isEmpty &&
        stageFilterList.isEmpty &&
        ratingFilterList.isEmpty &&
        tagFilterList.isEmpty &&
        sourceList.isEmpty &&
        categoryList.isEmpty) {
      return true;
    }
    return false;
  }

  final stageCountObject = {}.obs;

  @override
  void onInit() {
    // SỬA LỖI 3: Dọn dẹp onInit, bỏ Timer, chạy khởi tạo trực tiếp
    super.onInit(); // Luôn gọi super() ở đầu
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
      ),
    );
    dateString.value = "Toàn bộ thời gian";

    // *** BỎ TIMER, KHỞI TẠO TRỰC TIẾP ***
    helper.addSipUaHelperListener(this); // Dùng 'helper.' (không có '!')

    // Giải mã password trước khi sử dụng
    print(homeController.userData);
    if (homeController.callData.containsKey("passwordHash")) {
      final decryptedPassword = CryptoHelper.decrypt(
          homeController.callData["passwordHash"],
          homeController.userData["id"]);

      // Thêm print để debug mật khẩu
      print("!!! MẬT KHẨU ĐÃ GIẢI MÃ LÀ: $decryptedPassword");

      callSettingInit(homeController.callData["name"], decryptedPassword);
    }
    // **********************************

    final defaultIndex = Get.arguments?["defaultIndex"];
    if (defaultIndex != null) {
      onTapped(defaultIndex);
    }
    isLoading[selectedGroupIndex.value] = true;
    getHintCustomer();
    // fetchByStage();
    fetchWorkspaceDetail();
    fetchCustomer(index: selectedGroupIndex.value);
    sc.addListener(() {
      if (sc.position.pixels >= sc.position.maxScrollExtent) {
        if (roomList.isNotEmpty && !isLoading[selectedGroupIndex.value]) {
          loadMore();
          isLoadingMore[selectedGroupIndex.value] = true;
          fetchCustomer(
              offset: offset, limit: limit, index: selectedGroupIndex.value);
        }
      }
    });
    tabController = TabController(
        length: 5, vsync: this); // Replace 3 with the number of tabs you have
    tabController.addListener(
      handleTabChange,
    );
  }

  @override
  void onClose() {
    // SỬA LỖI 4: Dọn dẹp an toàn, gọi super.onClose() ở CUỐI CÙNG

    // Dọn dẹp của bạn TRƯỚC
    helper.removeSipUaHelperListener(this); // Dùng 'helper.'
    _debounce?.cancel();
    timer?.cancel();

    // Gọi super.onClose() CUỐI CÙNG
    super.onClose();
  }

  void callSettingInit(name, pass) {
    UaSettings settings = UaSettings();
    settings.webSocketUrl = "wss://vcwebrtc.voicecloud.vn:9443";
    settings.webSocketSettings.extraHeaders = {};
    settings.webSocketSettings.allowBadCertificate = true;
    settings.uri = "$name@azvidi.voicecloud-platform.com";
    settings.authorizationUser = name;
    settings.password = pass;
    settings.displayName = name;
    settings.userAgent = 'Dart SIP Client v1.0.0';
    settings.dtmfMode = DtmfMode.RFC2833;
    settings.transportType = TransportType.WS;

    // SỬA LỖI 5: Dùng 'helper.' (không có '!')
    helper.start(settings);
  }

  Future<void> handleCall(phone) async {
    // SỬA LỖI 6: Kiểm tra biến 'isSipRegistered.value'
    if (!isSipRegistered.value) {
      print('SIP HELPER LỖI: Chưa đăng ký (isSipRegistered = false).');

      Get.snackbar(
        'Chưa sẵn sàng',
        'Đang kết nối tới máy chủ, vui lòng thử lại sau giây lát.',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Dừng hàm, không chạy code bên dưới
      return;
    }
    // ************************************************

    // Code cũ của bạn (bây giờ đã an toàn để chạy)
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
    ].request();
    if (statuses[Permission.microphone] != PermissionStatus.granted) {
      openAppSettings();
      return;
    }

    final mediaConstraints = <String, dynamic>{
      'audio': true,
      'video': false,
    };
    rtc.MediaStream mediaStream;
    mediaStream =
        await rtc.navigator.mediaDevices.getUserMedia(mediaConstraints);

    // Lệnh gọi này bây giờ chỉ chạy khi helper đã sẵn sàng
    // SỬA LỖI 5: Dùng 'helper.' (không có '!')
    helper.call(
      "+$phone",
      // voiceonly: true,
      mediaStream: mediaStream,
    );
  }

  void onDebounce(Function searchFunction, int debounceTime) {
    // Hủy bỏ bất kỳ timer nào nếu có
    _debounce?.cancel();
    // Tạo mới timer với thời gian debounce
    _debounce = Timer(Duration(milliseconds: debounceTime), () {
      // Lấy dữ liệu từ trường văn bản và gọi hàm tìm kiếm
      searchFunction();
    });
  }

  void handleTabChange() {
    if (selectedGroupIndex.value != tabController.index) {
      offset = 0;
      selectedGroupIndex.value = tabController.index;
      roomList[selectedGroupIndex.value].clear();
      isLoading[selectedGroupIndex.value] = true;
      // fetchByStage();
      fetchCustomer(index: tabController.index);
    }
  }

  Future onRefresh() async {
    roomList[selectedGroupIndex.value].clear();
    update();
    offset = 0;
    isLoading[selectedGroupIndex.value] = true;
    await Future.wait([
      // fetchByStage(),
      fetchCustomer(index: selectedGroupIndex.value)
    ]);
  }

  Future<bool> onWillPop() async {
    if (history.last == 0) {
      return true;
    }
    if (history.length > 1) {
      history.removeLast();
      selectedIndex.value = history.last;
      update();
      return false;
    } else {
      return true;
    }
  }

  void onTapped(int index) {
    if (history.length == 2) {
      history.removeAt(1);
      history.add(index);
    } else {
      history.add(index);
    }
    selectedIndex.value = index;
    update();
  }

  void loadMore() {
    offset += limit;
  }

  Future fetchWorkspaceDetail() async {
    await WorkspaceApi()
        .getWorkspaceDetail(homeController.workGroupCardDataValue["id"])
        .then((res) {
      if (isSuccessStatus(res["code"])) {
        homeController.workGroupCardDataValue.value = res["content"];
      } else {
        errorAlert(title: "Lỗi", desc: res["message"]);
      }
    });
  }

  Future fetchCustomer(
      {int? offset, int? limit, required int index, String? searchText}) async {
    final groupId = stageGroupList[selectedGroupIndex.value]["id"];
    var stageString = "";
    for (var x in stageFilterList) {
      stageString += "&Stage=${x["id"]}";
    }
    var ratingString = "";
    for (var x in ratingFilterList) {
      ratingString += "&Rating=${x["value"]}";
    }
    var memberString = "";
    for (var x in memberFilterList) {
      memberString += "&AssignTo=${x["profileId"]}";
    }
    var teamString = "";
    for (var x in teamFilterList) {
      teamString += "&TeamId=${x["id"]}";
    }
    var categoryString = "";
    for (var x in categoryList) {
      categoryString += "&CategoryList=${x.id}";
    }
    var sourceString = "";
    for (var x in sourceList) {
      sourceString += "&SourceList=${x.id}";
    }
    var tagString = "";
    for (var x in tagFilterList) {
      tagString += "&Tags=$x";
    }
    fromDate = DateTime(fromDate.year, fromDate.month, fromDate.day, 0, 0, 0);
    toDate = DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59);
    await CustomerApi()
        .getCustomerList(homeController.workGroupCardDataValue['id'],
            offset ?? 0, limit ?? 10,
            groupId: groupId,
            searchText: searchController.text,
            endDate: toDate,
            ratingList: ratingString,
            stageList: stageString,
            memberList: memberString,
            teamList: teamString,
            startDate: fromDate,
            categoryList: categoryString,
            sourceList: sourceString,
            tagList: tagString)
        .then((res) {
      if (isSuccessStatus(res['code'])) {
        roomList[index].addAll(res['content']);
        if (roomList[index].isEmpty) {
          isRoomEmpty.value = true;
        } else {
          isRoomEmpty.value = false;
        }
        isLoading[index] = false;
        isLoadingMore[index] = false;
        update();
      } else {
        isLoading[index] = false;
        isLoadingMore[index] = false;
        update();
        errorAlert(title: 'Lỗi', desc: res['message']);
      }
    }).catchError((e) {
      checkToken(onDone: () {
        onRefresh();
      });
    });
  }

  Future fetchByStagesssss() async {
    var stageString = "";
    for (var x in stageFilterList) {
      stageString += "&Stage=${x["id"]}";
    }
    var ratingString = "";
    for (var x in ratingFilterList) {
      ratingString += "&Rating=${x["value"]}";
    }
    var memberString = "";
    for (var x in memberFilterList) {
      memberString += "&AssignTo=${x["profileId"]}";
    }
    var teamString = "";
    for (var x in teamFilterList) {
      teamString += "&TeamId=${x["id"]}";
    }
    var categoryString = "";
    for (var x in categoryList) {
      categoryString += "&CategoryList=${x.id}";
    }
    var sourceString = "";
    for (var x in sourceList) {
      sourceString += "&SourceList=${x.id}";
    }
    var tagString = "";
    for (var x in tagFilterList) {
      tagString += "&Tags=$x";
    }
    fromDate = DateTime(fromDate.year, fromDate.month, fromDate.day, 0, 0, 0);
    toDate = DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59);

    try {
      // Chỉ sử dụng API mới getStatisticsByStageGroup
      print("Đang gọi API getStatisticsByStageGroup");

      // Chuẩn bị các tham số
      final workspaceId = homeController.workGroupCardDataValue["id"];
      final searchText = searchController.text;
      final stageGroupId = groupId.value;
      final startDate = fromDate.toIso8601String();
      final endDate = toDate.toIso8601String();

      // Chỉ gửi các tham số không rỗng
      String? categoryListParam;
      if (categoryList.isNotEmpty) {
        categoryListParam = categoryList.map((e) => e.id).join(',');
      }

      String? sourceListParam;
      if (sourceList.isNotEmpty) {
        sourceListParam = sourceList.map((e) => e.id).join(',');
      }

      String? ratingParam;
      if (ratingFilterList.isNotEmpty) {
        ratingParam = ratingFilterList.map((e) => e["value"]).join(',');
      }

      String? tagsParam;
      if (tagFilterList.isNotEmpty) {
        tagsParam = tagFilterList.join(',');
      }

      String? assignToParam;
      if (memberFilterList.isNotEmpty) {
        assignToParam = memberFilterList.map((e) => e["profileId"]).join(',');
      }

      String? teamIdParam;
      if (teamFilterList.isNotEmpty) {
        teamIdParam = teamFilterList.map((e) => e["id"]).join(',');
      }

      print(
          "Tham số API: workspaceId=$workspaceId, searchText=$searchText, stageGroupId=$stageGroupId");

      // Gọi API
      final res = await CustomerApi().getStatisticsByStageGroup(
        workspaceId,
        searchText: searchText.isNotEmpty ? searchText : null,
        stageGroupId: stageGroupId.isNotEmpty ? stageGroupId : null,
        startDate: startDate,
        endDate: endDate,
        categoryList: categoryListParam,
        sourceList: sourceListParam,
        rating: ratingParam,
        tags: tagsParam,
        assignTo: assignToParam,
        teamId: teamIdParam,
      );

      print("Kết quả API: $res");

      if (res != null && isSuccessStatus(res["code"])) {
        List listData = res["content"] ?? [];
        print("Dữ liệu nhận được từ API: $listData");

        // Xử lý dữ liệu từ API
        stageCountObject.clear();

        for (var item in listData) {
          try {
            String groupName = item["groupName"]?.toString() ?? "";
            // Đảm bảo count không null và là kiểu int
            int count = 0;
            if (item["count"] != null) {
              if (item["count"] is int) {
                count = item["count"];
              } else {
                count = int.tryParse(item["count"].toString()) ?? 0;
              }
            }

            if (groupName.isNotEmpty) {
              // Cập nhật stageCountObject với dữ liệu mới
              stageCountObject[groupName] = count;
              print("Đã cập nhật nhóm: $groupName với số lượng: $count");
            }
          } catch (e) {
            print("Lỗi khi xử lý item: $item - Lỗi: $e");
          }
        }

        // Đảm bảo tất cả các nhóm đều có giá trị, nếu không có thì gán bằng 0
        for (var category in categories) {
          if (!stageCountObject.containsKey(category) && category != "Tất cả") {
            stageCountObject[category] = 0;
            print("Đã thêm nhóm thiếu: $category với số lượng: 0");
          }
        }

        // Tính tổng số lượng cho "Tất cả"
        num allCount = 0;
        for (var entry in stageCountObject.entries) {
          if (entry.key != "Tất cả") {
            allCount += entry.value ?? 0;
          }
        }
        stageCountObject["Tất cả"] = allCount;
        print("Tổng số lượng 'Tất cả': $allCount");
        print("Kết quả cuối cùng: $stageCountObject");
      } else {
        // Nếu API trả về lỗi, vẫn đảm bảo hiển thị UI với giá trị mặc định
        print("API trả về lỗi: ${res?["message"] ?? "Không xác định"}");
        stageCountObject.clear();
        for (var category in categories) {
          if (category != "Tất cả") {
            stageCountObject[category] = 0;
          }
        }
        stageCountObject["Tất cả"] = 0;

        if (res != null) {
          errorAlert(
              title: "Lỗi", desc: res["message"] ?? "Lỗi không xác định");
        }
      }
    } catch (e) {
      print("Lỗi khi gọi API getStatisticsByStageGroup: $e");
      // Nếu có lỗi, vẫn đảm bảo hiển thị UI với giá trị mặc định
      stageCountObject.clear();
      for (var category in categories) {
        if (category != "Tất cả") {
          stageCountObject[category] = 0;
        }
      }
      stageCountObject["Tất cả"] = 0;
    }

    update();
  }

  void countGroupStage(List<dynamic> listData) {
    stageCountObject.clear();
    for (var x in stageValueCustomerChartObject.entries) {
      var value = x.value;
      var count = 0;
      for (var y in value["data"] as List) {
        final name = y["name"];
        Map? matchingElement;
        try {
          matchingElement = listData.firstWhere((e) => e["stageName"] == name,
              orElse: () => {"count": 0});
        } catch (e) {
          matchingElement = {"count": 0};
        }

        var countValue =
            matchingElement != null ? (matchingElement["count"] ?? 0) : 0;
        y["count"] = countValue;
        count += y["count"] as int;
      }
      value["count"] = count;
      stageCountObject[value["name"]] = count;
    }
    num allCount = 0;
    for (var x in stageCountObject.values) {
      allCount += x ?? 0;
    }
    stageCountObject["Tất cả"] = allCount;
    update();
  }

  Future<void> _showNotification(message, {bool? autoCount = false}) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('coka_notification', 'coka_notification',
            channelDescription: 'your channel description',
            priority: Priority.min,
            importance: Importance.min,
            usesChronometer: autoCount!,
            groupAlertBehavior: GroupAlertBehavior.summary,
            onlyAlertOnce: true,
            ongoing: true);
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        1001, message['title'], message['body'], notificationDetails);
  }

// Tắt thông báo treo với ID cụ thể
  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(1001);
  }

  @override
  void callStateChanged(Call call, CallState state) {
    final customerController = Get.put(CustomerController());

    if (state.state == CallStateEnum.CALL_INITIATION) {
      Get.to(() => CallScreenWidget(
            helper,
            call,
            dataItem: customerController.dataItem,
          ));
    }
    print({"state": state.state});
    switch (state.state) {
      case CallStateEnum.FAILED:
      case CallStateEnum.ENDED:
        _showNotification({"title": "Cuộc gọi", "body": "Kết thúc cuộc gọi"});
        Timer(const Duration(seconds: 2), () {
          customerController.fetchJourney();
        });
        cancelNotification();
        if (timer != null) {
          timer!.cancel();
          timer = null;
        }
        break;
      case CallStateEnum.PROGRESS:
        _showNotification({"title": "Cuộc gọi", "body": "Đổ chuông"});
        break;
      case CallStateEnum.CONFIRMED:
        _startTimer();
        _showNotification({
          "title": customerController.dataItem["fullName"],
          "body": "Đang gọi..."
        }, autoCount: true);
        break;
    }
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      Duration duration = Duration(seconds: timer.tick);
      timeLabel.value = [duration.inMinutes, duration.inSeconds]
          .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
          .join(':');
      update();
    });
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {
    // TODO: implement onNewMessage
  }

  @override
  void onNewNotify(Notify ntf) {
    // TODO: implement onNewNotify
  }

  @override
  void registrationStateChanged(RegistrationState state) {
    // SỬA LỖI 7: Triển khai (implement) hàm listener này
    print('### TRẠNG THÁI SIP THAY ĐỔI: ${state.state} ###');

    if (state.state == RegistrationStateEnum.REGISTERED) {
      isSipRegistered.value = true;
      print("### SIP ĐÃ SẴN SÀNG ĐỂ GỌI (REGISTERED) ###");
    } else {
      // Bị lỗi, hoặc chưa đăng ký
      isSipRegistered.value = false;
      if (state.state == RegistrationStateEnum.REGISTRATION_FAILED) {
        print("### SIP ĐĂNG KÝ THẤT BẠI: ${state.cause} ###");
        Get.snackbar(
          'Lỗi kết nối cuộc gọi',
          'Đăng ký SIP thất bại: ${state.cause}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  void transportStateChanged(TransportState state) {
    // TODO: implement transportStateChanged
  }

  @override
  void onNewReinvite(ReInvite event) {
    // TODO: implement onNewReinvite
  }
}
// END: FILE WorkspaceMainController.dart
