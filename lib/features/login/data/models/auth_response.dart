import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_user_model.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

/// Shared shape for login, refresh-token, and profile responses.
@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    @Default(false) bool success,
    String? token,
    String? refreshToken,
    DateTime? expiresAt,
    int? expiresIn,
    AuthUserModel? user,
    String? message,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}
