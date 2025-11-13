import 'dart:convert';

import 'package:dio/dio.dart';

import '../constants.dart';
import 'api_url.dart';

class IftttApi {
  final dio = Dio(BaseOptions(baseUrl: apiAutomationUrl));

  Future createCam(input) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post('/api/ifttt/create',
          data: input,
          options: Options(headers: {
            "Content-Type": "application/json",
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

  Future testSendmail(displayName, email, password, port, smtpServer) async {
    try {
      final response = await dio.post('/api/ifttt/test-send-email',
          data: {
            "displayName": displayName,
            "email": email,
            "password": password,
            "port": port,
            "smtpServer": smtpServer
          },
          options: Options(headers: {
            "Content-Type": "application/json",
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

  Future getCamList() async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          '/api/ifttt/camlist?organizationId=${jsonDecode(await getOData())["id"]}&Limit=100',
          options: Options(headers: {
            "Content-Type": "application/json",
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

  // Hàm để chỉnh sửa một campaign
  Future updateCampaign(
      String campaignId, Map<String, dynamic> updatedData) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.patch(
        '/api/ifttt/camlist/$campaignId',
        data: updatedData,
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiToken",
        }),
      );

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

  Future updateCampaignStage(String campaignId, int newStage) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.patch(
        '/api/ifttt/camlist/$campaignId/update-stage?stage=$newStage',
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiToken",
        }),
      );

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

// Hàm để xóa một campaign
  Future deleteCampaign(String campaignId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.delete(
        '/api/ifttt/camlist/$campaignId',
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiToken",
        }),
      );

      return response.statusCode ==
          204; // Kiểm tra mã trạng thái 204 No Content
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
