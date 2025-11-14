import 'dart:convert';
import 'dart:developer';

import 'package:coka/api/api_url.dart';
import 'package:coka/constants.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DashboardApi {
  final dio = Dio(BaseOptions(baseUrl: apiBaseUrl))  ..interceptors.add(PrettyDioLogger(
      requestHeader: true, // 显示请求头
      requestBody: true, // 显示请求体
      responseBody: true, // 显示响应体
      responseHeader: false, // 不显示响应头（可选，减少日志量）
      error: true, // 显示错误信息
      compact: false, // 不压缩日志（显示完整格式）
      maxWidth: 90, // 日志最大宽度
    ));

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
