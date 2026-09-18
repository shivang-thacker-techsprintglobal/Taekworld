import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/exceptions/network_exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    if (AppConstants.useMockData) {
      // Simulate quick network latency for realistic UI feedback
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return UserEntity(
        id: '5688',
        email: email.isNotEmpty ? email : 'master@example.com',
        name: 'Master Kim',
        token: 'mock_bearer_token',
        academyId: '5688',
        academyName: 'Taekworld Academy',
        phoneNumber: '7037601000',
        status: 'Active',
        statusText: 'Active',
        role: 'master',
      );
    }

    try {
      final response = await _remote.login(
        LoginRequest(email: email, password: password),
      );
      return response.toEntity();
    } on NetworkException catch (error) {
      throw _mapNetworkException(error);
    } catch (_) {
      throw const UnexpectedFailure();
    }
  }

  Failure _mapNetworkException(NetworkException error) {
    return switch (error) {
      UnauthorizedException() || ForbiddenException() =>
        AuthFailure(error.message),
      NoInternetException() || TimeoutException() =>
        NetworkFailure(error.message),
      ServerException() || BadRequestException() || NotFoundException() =>
        ServerFailure(error.message),
      UnknownNetworkException() => UnexpectedFailure(error.message),
    };
  }
}

extension on LoginResponse {
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      token: token,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});
