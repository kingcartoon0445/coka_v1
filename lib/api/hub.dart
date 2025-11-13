import 'package:dio/dio.dart';

import '../constants.dart';
import 'api_config.dart';
import 'api_url.dart';

class HubApi {
  final dio = ApiConfig().dio;

  Future getListHubPaging(projectId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get(
          "$getListHubPagingApi?ProjectId=$projectId&Limit=100&Offset=0",
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

  Future getHubDetail(hubId) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.get("$getHubDetailApi$hubId",
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

  Future updateHubFeedMess(hubId, feed, message) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.patch("$updateHubFeedMessApi$hubId",
          data: {
            "feed": feed,
            "message": message,
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

  Future updateHubStatus(hubId, status) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.patch("$updateHubStatusApi$hubId",
          data: {"status": status},
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
