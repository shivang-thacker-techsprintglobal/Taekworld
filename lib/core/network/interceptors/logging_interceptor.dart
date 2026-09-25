import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs request/response details in debug builds only.
///
/// Prints a copy-pasteable `curl` (method, URL, headers, body) so mobile
/// API calls can be inspected from logcat / the Flutter console.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('→ ${options.method} ${options.uri}');
      debugPrint(_toCurl(options));
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

  String _toCurl(RequestOptions options) {
    final buffer = StringBuffer('curl -X ${options.method} ');
    buffer.write(_shellQuote(options.uri.toString()));

    options.headers.forEach((key, value) {
      if (value == null) return;
      if (key.toLowerCase() == 'content-length') return;
      buffer.write(' \\\n  -H ${_shellQuote('$key: $value')}');
    });

    final data = options.data;
    if (data != null) {
      final body = _bodyAsString(data);
      if (body != null && body.isNotEmpty) {
        buffer.write(' \\\n  -d ${_shellQuote(body)}');
      }
    }

    return buffer.toString();
  }

  String? _bodyAsString(Object data) {
    if (data is FormData) {
      return data.fields.map((e) => '${e.key}=${e.value}').join('&');
    }
    if (data is String) return data;
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  String _shellQuote(String value) {
    return "'${value.replaceAll("'", "'\\''")}'";
  }
}
