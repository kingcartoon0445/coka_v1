import 'package:dio/dio.dart';

import '../constants.dart';
import 'api_config.dart';
import 'api_url.dart';

class FbApi {
  final dio = ApiConfig().dio;

  Future fbGetListConversation(projectId, provider) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "$fbGetListConversationApi?projectId=$projectId&provider=$provider&Limit=100&Offset=0&IgnoreCache=true&Sort=",
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

  Future fbGetLongAccessToken(token) async {
    try {
      final response = await Dio().get(
          "https://graph.facebook.com/v16.0/oauth/access_token?grant_type=fb_exchange_token&client_id=1751811208512576&client_secret=4afe7155afcde011172f340625206fcc&fb_exchange_token=$token",
          options: Options(headers: {"Content-Type": "application/json"}));
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

  Future fbGetDetailConversation(hubId, convId, offset) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "$fbGetDetailConversationApi?&HubId=$hubId&ConversationId=$convId&limit=15&offset=$offset",
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

  Future fbConnect(accessToken, projectId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post(fbConnectApi,
          data: {"accessToken": accessToken, "projectId": projectId},
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

  Future fbSendMessage(hubId, conversationId, message) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post(fbSendMessageApi,
          data: {
            "hubId": hubId,
            "conversationId": conversationId,
            "message": message,
            "type": "message",
          },
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

  Future setGptPageStatus(hubId, promptMes, gptMes, promptFeed, gptFeed) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.patch(setGptPageStatusApi,
          data: {
            "gptMessage": gptMes,
            "gptMessagePrompt": promptMes,
            "gptFeed": gptFeed,
            "gptFeedPrompt": promptFeed,
          },
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

  Future updateReadStatus(conversationId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.patch("$updateReadStatusApi$conversationId",
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

  Future getSyncConversation(projectId) async {
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
}
