import 'package:get/get.dart';

import 'chat_channel_controller.dart';

class ChatChannelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatChannelController());
  }
}
