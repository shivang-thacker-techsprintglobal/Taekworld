import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/login/domain/entities/auth_session.dart';
import '../../features/login/domain/entities/user_entity.dart';

/// Platform secure store (Keychain / Keystore) for auth tokens + user snapshot.
///
/// Never store tokens in SharedPreferences.
class SecureSessionStorage {
  SecureSessionStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'auth.access_token';
  static const _refreshTokenKey = 'auth.refresh_token';
  static const _expiresAtKey = 'auth.expires_at';
  static const _userJsonKey = 'auth.user_json';

  final FlutterSecureStorage _storage;

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<DateTime?> readExpiresAt() async {
    final raw = await _storage.read(key: _expiresAtKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> saveSession(AuthSession session) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: session.accessToken),
      _storage.write(key: _refreshTokenKey, value: session.refreshToken),
      _storage.write(
        key: _expiresAtKey,
        value: session.expiresAt?.toUtc().toIso8601String() ?? '',
      ),
      _storage.write(
        key: _userJsonKey,
        value: jsonEncode(_userToMap(session.user)),
      ),
    ]);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    DateTime? expiresAt,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      _storage.write(
        key: _expiresAtKey,
        value: expiresAt?.toUtc().toIso8601String() ?? '',
      ),
    ]);
  }

  Future<AuthSession?> readSession() async {
    final accessToken = await readAccessToken();
    final refreshToken = await readRefreshToken();
    final userJson = await _storage.read(key: _userJsonKey);

    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty ||
        userJson == null ||
        userJson.isEmpty) {
      return null;
    }

    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return AuthSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: await readExpiresAt(),
        user: _userFromMap(map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> hasStoredSession() async {
    final refresh = await readRefreshToken();
    return refresh != null && refresh.isNotEmpty;
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _expiresAtKey),
      _storage.delete(key: _userJsonKey),
    ]);
  }

  Map<String, dynamic> _userToMap(UserEntity user) {
    return {
      'id': user.id,
      'email': user.email,
      'name': user.name,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'phoneNumber': user.phoneNumber,
      'academyId': user.academyId,
      'academyName': user.academyName,
      'status': user.status,
      'statusText': user.statusText,
      'role': user.role,
      'roles': user.roles,
    };
  }

  UserEntity _userFromMap(Map<String, dynamic> map) {
    final roles = (map['roles'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>['master'];

    return UserEntity(
      id: map['id'] as String? ?? '',
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      academyId: map['academyId'] as String? ?? '',
      academyName: map['academyName'] as String? ?? '',
      status: map['status'] as String? ?? '',
      statusText: map['statusText'] as String? ?? '',
      role: map['role'] as String? ?? 'master',
      roles: roles,
    );
  }
}

final secureSessionStorageProvider = Provider<SecureSessionStorage>((ref) {
  return SecureSessionStorage();
});
