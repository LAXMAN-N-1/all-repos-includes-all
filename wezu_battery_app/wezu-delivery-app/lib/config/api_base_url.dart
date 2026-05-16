import 'package:flutter/foundation.dart';

/// Resolves backend base URL for each platform.
///
/// Override with:
/// --dart-define=API_BASE_URL=http://YOUR_HOST:8000/api/v1
class ApiBaseUrl {
  ApiBaseUrl._();

  static String resolve() {
    const configured = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    final raw = configured.trim().isNotEmpty
        ? configured.trim()
        : _platformDefault();
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }

  static String _platformDefault() {
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return 'http://127.0.0.1:8000/api/v1';
    }
    return 'http://10.0.2.2:8000/api/v1';
  }
}
