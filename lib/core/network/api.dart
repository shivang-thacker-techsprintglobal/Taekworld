import 'api_env.dart';

/// Shared API path constants.
///
/// Feature datasources compose these paths; never hardcode hosts there.
/// Base URL comes from [ApiEnv] (UAT / production / override).
abstract final class Api {
  static String get baseUrl => ApiEnv.baseUrl;

  static const String health = '/api/health';

  // Auth
  static const String login = '/api/Auth/login';
  static const String profile = '/api/Auth/profile';
  static const String refreshToken = '/api/Auth/refresh-token';

  // Dashboard
  static String statistics(String dojangId) =>
      '/api/TrialMember/statistics/$dojangId';

  // Trial members — same path, different `category` query values
  static const String trialCategorySevenDay = '7 days trial';
  static const String trialCategoryThirtyDay = '30 days trial';

  static String trialMembers(String dojangId) =>
      '/api/TrialMember/students/$dojangId';

  // Applications
  static String applications(String dojangId) =>
      '/api/NewStudent/applications/$dojangId';
  static String applicationDetail(String applicationId) =>
      '/api/NewStudent/application/$applicationId';

  // Notifications
  static const String registerDevice = '/api/Notification/register-device';
  static const String deleteDevice = '/api/Notification/delete-device';
}
