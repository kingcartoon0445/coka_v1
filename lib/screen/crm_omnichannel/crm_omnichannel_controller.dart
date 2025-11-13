import 'package:coka/screen/main/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/loading_dialog.dart';

class CrmOmnichannelController extends GetxController {
  MainController mainController = Get.put(MainController());
  final currentPage = 0.obs;
  final PageController pageController = PageController(initialPage: 0);

  final hubGroup = {}.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchHubList();
  }

  Future fetchHubList() async {
    hubGroup.clear();
    Future.delayed(const Duration(milliseconds: 50),
        () => showLoadingDialog(Get.context!));
  }
}
