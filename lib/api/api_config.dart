import 'package:coka/constants.dart';
import 'dart:convert';
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

    // Custom logging interceptor: clearly separate REQUEST/HEADERS/BODY/RESPONSE/ERROR
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final String method = options.method;
        final Uri uri = options.uri;
        final dynamic data = options.data;
        final Map<String, dynamic> headers =
            Map<String, dynamic>.from(options.headers);

        // ignore: avoid_print
        print('===== REQUEST ===============================================');
        // ignore: avoid_print
        print('METHOD: $method  URL: $uri');
        // ignore: avoid_print
        print('--- HEADERS --------------------------------------------------');
        // ignore: avoid_print
        print(_safeJson(headers));
        // ignore: avoid_print
        print('--- BODY -----------------------------------------------------');
        // ignore: avoid_print
        print(_safeJson(data));
        // ignore: avoid_print
        print('===== END REQUEST ===========================================');

        return handler.next(options);
      },
      onResponse: (response, handler) {
        final int? status = response.statusCode;
        final Uri uri = response.requestOptions.uri;
        final Map<String, List<String>> headers = response.headers.map;
        final dynamic data = response.data;

        // ignore: avoid_print
        print('===== RESPONSE ==============================================');
        // ignore: avoid_print
        print('STATUS: $status  URL: $uri');
        // ignore: avoid_print
        print('--- HEADERS --------------------------------------------------');
        // ignore: avoid_print
        print(_safeJson(headers));
        // ignore: avoid_print
        print('--- BODY -----------------------------------------------------');
        // ignore: avoid_print
        print(_safeJson(data));
        // ignore: avoid_print
        print('===== END RESPONSE ==========================================');

        return handler.next(response);
      },
      onError: (err, handler) {
        // ignore: avoid_print
        print('===== ERROR ==================================================');
        // ignore: avoid_print
        print('TYPE: ${err.type}  MESSAGE: ${err.message}');
        if (err.response != null) {
          final int? status = err.response?.statusCode;
          final Uri uri = err.requestOptions.uri;
          // ignore: avoid_print
          print('STATUS: $status  URL: $uri');
          // ignore: avoid_print
          print(
              '--- RESPONSE HEADERS ----------------------------------------');
          // ignore: avoid_print
          print(_safeJson(err.response?.headers.map));
          // ignore: avoid_print
          print(
              '--- RESPONSE BODY -------------------------------------------');
          // ignore: avoid_print
          print(_safeJson(err.response?.data));
        }
        // ignore: avoid_print
        print('===== END ERROR =============================================');

        return handler.next(err);
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.headers["version"] = await getVersion();
        return handler.next(options);
      },
    ));
  }

  Dio get dio => _dio;
}

String _safeJson(dynamic value) {
  try {
    if (value == null) return 'null';
    // Convert Headers (Map<String, List<String>>) and other objects to encodable
    final dynamic normalized = _normalize(value);
    return const JsonEncoder.withIndent('  ').convert(normalized);
  } catch (_) {
    return value.toString();
  }
}

dynamic _normalize(dynamic value) {
  if (value == null) return null;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), _normalize(val)));
  }
  if (value is Iterable) {
    return value.map(_normalize).toList();
  }
  if (value is Uri) {
    return value.toString();
  }
  return value;
}
