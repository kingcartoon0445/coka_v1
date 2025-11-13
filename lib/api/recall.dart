import 'dart:convert';

import 'package:dio/dio.dart';

import '../constants.dart';
import 'api_url.dart';

class RecallApi {
  final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));

  Future getRecall(workspaceId, teamId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get("/api/v1/automation/eviction/getdetail",
          options: Options(headers: {
            "Content-Type": "application/json",
            "workspaceId": workspaceId,
            "teamId": teamId,
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

  Future getRoutingLog(workspaceId, teamId, data) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get("/api/v1/automation/eviction/logs",
          data: data,
          options: Options(headers: {
            "Content-Type": "application/json",
            "workspaceId": workspaceId,
            "organizationId": jsonDecode(await getOData())["id"],
            if (teamId != null) "teamId": teamId,
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

  Future updateRouting(workspaceId, teamId, data) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.put("/api/v1/routing",
          data: data,
          options: Options(headers: {
            "Content-Type": "application/json",
            "workspaceId": workspaceId,
            "organizationId": jsonDecode(await getOData())["id"],
            if (teamId != null) "teamId": teamId,
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
