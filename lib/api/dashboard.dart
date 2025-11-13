import 'dart:convert';
import 'dart:developer';

import 'package:coka/api/api_url.dart';
import 'package:coka/constants.dart';
import 'package:dio/dio.dart';

class DashboardApi {
  final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));

  Future getSummary(workspaceId, startDate, endDate) async {
    final apiToken = await getAccessToken();

    log("token: $apiToken");
    try {
      final response = await dio.get(
          "$getDashboardSummaryApi?workspaceId=$workspaceId&startDate=$startDate&endDate=$endDate",
          options: Options(headers: {
            "Content-Type": "application/json",
            "workspaceId": workspaceId,
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

  Future getStatisticByDataSource(workspaceId, startDate, endDate) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "$getDashboardByDataSource?workspaceId=$workspaceId&startDate=$startDate&endDate=$endDate",
          options: Options(headers: {
            "Content-Type": "application/json",
            "workspaceId": workspaceId,
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

  Future getStatisticByUtmSource(workspaceId, startDate, endDate) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "$getDashboardByUtmSource?workspaceId=$workspaceId&startDate=$startDate&endDate=$endDate",
          options: Options(headers: {
            "Content-Type": "application/json",
            "workspaceId": workspaceId,
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

  Future getStatisticByTag(workspaceId, startDate, endDate) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "$getDashboardByTag?workspaceId=$workspaceId&startDate=$startDate&endDate=$endDate",
          options: Options(headers: {
            "Content-Type": "application/json",
            "workspaceId": workspaceId,
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

  Future getStatisticByUser(workspaceId, startDate, endDate) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "$getDashboardByUser?workspaceId=$workspaceId&startDate=$startDate&endDate=$endDate",
          options: Options(headers: {
            "Content-Type": "application/json",
            "workspaceId": workspaceId,
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

  Future getOvertime(workspaceId, startDate, endDate, type) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "$getDashboardOverTime?workspaceId=$workspaceId&startDate=$startDate&endDate=$endDate&Type=$type",
          options: Options(headers: {
            "Content-Type": "application/json",
            "workspaceId": workspaceId,
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

  Future getByStage(workspaceId, startDate, endDate,
      {String? stageList = "",
      String? ratingList = "",
      String? memberList = "",
      String? teamList = "",
      String? categoryList = "",
      String? sourceList = "",
      String? tagList = "",
      String? searchText = ""}) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "$getDashboardByStage?workspaceId=$workspaceId&startDate=$startDate&endDate=$endDate$stageList$ratingList$memberList$teamList$categoryList$sourceList&SearchText=$searchText$tagList",
          options: Options(headers: {
            "Content-Type": "application/json",
            "workspaceId": workspaceId,
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

  Future getByRating(workspaceId, startDate, endDate) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "$getDashboardByRating?workspaceId=$workspaceId&startDate=$startDate&endDate=$endDate",
          options: Options(headers: {
            "Content-Type": "application/json",
            "workspaceId": workspaceId,
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
