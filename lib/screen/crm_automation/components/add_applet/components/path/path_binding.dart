import 'package:get/get.dart';

import 'path_controller.dart';

class PathBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PathController());
  }
}
