import 'package:coka/screen/workspace/getx/dashboard_controller.dart';
import 'package:coka/screen/workspace/getx/multi_connect_controller.dart';
import 'package:get/get.dart';

import 'getx/customer_controller.dart';
import 'getx/team_controller.dart';
import 'main_controller.dart';

class WorkspaceMainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WorkspaceMainController());
    Get.lazyPut(() => TeamController());
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => CustomerController());
    Get.lazyPut(() => MultiConnectController());
  }
}
