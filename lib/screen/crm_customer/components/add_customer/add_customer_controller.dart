import 'package:get/get.dart';

import '../../../../constants.dart';

class AddCustomerController extends GetxController {
  final avatarData = "".obs;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    avatarData.value=defaultAvatar;
  }
}