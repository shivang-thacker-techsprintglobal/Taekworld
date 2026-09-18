/// API path constants shared across features.
///
/// Feature-specific endpoints may also live next to their datasource;
/// put truly shared paths here.
abstract final class Api {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.taekworld.com',
  );

  static const String login = '/api/Auth/login';
  static const String profile = '/api/Auth/profile';
  static const String refreshToken = '/api/Auth/refresh-token';

  // Statistics & Trial Members
  static String statistics(String dojangId) => '/api/TrialMember/statistics/$dojangId';
  static String trialStudents(String dojangId) => '/api/TrialMember/students/$dojangId';

  // Applications
  static String applications(String dojangId) => '/api/NewStudent/applications/$dojangId';
  static String applicationDetail(String applicationId) => '/api/NewStudent/application/$applicationId';
  static String enroll(String applicationId) => '/api/TrialMember/enroll/$applicationId';

  // Notifications
  static const String registerDevice = '/api/Notification/register-device';
  static const String deleteDevice = '/api/Notification/delete-device';
}
