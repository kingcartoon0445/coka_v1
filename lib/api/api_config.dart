import 'package:coka/constants.dart';
import 'package:dio/dio.dart';

import 'api_url.dart';

class ApiConfig {
  static final ApiConfig _singleton = ApiConfig._internal();
  late Dio _dio;

  factory ApiConfig() {
    return _singleton;
  }

  ApiConfig._internal() {
    BaseOptions options = BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 17),
      receiveTimeout: const Duration(seconds: 17),
    );

    _dio = Dio(options);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.headers["version"] = await getVersion();
        return handler.next(options);
      },
    ));
  }

  Dio get dio => _dio;
}
