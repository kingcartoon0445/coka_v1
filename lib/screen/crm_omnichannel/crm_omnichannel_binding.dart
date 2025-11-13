import 'package:get/get.dart';

import 'crm_omnichannel_controller.dart';

class CrmOmnichannelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CrmOmnichannelController());
  }
}