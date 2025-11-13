import 'package:coka/screen/home/home_controller.dart';
import 'package:coka/screen/main/getx/notification_controller.dart';
import 'package:get/get.dart';

import '../crm/crm_controller.dart';
import 'main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => CrmController());
    Get.lazyPut(() => NotificationController());

  }
}
