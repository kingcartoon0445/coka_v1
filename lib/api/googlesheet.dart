import 'dart:convert';

import 'package:coka/constants.dart';
import 'package:coka/screen/home/home_controller.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'api_url.dart';

class GoogleSheetApi {
  final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
  Future urlCheck(url, targetRow) async {
    final apiToken = await getAccessToken();
    final homeController = Get.put(HomeController());
    try {
      final response =
          await dio.post("/api/v1/crm/googlesheet/mappinggenerator",
              data: {"formUrl": url, "targetRow": targetRow},
              options: Options(headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $apiToken",
                "workspaceId": homeController.workGroupCardDataValue["id"],
                "organizationId": jsonDecode(await getOData())["id"],
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

  Future importData(data) async {
    final apiToken = await getAccessToken();
    final homeController = Get.put(HomeController());
    try {
      final response = await dio.post("/api/v1/crm/googlesheet/import",
          data: data,
          options: Options(headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $apiToken",
            "workspaceId": homeController.workGroupCardDataValue["id"],
            "organizationId": jsonDecode(await getOData())["id"],
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
