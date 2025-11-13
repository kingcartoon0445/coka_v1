import 'dart:convert';

import 'package:get/get.dart';

class FilterSelectorController extends GetxController {
  final orList = [].obs;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    orList.add([{}]);
    if (Get.arguments != null) {
      orList.value = jsonDecode(Get.arguments["orList"]);
    }

    update();
  }
}
