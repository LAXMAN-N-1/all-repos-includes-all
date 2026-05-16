import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:wezu_customer_app/core/constants/api_constants.dart';

/// App-wide configuration sourced from build-time --dart-define flags.
/// String.fromEnvironment requires a string literal key — each getter is inlined.
class AppConfig {
  // ── Google Maps ─────────────────────────────────────────────────────────────
  static String get googleMapsApiKey {
    if (kIsWeb) {
      return const String.fromEnvironment('GOOGLE_MAPS_API_KEY_WEB', defaultValue: '');
    }
    if (Platform.isAndroid) {
      return const String.fromEnvironment('GOOGLE_MAPS_API_KEY_ANDROID', defaultValue: '');
    }
    return const String.fromEnvironment('GOOGLE_MAPS_API_KEY_IOS', defaultValue: '');
  }

  // ── Google Sign In ───────────────────────────────────────────────────────────
  static String get googleClientId {
    if (kIsWeb) {
      return const String.fromEnvironment('GOOGLE_OAUTH_CLIENT_ID', defaultValue: '');
    }
    if (Platform.isAndroid) {
      return const String.fromEnvironment('GOOGLE_OAUTH_ANDROID_CLIENT_ID', defaultValue: '');
    }
    return const String.fromEnvironment('GOOGLE_OAUTH_IOS_CLIENT_ID', defaultValue: '');
  }

  // ── Razorpay ─────────────────────────────────────────────────────────────────
  static const String razorpayKeyId =
      String.fromEnvironment('RAZORPAY_KEY_ID', defaultValue: '');

  // ── API Base URL ─────────────────────────────────────────────────────────────
  static String get apiBaseUrl {
    const configured = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    return configured.isNotEmpty ? configured : ApiConstants.customerApiUrl;
  }
}
