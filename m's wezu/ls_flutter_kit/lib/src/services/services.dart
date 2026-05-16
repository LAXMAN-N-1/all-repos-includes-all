import 'dart:developer' as dev;

/// Structured logger with colorized output and severity levels.
class Logger {
  final String name;
  static LogLevel _minLevel = LogLevel.debug;

  Logger(this.name);

  static void setLevel(LogLevel level) => _minLevel = level;

  void debug(String message, [dynamic data]) => _log(LogLevel.debug, message, data);
  void info(String message, [dynamic data]) => _log(LogLevel.info, message, data);
  void warning(String message, [dynamic data]) => _log(LogLevel.warning, message, data);
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error);
    if (stackTrace != null) dev.log(stackTrace.toString(), name: name);
  }

  void _log(LogLevel level, String message, [dynamic data]) {
    if (level.index < _minLevel.index) return;
    final prefix = _levelPrefix(level);
    final logMessage = data != null ? '$prefix $message | $data' : '$prefix $message';
    dev.log(logMessage, name: name);
  }

  String _levelPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug: return '🔍';
      case LogLevel.info: return 'ℹ️';
      case LogLevel.warning: return '⚠️';
      case LogLevel.error: return '❌';
    }
  }
}

enum LogLevel { debug, info, warning, error }

/// CSV export utility.
class CsvExportService {
  /// Converts a list of maps to CSV string.
  static String toCSV(List<Map<String, dynamic>> data, {List<String>? columns}) {
    if (data.isEmpty) return '';
    final cols = columns ?? data.first.keys.toList();
    final buffer = StringBuffer();
    buffer.writeln(cols.join(','));
    for (final row in data) {
      buffer.writeln(cols.map((c) => _escape(row[c]?.toString() ?? '')).join(','));
    }
    return buffer.toString();
  }

  static String _escape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
