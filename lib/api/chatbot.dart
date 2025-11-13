import 'dart:convert';

import 'package:dio/dio.dart';

import '../constants.dart';
import 'api_config.dart';

class ChatBotApi {
  final dio = ApiConfig().dio;
  Future getList() async {
    final apiToken = await getAccessToken();
    try {
      final response =
          await dio.get("/api/v1/omni/chatbot/getlistpaging?Limit=200",
              options: Options(headers: {
                "organizationId": jsonDecode(await getOData())["id"],
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

  Future create(data) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post("/api/v1/omni/chatbot/create",
          data: data,
          options: Options(headers: {
            "organizationId": jsonDecode(await getOData())["id"],
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

  Future update(data, id) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.patch("/api/v1/omni/chatbot/update/$id",
          data: data,
          options: Options(headers: {
            "organizationId": jsonDecode(await getOData())["id"],
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

  Future updateStatus(status, id) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.patch("/api/v1/omni/chatbot/updatestatus/$id",
          data: {"status": status},
          options: Options(headers: {
            "organizationId": jsonDecode(await getOData())["id"],
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

  Future delete(id) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.delete("/api/v1/omni/chatbot/delete/$id",
          options: Options(headers: {
            "organizationId": jsonDecode(await getOData())["id"],
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
