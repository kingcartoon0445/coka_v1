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
          "$getRoomListApi?provider=$provider&Limit=20&Offset=$offset&Sort=$sortDesc&SearchText=$searchText&Fields=personName&IntegrationAuthId=$integrationAuthId",
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
      final formData = FormData.fromMap(data);
      final response = await dio.post(sendConvApi,
          data: formData,
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

  Future sendConvAttachment({
    required String conversationId,
    String? message,
    required MultipartFile attachment,
  }) async {
    final apiToken = await getAccessToken();
    try {
      final formData = FormData.fromMap({
        "ConversationId": conversationId,
        if (message != null && message.isNotEmpty) "Message": message,
        "Attachment": attachment,
      });
      final response = await dio.post(
        sendConvApi,
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
            "Authorization": "Bearer $apiToken",
            "organizationId": jsonDecode(await getOData())["id"],
          },
        ),
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

  Future assignTo(convId, assignToProfileId) async {
    final apiToken = await getAccessToken();
    try {
      final response =
          await dio.patch('/api/v1/omni/conversation/$convId/assignto',
              data: {"assignTo": assignToProfileId},
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

  Future getConversationDetail(convId) async {
    final apiToken = await getAccessToken();
    try {
      final response =
          await dio.get('/api/v1/integration/omni/conversation/$convId',
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
