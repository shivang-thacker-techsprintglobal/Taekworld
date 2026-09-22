import 'user_entity.dart';

/// Persisted auth session (tokens + user).
class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.expiresAt,
  });

  final UserEntity user;
  final String accessToken;
  final String refreshToken;
  final DateTime? expiresAt;

  bool get isAccessTokenExpired {
    if (expiresAt == null) return false;
    return DateTime.now().toUtc().isAfter(expiresAt!.toUtc());
  }

  /// True when the access token should be refreshed soon (2 min buffer).
  bool get shouldRefreshProactively {
    if (expiresAt == null) return false;
    final refreshAt = expiresAt!.toUtc().subtract(const Duration(minutes: 2));
    return DateTime.now().toUtc().isAfter(refreshAt);
  }
}
