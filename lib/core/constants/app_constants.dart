/// Application-wide constants that are not design tokens.
abstract final class AppConstants {
  static const String appName = 'Taekworld';
  static const Duration defaultAnimationDuration = Duration(milliseconds: 250);
  static const int minPasswordLength = 6;

  /// Set to true to bypass backend APIs and use realistic UI test data
  static const bool useMockData = true;
}
