import 'package:dio/dio.dart';

import '../api.dart';
import '../api_env.dart';
import '../../storage/secure_session_storage.dart';

/// Extra flags for auth-related request handling.
abstract final class AuthInterceptorKeys {
  static const skipAuth = 'skipAuth';
  static const retried = 'authRetried';
}

/// Attaches Bearer tokens and refreshes once on 401.
///
/// Uses [QueuedInterceptor] so parallel 401s share a single refresh.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required SecureSessionStorage sessionStorage,
    void Function()? onSessionExpired,
  })  : _sessionStorage = sessionStorage,
        _onSessionExpired = onSessionExpired,
        _refreshDio = Dio(
          BaseOptions(
            baseUrl: ApiEnv.baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        );

  final SecureSessionStorage _sessionStorage;
  final void Function()? _onSessionExpired;
  final Dio _refreshDio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final skipAuth = options.extra[AuthInterceptorKeys.skipAuth] == true;
    if (!skipAuth) {
      final token = await _sessionStorage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final alreadyRetried =
        err.requestOptions.extra[AuthInterceptorKeys.retried] == true;
    final skipAuth =
        err.requestOptions.extra[AuthInterceptorKeys.skipAuth] == true;

    if (statusCode != 401 || alreadyRetried || skipAuth) {
      handler.next(err);
      return;
    }

    try {
      final refreshed = await _refreshTokens();
      if (!refreshed) {
        await _sessionStorage.clear();
        _onSessionExpired?.call();
        handler.next(err);
        return;
      }

      final token = await _sessionStorage.readAccessToken();
      final request = err.requestOptions;
      request.headers['Authorization'] = 'Bearer $token';
      request.extra[AuthInterceptorKeys.retried] = true;

      final response = await _refreshDio.fetch<dynamic>(request);
      handler.resolve(response);
    } catch (_) {
      await _sessionStorage.clear();
      _onSessionExpired?.call();
      handler.next(err);
    }
  }

  Future<bool> _refreshTokens() async {
    final refreshToken = await _sessionStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    final response = await _refreshDio.post<Map<String, dynamic>>(
      Api.refreshToken,
      data: {'refreshToken': refreshToken},
    );

    final data = response.data;
    if (data == null) return false;

    final accessToken = data['token'] as String?;
    final newRefresh = data['refreshToken'] as String?;
    if (accessToken == null ||
        accessToken.isEmpty ||
        newRefresh == null ||
        newRefresh.isEmpty) {
      return false;
    }

    DateTime? expiresAt;
    final expiresRaw = data['expiresAt'];
    if (expiresRaw is String) {
      expiresAt = DateTime.tryParse(expiresRaw);
    }

    await _sessionStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: newRefresh,
      expiresAt: expiresAt,
    );
    return true;
  }
}
