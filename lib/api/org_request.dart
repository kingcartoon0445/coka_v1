import 'dart:convert';

import 'package:dio/dio.dart';

import '../constants.dart';
import 'api_config.dart';
import 'api_url.dart';

class OrgRequestApi {
  final dio = ApiConfig().dio;
  Future getRequestList(searchText, status) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "$getOrgRequestListApi?SearchText=$searchText&Status=$status&limit=100",
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

  Future postOrgRequest(oId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post(postOrgRequestApi,
          data: {},
          options: Options(headers: {
            "Content-Type": "application/json",
            "organizationId": oId,
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

  Future postAcceptRequest(inviteId, isAccept, oId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post(
          "$postOrgAcceptRequestApi?InviteId=$inviteId&IsAccept=$isAccept",
          data: {},
          options: Options(headers: {
            "Content-Type": "application/json",
            "organizationId": oId,
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

  Future postCancelRequest(inviteId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post("$postOrgCancelRequestApi$inviteId",
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

  Future getSearchOrg(searchText) async {
    final apiToken = await getAccessToken();
    try {
      final response =
          await dio.get("$getSearchOrgApi?SearchText=$searchText&limit=100",
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
}
