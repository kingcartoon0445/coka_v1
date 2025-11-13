import 'package:coka/api/lead.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:get/get.dart';

class ChatChannelController extends GetxController {
  final homeController = Get.put(HomeController());
  final isChannelEmpty = false.obs;
  final channelList = [].obs;
  final isChannelFetching = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    onRefresh();
  }

  Future onRefresh() async {
    isChannelFetching.value = true;
    channelList.clear();
    update();
    await Future.wait([fetchChannelList()]);
    isChannelFetching.value = false;
    update();
  }

  Future fetchChannelList() async {
    await LeadApi().getFbMessageList().then((res) {
      if (isSuccessStatus(res["code"])) {
        channelList.value = res["content"];
        if (channelList.isEmpty) {
          isChannelEmpty.value = true;
        } else {
          isChannelEmpty.value = false;
        }
      } else {
        if (res["message"].contains("không có quyền")) {
          Get.back();
        }
        errorAlert(title: "Lỗi", desc: res["message"]);
      }
    });
  }
}
