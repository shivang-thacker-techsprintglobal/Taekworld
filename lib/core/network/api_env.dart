/// API host configuration for UAT and production.
///
/// Switch environments without touching call sites:
///
/// ```bash
/// # UAT (default while developing)
/// fvm flutter run --dart-define=API_ENV=uat
///
/// # Production
/// fvm flutter run --dart-define=API_ENV=production
///
/// # Optional full URL override (wins over API_ENV)
/// fvm flutter run --dart-define=API_BASE_URL=https://api.taekworld.com
/// ```
abstract final class ApiEnv {
  /// `uat` | `production` — defaults to UAT for development.
  static const String envName = String.fromEnvironment(
    'API_ENV',
    defaultValue: 'uat',
  );

  /// Optional absolute override. When non-empty, this wins over [envName].
  static const String baseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const String productionUrl = 'https://api.taekworld.com';
  static const String productionAliasUrl = 'https://api.blackbelthw.com';

  /// Cloud Run UAT host provided for the mobile rewrite.
  static const String uatUrl =
      'https://api-uat-433251623503.us-east4.run.app';

  static bool get isProduction =>
      current == ApiEnvironment.production;

  static bool get isUat => current == ApiEnvironment.uat;

  static ApiEnvironment get current {
    switch (envName.toLowerCase().trim()) {
      case 'production':
      case 'prod':
        return ApiEnvironment.production;
      case 'uat':
      case 'staging':
      case 'dev':
      default:
        return ApiEnvironment.uat;
    }
  }

  /// Resolved base URL (no trailing slash).
  static String get baseUrl {
    final override = baseUrlOverride.trim();
    if (override.isNotEmpty) {
      return _stripTrailingSlash(override);
    }

    return switch (current) {
      ApiEnvironment.production => productionUrl,
      ApiEnvironment.uat => uatUrl,
    };
  }

  static String _stripTrailingSlash(String url) {
    if (url.endsWith('/')) {
      return url.substring(0, url.length - 1);
    }
    return url;
  }
}

enum ApiEnvironment {
  uat,
  production,
}
