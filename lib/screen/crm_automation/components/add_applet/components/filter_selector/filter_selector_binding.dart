import 'package:coka/screen/crm_automation/components/add_applet/components/filter_selector/filter_selector_controller.dart';
import 'package:get/get.dart';

class FilterSelectorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FilterSelectorController());
  }
}
