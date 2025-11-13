import 'package:dio/dio.dart';

import '../constants.dart';
import 'api_url.dart';

class AutomationApi {
  final dio = Dio(BaseOptions(baseUrl: apiAutomationUrl));
  Future createChat(message) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post(createChatApi,
          data: {"message": message},
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
