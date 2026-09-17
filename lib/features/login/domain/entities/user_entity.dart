/// Authenticated user domain entity.
class UserEntity {
  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.token,
  });

  final String id;
  final String email;
  final String name;
  final String? token;
}
