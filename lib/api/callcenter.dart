import 'dart:convert';

import 'package:coka/screen/home/home_controller.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../constants.dart';
import 'api_url.dart';

class CallCenterApi {
  final dio = Dio(BaseOptions(baseUrl: apiCallCenterUrl));

  Future callTracking(data) async {
    final apiToken = await getAccessToken();
    final homeController = Get.put(HomeController());
    try {
      final response = await dio.post("/api/v1/calltracking/int",
          data: data,
          options: Options(headers: {
            "Content-Type": "application/json",
            "workspaceId": homeController.workGroupCardDataValue["id"],
            "organizationId": jsonDecode(await getOData())["id"],
            "Authorization": "Bearer $apiToken",
          }));
      return response.data;
    } on DioException catch (e) {
      final response = e.response;
      if (response != null) {
        return response.data;
      } else {
        print(e.requestOptions);
        print(e.message);
      }
    }
  }

  Future getSetting() async {
    final apiToken = await getAccessToken();

    try {
      final response = await dio.get("/api/v1/user/line",
          options: Options(headers: {
            "Content-Type": "application/json",
            "organizationId": jsonDecode(await getOData())["id"],
            "Authorization": "Bearer $apiToken",
          }));
      return response.data;
    } on DioException catch (e) {
      final response = e.response;
      if (response != null) {
        return response.data;
      } else {
        print(e.requestOptions);
        print(e.message);
      }
    }
  }
}
