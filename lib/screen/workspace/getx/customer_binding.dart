import 'package:coka/screen/workspace/getx/customer_controller.dart';
import 'package:get/get.dart';

class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CustomerController());
  }
}
