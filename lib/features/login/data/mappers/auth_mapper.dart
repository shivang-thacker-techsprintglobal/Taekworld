import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user_entity.dart';
import '../models/auth_response.dart';
import '../models/auth_user_model.dart';

/// Maps Auth API DTOs to domain objects.
extension AuthResponseMapper on AuthResponse {
  AuthSession toSession() {
    final accessToken = token;
    final refresh = refreshToken;
    final authUser = user;

    if (accessToken == null ||
        accessToken.isEmpty ||
        refresh == null ||
        refresh.isEmpty ||
        authUser == null) {
      throw const FormatException('Auth response is missing token or user.');
    }

    return AuthSession(
      accessToken: accessToken,
      refreshToken: refresh,
      expiresAt: expiresAt,
      user: authUser.toEntity(),
    );
  }
}

extension AuthUserModelMapper on AuthUserModel {
  UserEntity toEntity() {
    final resolvedName = () {
      final display = displayName?.trim();
      if (display != null && display.isNotEmpty) return display;
      final combined = '${firstName ?? ''} ${lastName ?? ''}'.trim();
      if (combined.isNotEmpty) return combined;
      return email;
    }();

    return UserEntity(
      id: uid,
      email: email,
      name: resolvedName,
      firstName: firstName ?? '',
      lastName: lastName ?? '',
      phoneNumber: phoneNumber ?? '',
      academyId: academyId ?? '',
      academyName: academyName ?? '',
      status: status ?? '',
      statusText: statusText ?? '',
      role: role ?? (roles.isNotEmpty ? roles.first : 'master'),
      roles: roles.isNotEmpty
          ? roles
          : (role != null ? [role!] : const ['master']),
    );
  }
}
