import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user_model.freezed.dart';
part 'auth_user_model.g.dart';

/// User payload nested under the Auth API response.
@freezed
class AuthUserModel with _$AuthUserModel {
  const factory AuthUserModel({
    required String uid,
    required String email,
    String? firstName,
    String? lastName,
    String? displayName,
    String? phoneNumber,
    String? role,
    @Default(<String>[]) List<String> roles,
    /// Dojang id used by every authenticated call. Wire format is a string.
    String? academyId,
    String? academyName,
    String? academyPhoneNumber,
    String? status,
    String? statusText,
    bool? isActive,
    String? userCode,
  }) = _AuthUserModel;

  const AuthUserModel._();

  factory AuthUserModel.fromJson(Map<String, dynamic> json) =>
      _$AuthUserModelFromJson(json);

  /// Client-side master gate (case-insensitive).
  bool get isMaster {
    final candidates = <String>[
      ...roles,
      ?role,
    ];
    return candidates.any((r) => r.toLowerCase() == 'master');
  }
}
