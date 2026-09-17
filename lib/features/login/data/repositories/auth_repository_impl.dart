import 'package:flutter_riverpod/flutter_riverpod.dart';

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
