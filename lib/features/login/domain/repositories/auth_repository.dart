import '../entities/auth_session.dart';
import '../entities/user_entity.dart';

/// Auth repository contract — domain stays free of Dio/storage details.
abstract class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<AuthSession> refreshToken();

  Future<AuthSession> getProfile();

  /// Cold start: profile → on 401 refresh → else clear and return null.
  Future<AuthSession?> restoreSession();

  Future<UserEntity?> readCachedUser();

  Future<void> clearSession();
}
