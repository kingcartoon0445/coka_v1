import 'package:get/get.dart';

class ContactDetailController extends GetxController {
  final dataContact = {}.obs;
  final dataProfileList = [].obs;
  final dataSocialList = [].obs;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    dataContact.value = Get.arguments;
    print(dataContact);
    dataProfileList.value = [
      {"type": "phone", "value": dataContact["phone"]},
      {"type": "address", "value": dataContact["address"]},
    ];
  }
}
