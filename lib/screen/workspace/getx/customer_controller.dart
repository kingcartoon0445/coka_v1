import 'package:coka/api/customer.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:get/get.dart';

class CustomerController extends GetxController {
  HomeController homeController = Get.put(HomeController());

  final dataItem = {}.obs;
  final stageId = "".obs;
  final isNew = false.obs;
  final journeyList = [].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    dataItem.value = Get.arguments;

    // stageId.value = dataItem["stage"]["id"];
    stageObject.forEach((key, value) {
      print(value["name"]);
    });
    fetchJourney();
    fetchDetailCustomer();
  }

  Future fetchDetailCustomer() async {
    update();
    CustomerApi()
        .getDetailCustomer(
            homeController.workGroupCardDataValue['id'], dataItem["id"])
        .then((res) {
      if (isSuccessStatus(res['code'])) {
        dataItem.value = res['content'];

        update();
      } else {
        update();
        errorAlert(title: 'Lỗi', desc: res['message']);
      }
    });
  }

  Future fetchJourney() async {
    isLoading.value = true;
    update();
    CustomerApi()
        .getJourneyList(
            homeController.workGroupCardDataValue['id'], dataItem["id"])
        .then((res) {
      if (isSuccessStatus(res['code'])) {
        journeyList.value = res['content'].toList();
        isLoading.value = false;

        update();
      } else {
        isLoading.value = false;
        update();
        errorAlert(title: 'Lỗi', desc: res['message']);
      }
    });
  }
}
