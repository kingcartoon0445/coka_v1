import 'dart:convert';

import 'package:dio/dio.dart';

import '../constants.dart';
import 'api_config.dart';
import 'api_url.dart';

class WebformApi {
  final dio = ApiConfig().dio;

  Future getWebsiteList(workspaceId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get("$getWebsiteListApi?Limit=100&Offset=0",
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

  Future addWebsite(domain, workspaceId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post(addWebsiteApi,
          data: {"url": domain, "type": "DOMAIN"},
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

  Future deleteWebsite(id, workspaceId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.delete("$deleteWebsiteApi$id",
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

  Future verifyWebsite(id, workspaceId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post("$verifyWebsiteApi$id",
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

  Future updateStatusWebsite(id, workspaceId, status) async {
    final apiToken = await getAccessToken();
    try {
      final response =
          await dio.patch("$updateStatusWebsiteApi$id?Status=$status",
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
