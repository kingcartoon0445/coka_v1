import 'package:dio/dio.dart';

import '../constants.dart';
import 'api_config.dart';
import 'api_url.dart';

class AuthApi {
  final dio = ApiConfig().dio;

  void sendTelegramMessage(error) async {
    final dio = Dio();
    await dio.get(
        'https://api.telegram.org/bot6208718511:AAHk8gGXV4hpwqBdR5eXfOXEKj9c2wX3XnU/sendMessage',
        queryParameters: {'chat_id': '2067995285', 'text': error});
  }

  Future socialLogin(accessToken, provider) async {
    try {
      final response = await dio.post(socialLoginApi,
          data: {
            "provider": provider,
            "accessToken": accessToken,
          },
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

  Future userNameLogin(userName) async {
    try {
      final response = await dio.post(phoneLoginApi,
          data: {"userName": userName},
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

  Future verifyOtp(otpId, code) async {
    try {
      final response = await dio.post(verifyOtpApi,
          data: {"otpId": otpId, "code": code},
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

  Future resendOtp(otpId) async {
    try {
      final response = await dio.post(resendOtpApi,
          data: {"otpId": otpId},
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

  Future refreshToken(refreshToken) async {
    final apiToken = await getAccessToken();
    try {
      final response = await dio.post(refreshTokenApi,
          data: {"refreshToken": refreshToken},
          options: Options(headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $apiToken"
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
