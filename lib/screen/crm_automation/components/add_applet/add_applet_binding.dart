import 'package:coka/screen/crm_automation/components/add_applet/add_applet_controller.dart';
import 'package:get/get.dart';

class AddAppletBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AddAppletController());
  }
}
