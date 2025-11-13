import 'package:get/get.dart';

import 'trigger_selector_controller.dart';

class TriggerSelectorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TriggerSelectorController());
  }
}
