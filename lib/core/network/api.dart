/// API path constants shared across features.
///
/// Feature-specific endpoints may also live next to their datasource;
/// put truly shared paths here.
abstract final class Api {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com',
  );

  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';
}
