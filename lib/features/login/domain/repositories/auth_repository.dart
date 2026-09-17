import '../entities/user_entity.dart';

/// Auth repository contract — domain layer stays free of Dio/API details.
abstract class AuthRepository {
  Future<UserEntity> login({
    required String email,
    required String password,
  });
}
