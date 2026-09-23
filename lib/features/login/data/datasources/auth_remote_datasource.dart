import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions/network_exceptions.dart';
import '../../../../core/network/interceptors/auth_interceptor.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/refresh_token_request.dart';

/// Remote data source for authentication APIs.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final DioClient _client;

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        Api.login,
        data: request.toJson(),
        options: Options(extra: const {AuthInterceptorKeys.skipAuth: true}),
      );
      return _parseAuthResponse(response.data);
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<AuthResponse> refreshToken(RefreshTokenRequest request) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        Api.refreshToken,
        data: request.toJson(),
        options: Options(extra: const {AuthInterceptorKeys.skipAuth: true}),
      );
      return _parseAuthResponse(response.data);
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<AuthResponse> getProfile() async {
    try {
      final response = await _client.get<Map<String, dynamic>>(Api.profile);
      return _parseAuthResponse(response.data);
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  /// Ends the server session. Requires Bearer token (do not skip auth).
  Future<void> logout() async {
    try {
      await _client.post<Map<String, dynamic>>(Api.logout, data: <String, dynamic>{});
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  AuthResponse _parseAuthResponse(Map<String, dynamic>? data) {
    if (data == null) {
      throw const UnknownNetworkException('Empty auth response.');
    }

    final payload = data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : data;

    return AuthResponse.fromJson(payload);
  }
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioClientProvider));
});
