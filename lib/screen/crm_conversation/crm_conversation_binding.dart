import 'package:get/get.dart';

import 'crm_conversation_controller.dart';

class CrmConversationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CrmConversationController());
  }
}