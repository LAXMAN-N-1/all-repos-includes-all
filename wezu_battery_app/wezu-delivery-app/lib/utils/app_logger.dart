import 'package:flutter/foundation.dart';

class AppLogger {
  final String tag;

  AppLogger(this.tag);

  void info(String message) {
    debugPrint('INFO: [$tag] $message');
  }

  void warning(String message) {
    debugPrint('WARNING: [$tag] $message');
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('ERROR: [$tag] $message');
    if (error != null) {
      debugPrint(error.toString());
    }
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}
