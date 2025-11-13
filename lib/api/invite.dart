import 'dart:convert';

import 'package:dio/dio.dart';

import '../constants.dart';
import 'api_config.dart';
import 'api_url.dart';

class InviteApi {
  final dio = ApiConfig().dio;
  Future getInviteList(searchText, status) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "$getOrgInviteListApi?SearchText=$searchText&Status=$status&limit=100",
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

  Future postOrgInvite(profileId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post(postOrgInviteApi,
          data: {"profileId": profileId},
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

  Future postRefuseInvite(inviteId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post("$postOrgRefuseInviteApi$inviteId",
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

  Future postAcceptInvite(inviteId, isAccept) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post(
          "$postOrgAcceptInviteApi?InviteId=$inviteId&IsAccept=$isAccept",
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

  Future getSearchProfile(searchText, offset) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "$getOrgSearchProfileApi?SearchText=$searchText&limit=15&offset=$offset",
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
