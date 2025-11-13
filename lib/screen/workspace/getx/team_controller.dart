import 'package:coka/api/team.dart';
import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:get/get.dart';

import '../../../components/awesome_alert.dart';

class TeamController extends GetxController {
  HomeController homeController = Get.put(HomeController());
  final isFetching = false.obs;
  final teamList = [].obs;
  final memberList = [].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchTeamList("");
  }

  Future fetchMemberList(teamId, searchText) async {
    isFetching.value = true;
    update();
    await TeamApi()
        .getMemberInTeamList(
            homeController.workGroupCardDataValue["id"], teamId, searchText)
        .then((res) {
      if (!isSuccessStatus(res["code"])) {
        return errorAlert(title: "Lỗi", desc: res["message"]);
      }
      memberList.value = res["content"];
      isFetching.value = false;
      update();
    });
  }

  Future fetchTeamList(searchText) async {
    isFetching.value = true;
    update();
    await TeamApi()
        .getTeamList(homeController.workGroupCardDataValue["id"], searchText)
        .then((res) {
      if (!isSuccessStatus(res["code"])) {
        return errorAlert(title: "Lỗi", desc: res["message"]);
      }
      teamList.value = res["content"];
      isFetching.value = false;
      update();
    });
  }
}
