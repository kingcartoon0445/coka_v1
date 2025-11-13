import 'package:dio/dio.dart';

import '../constants.dart';
import 'api_config.dart';
import 'api_url.dart';

class NotificationApi {
  final dio = ApiConfig().dio;
  Future getNotificationList(offset) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "$getNotificationListApi?Limit=15&$sortDesc&offset=$offset",
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

  Future getNotificationListUnread(offset) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get("$getNotificationListUnreadApi",
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

  Future updateRead(id) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.put(
          "$updateNotificationReadApi?Limit=50&$sortDesc&notifyId=$id&Status=0",
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

  Future updateAllRead() async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post("/api/v1/notify/readall",
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
