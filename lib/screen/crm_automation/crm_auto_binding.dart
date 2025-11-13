import 'package:coka/screen/crm_automation/crm_auto_controller.dart';
import 'package:get/get.dart';

class CrmAutoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CrmAutoController());
  }
}
