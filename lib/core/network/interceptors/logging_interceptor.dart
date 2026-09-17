import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs request/response details in debug builds only.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '→ ${options.method} ${options.baseUrl}${options.path}',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint(
        '← ${response.statusCode} ${response.requestOptions.path}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '✖ ${err.response?.statusCode} ${err.requestOptions.path}: ${err.message}',
      );
    }
    handler.next(err);
  }
}
