import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions/network_exceptions.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

/// Remote data source for authentication APIs.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final DioClient _client;

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        Api.login,
        data: request.toJson(),
      );

      final data = response.data;
      if (data == null) {
        throw const UnknownNetworkException('Empty login response.');
      }

      // Support both `{ ...user }` and `{ "data": { ...user } }` payloads.
      final payload = data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data;

      return LoginResponse.fromJson(payload);
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioClientProvider));
});
