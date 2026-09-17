import 'package:dio/dio.dart';

/// Attaches authentication headers when a token is available.
///
/// Replace the token lookup with your secure storage / session provider.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({this.tokenProvider});

  /// Returns the current access token, or null if unauthenticated.
  final Future<String?> Function()? tokenProvider;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
