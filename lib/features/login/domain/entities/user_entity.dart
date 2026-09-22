/// Authenticated master user (domain).
class UserEntity {
  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.academyId,
    this.firstName = '',
    this.lastName = '',
    this.phoneNumber = '',
    this.academyName = '',
    this.status = '',
    this.statusText = '',
    this.role = 'master',
    this.roles = const ['master'],
  });

  /// Backend `user.uid`.
  final String id;
  final String email;

  /// Display name preferred over first+last.
  final String name;
  final String firstName;
  final String lastName;
  final String phoneNumber;

  /// Dojang id (`user.academyId`) used in every authenticated path.
  final String academyId;
  final String academyName;
  final String status;
  final String statusText;
  final String role;
  final List<String> roles;

  int? get dojangId => int.tryParse(academyId);

  bool get isMaster {
    final candidates = <String>[role, ...roles];
    return candidates.any((r) => r.toLowerCase() == 'master');
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? academyId,
    String? academyName,
    String? status,
    String? statusText,
    String? role,
    List<String>? roles,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      academyId: academyId ?? this.academyId,
      academyName: academyName ?? this.academyName,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      role: role ?? this.role,
      roles: roles ?? this.roles,
    );
  }
}
