import 'dart:convert';

import 'package:dio/dio.dart';

import '../constants.dart';
import 'api_config.dart';
import 'api_url.dart';

class UserApi {
  final dio = ApiConfig().dio;
  Future getListProfile() async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(getProfileListApi,
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

  Future getProfile() async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(getProfileDetailApi,
          options: Options(headers: {
            "deviceId": await getDeviceId(),
            "version": await getVersion(),
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

  Future getUserProfile(profileId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(getProfileDetailApi + profileId,
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

  Future updateProfile(data) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.patch(patchProfileUpdateApi,
          data: data,
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

  Future switchProfile(data) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post(postProfileSwitchApi,
          data: data,
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

  Future updateFcmToken(data) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.put(updateFcmTokenApi,
          data: data,
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
