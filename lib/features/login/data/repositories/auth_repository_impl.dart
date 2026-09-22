import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/exceptions/network_exceptions.dart';
import '../../../../core/storage/secure_session_storage.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../mappers/auth_mapper.dart';
import '../models/login_request.dart';
import '../models/refresh_token_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required SecureSessionStorage sessionStorage,
  })  : _remote = remote,
        _sessionStorage = sessionStorage;

  final AuthRemoteDataSource _remote;
  final SecureSessionStorage _sessionStorage;

  static const _masterOnlyMessage =
      'This app is for school masters only. Please use an account with the master role.';

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remote.login(
        LoginRequest(email: email, password: password),
      );

      if (response.success == false && response.user == null) {
        throw AuthFailure(
          response.message ?? 'That email or password doesn\'t seem to match.',
        );
      }

      final session = response.toSession();
      _ensureMaster(session.user);
      await _sessionStorage.saveSession(session);
      return session;
    } on Failure {
      rethrow;
    } on FormatException catch (error) {
      throw UnexpectedFailure(error.message);
    } on NetworkException catch (error) {
      throw _mapNetworkException(error);
    } catch (_) {
      throw const UnexpectedFailure();
    }
  }

  @override
  Future<AuthSession> refreshToken() async {
    try {
      final refresh = await _sessionStorage.readRefreshToken();
      if (refresh == null || refresh.isEmpty) {
        throw const AuthFailure('Session expired. Please sign in again.');
      }

      final response = await _remote.refreshToken(
        RefreshTokenRequest(refreshToken: refresh),
      );
      final session = response.toSession();
      _ensureMaster(session.user);
      await _sessionStorage.saveSession(session);
      return session;
    } on Failure {
      rethrow;
    } on FormatException catch (error) {
      throw UnexpectedFailure(error.message);
    } on NetworkException catch (error) {
      throw _mapNetworkException(error);
    } catch (_) {
      throw const UnexpectedFailure();
    }
  }

  @override
  Future<AuthSession> getProfile() async {
    try {
      final response = await _remote.getProfile();
      final session = response.toSession();
      _ensureMaster(session.user);

      // Profile may echo the request token; keep existing refresh if absent.
      final existingRefresh = await _sessionStorage.readRefreshToken();
      final merged = AuthSession(
        user: session.user,
        accessToken: session.accessToken,
        refreshToken: session.refreshToken.isNotEmpty
            ? session.refreshToken
            : (existingRefresh ?? ''),
        expiresAt: session.expiresAt,
      );

      if (merged.refreshToken.isEmpty) {
        throw const AuthFailure('Session expired. Please sign in again.');
      }

      await _sessionStorage.saveSession(merged);
      return merged;
    } on Failure {
      rethrow;
    } on FormatException catch (error) {
      throw UnexpectedFailure(error.message);
    } on NetworkException catch (error) {
      throw _mapNetworkException(error);
    } catch (_) {
      throw const UnexpectedFailure();
    }
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final cached = await _sessionStorage.readSession();
    if (cached == null) return null;

    Future<AuthSession?> tryRefresh() async {
      try {
        return await refreshToken();
      } on Failure {
        await _sessionStorage.clear();
        return null;
      }
    }

    if (cached.shouldRefreshProactively) {
      return tryRefresh();
    }

    try {
      return await getProfile();
    } on AuthFailure catch (failure) {
      if (failure.message == _masterOnlyMessage) {
        await _sessionStorage.clear();
        return null;
      }
      return tryRefresh();
    } on Failure {
      return tryRefresh();
    }
  }

  @override
  Future<UserEntity?> readCachedUser() async {
    final session = await _sessionStorage.readSession();
    return session?.user;
  }

  @override
  Future<void> clearSession() => _sessionStorage.clear();

  void _ensureMaster(UserEntity user) {
    if (!user.isMaster) {
      throw const AuthFailure(_masterOnlyMessage);
    }
  }

  Failure _mapNetworkException(NetworkException error) {
    return switch (error) {
      UnauthorizedException() => AuthFailure(error.message),
      ForbiddenException() => AuthFailure(error.message),
      RateLimitException() => AuthFailure(error.message),
      NoInternetException() || TimeoutException() =>
        NetworkFailure(error.message),
      ServerException() || BadRequestException() || NotFoundException() =>
        ServerFailure(error.message),
      UnknownNetworkException() => UnexpectedFailure(error.message),
    };
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    sessionStorage: ref.watch(secureSessionStorageProvider),
  );
});
