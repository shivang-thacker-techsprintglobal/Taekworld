/// Application-wide constants that are not design tokens.
abstract final class AppConstants {
  static const String appName = 'Taekworld Master';
  static const Duration defaultAnimationDuration = Duration(milliseconds: 250);
  static const Duration splashMinDuration = Duration(seconds: 2);
  static const Duration splashFadeInDuration = Duration(milliseconds: 800);
  static const int minPasswordLength = 6;

  /// Set to true to bypass backend APIs and use realistic UI test data.
  /// Keep false when integrating against UAT/production.
  static const bool useMockData = false;

  static const String webBaseUrl = 'https://www.blackbelthw.com';
  static const String notificationChannelId = 'taekworld_alerts_v2';
  static const String notificationChannelName = 'Taekworld Alerts';
  static const int maxLocalNotifications = 100;
  static const Duration deviceReregisterInterval = Duration(days: 1);
}
