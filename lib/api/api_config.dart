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

        return handler.next(options);
      },
      onResponse: (response, handler) {
        final int? status = response.statusCode;
        final Uri uri = response.requestOptions.uri;
        final Map<String, List<String>> headers = response.headers.map;
        final dynamic data = response.data;

        return handler.next(response);
      },
      onError: (err, handler) {
        // ignore: avoid_print

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
