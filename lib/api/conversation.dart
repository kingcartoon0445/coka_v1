import 'dart:convert';

import 'package:dio/dio.dart';

import '../constants.dart';
import 'api_config.dart';
import 'api_url.dart';

class ConvApi {
  final dio = ApiConfig().dio;

  Future getConvUnread() async {
    final apiToken = await getAccessToken();
    try {
      final response =
          await dio.get('/api/v1/omni/conversation/getlistpageunread',
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

  Future getRoomList(integrationAuthId, provider, offset,
      {String? searchText = ""}) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "$getRoomListApi?IntegrationAuthId=$integrationAuthId&provider=$provider&Limit=20&Offset=$offset&Sort=$sortDesc&SearchText=$searchText&Fields=personName",
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

  Future getConvList(convId, offset) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "$getConvListApi?ConversationId=$convId&Limit=20&Offset=$offset&IgnoreCache=true&Sort=",
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

  Future syncConv(projectId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post(syncConvApi,
          data: {"projectId": projectId},
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

  Future sendConv(data) async {
    final apiToken = await getAccessToken();
    try {
      final payload = Map<String, dynamic>.from(data)
        ..removeWhere((key, value) =>
            value == null ||
            value.toString().trim().isEmpty ||
            value == "undefined");

      final response = await dio.post(sendConvApi,
          data: FormData.fromMap(payload),
          options: Options(headers: {
            "Authorization": "Bearer $apiToken",
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

  Future setRead(convId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.patch('$setReadApi$convId',
          options: Options(headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $apiToken",
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
