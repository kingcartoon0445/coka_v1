import 'package:get/get.dart';

import 'crm_customer_controller.dart';

class CrmCustomerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CrmCustomerController());
  }
}