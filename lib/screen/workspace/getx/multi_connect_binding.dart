import 'package:coka/screen/workspace/getx/multi_connect_controller.dart';
import 'package:get/get.dart';

class MultiConnectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MultiConnectController());
  }
}
