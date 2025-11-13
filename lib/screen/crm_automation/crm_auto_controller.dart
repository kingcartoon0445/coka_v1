import 'package:coka/api/ifttt.dart';
import 'package:coka/components/awesome_alert.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:get/get.dart';

class CrmAutoController extends GetxController {
  final camList = [].obs;
  final isFetching = false.obs;
  final isEmpty = false.obs;
  final homeController = Get.put(HomeController());
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchCamList();
  }

  Future fetchCamList() async {
    isFetching.value = true;
    update();
    IftttApi().getCamList().then((res) {
      isFetching.value = false;
      update();
      if (res["campaigns"] != null) {
        camList.value = res["campaigns"];
        if (camList.isEmpty) {
          isEmpty.value = true;
        } else {
          isEmpty.value = false;
        }
        update();
      } else {
        errorAlert(
            title: "Lỗi",
            desc: res["message"] ?? "Đã có lỗi xảy ra vui lòng thử lại");
      }
    });
  }
}
