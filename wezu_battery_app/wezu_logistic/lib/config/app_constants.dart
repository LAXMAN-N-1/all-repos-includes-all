import 'package:flutter/foundation.dart';

/// App-wide constants and configuration values.
class AppConstants {
  AppConstants._();

  // ─── App Info ─────────────────────────────────────────────────────
  static const String appName = 'wezu logistics';
  static const String appVersion = '1.0.0';

  // ─── API ──────────────────────────────────────────────────────────
  static String get _platformDefaultApiBaseUrl {
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return 'http://127.0.0.1:8000/api/v1';
    }
    // Android emulator host loopback to local machine backend.
    return 'http://10.0.2.2:8000/api/v1';
  }

  static String get apiBaseUrl {
    const configured = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    final baseUrl = configured.isNotEmpty
        ? configured
        : _platformDefaultApiBaseUrl;
    return baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
  }

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ─── Pagination ───────────────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ─── Storage Keys ─────────────────────────────────────────────────
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'app_theme';
  static const String onboardingKey = 'onboarding_complete';
  static const String notificationsAppScope = 'logistics';
  static const String pushDeviceTokenKey = 'push_device_token';
  static const String pushDeviceIdKey = 'push_device_id';

  // ─── Animation Durations ──────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration splashDelay = Duration(seconds: 2);

  // ─── Asset Paths ──────────────────────────────────────────────────
  static const String assetIcons = 'assets/icons';
  static const String assetImages = 'assets/images';

  // ─── Input Constraints ────────────────────────────────────────────
  static const int maxEmailLength = 254;
  static const int minPasswordLength = 4;
  static const int maxPasswordLength = 128;
  static const int phoneLength = 10;

  // ─── Battery Thresholds ───────────────────────────────────────────
  static const int batteryFullThreshold = 80;
  static const int batteryMediumThreshold = 40;
  static const int batteryLowThreshold = 20;

  // ─── Google Maps ──────────────────────────────────────────────────
  /// Pass via:
  /// --dart-define=GOOGLE_MAPS_API_KEY=your_key_here
  static String get googleMapsApiKey {
    const configured = String.fromEnvironment(
      'GOOGLE_MAPS_API_KEY',
      defaultValue: '',
    );
    return configured.trim();
  }

  /// Web uses a safe fallback view by default to avoid runtime crashes when
  /// Google Maps JS is not injected in `web/index.html`.
  static bool get isWebGoogleMapsEnabled {
    const configured = String.fromEnvironment(
      'ENABLE_WEB_GOOGLE_MAPS',
      defaultValue: 'false',
    );
    final normalized = configured.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }

  static const String directionsApiUrl =
      'https://maps.googleapis.com/maps/api/directions/json';

  // ─── Tracking ─────────────────────────────────────────────────────
  static const Duration locationPollInterval = Duration(seconds: 30);
  static const double delayAlertThresholdMinutes = 15;
}
