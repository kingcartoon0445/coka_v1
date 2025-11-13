import 'package:get/get.dart';

import 'action_selector_controller.dart';

class ActionSelectorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ActionSelectorController());
  }
}
