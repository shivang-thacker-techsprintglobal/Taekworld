/// Authenticated user domain entity.
class UserEntity {
  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.token,
    this.academyId = '5688',
    this.academyName = 'Taekworld Academy',
    this.phoneNumber = '',
    this.status = 'Active',
    this.statusText = 'Active',
    this.role = 'master',
  });

  final String id;
  final String email;
  final String name;
  final String? token;
  final String academyId;
  final String academyName;
  final String phoneNumber;
  final String status;
  final String statusText;
  final String role;
}
