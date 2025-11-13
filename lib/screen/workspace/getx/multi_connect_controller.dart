import 'package:coka/api/lead.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:get/get.dart';

import '../../../api/webform.dart';

class MultiConnectController extends GetxController {
  HomeController mainController = Get.put(HomeController());

  final isFetching = false.obs;
  final connectObject = {"webform": [], "faza": []}.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    onRefresh();
  }

  Future onRefresh() async {
    isFetching.value = true;
    connectObject.value = {"webform": [], "faza": []};
    update();
    await Future.wait([fetchWebForm(), fetchZaloForm(), fetchFbForm()]);
    isFetching.value = false;
    update();
  }

  Future fetchZaloForm() async {
    await LeadApi()
        .getZaloFormList(mainController.workGroupCardDataValue['id'])
        .then((res) {
      if (isSuccessStatus(res["code"])) {
        connectObject["faza"]?.addAll(res["content"]);
      } else {
        Get.back();
        errorAlert(title: "Lỗi", desc: res["message"]);
      }
    });
  }

  Future fetchFbForm() async {
    await LeadApi()
        .getFbLeadList(mainController.workGroupCardDataValue['id'],
            provider: "FACEBOOK")
        .then((res) {
      if (isSuccessStatus(res["code"])) {
        connectObject["faza"]?.addAll(res["content"]);
      } else {
        Get.back();
        errorAlert(title: "Lỗi", desc: res["message"]);
      }
    });
  }

  Future fetchWebForm() async {
    await WebformApi()
        .getWebsiteList(mainController.workGroupCardDataValue['id'])
        .then((res) {
      if (isSuccessStatus(res["code"])) {
        connectObject["webform"] = res["content"];
      } else {
        Get.back();
        errorAlert(title: "Lỗi", desc: res["message"]);
      }
    });
  }
}
