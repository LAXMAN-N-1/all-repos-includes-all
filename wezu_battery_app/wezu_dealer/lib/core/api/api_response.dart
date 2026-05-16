import 'package:dio/dio.dart';

/// Shared helpers to normalize backend payloads and errors across providers.
class ApiResponse {
  static dynamic unwrap(dynamic payload) {
    if (payload is Map) {
      final data = payload['data'];
      if (data != null) return data;
    }
    return payload;
  }

  static Map<String, dynamic> asMap(
    dynamic payload, {
    List<String> keys = const [],
  }) {
    final unwrapped = unwrap(payload);
    if (unwrapped is Map<String, dynamic>) return unwrapped;
    if (unwrapped is Map) return Map<String, dynamic>.from(unwrapped);

    if (payload is Map<String, dynamic>) {
      for (final key in keys) {
        final value = payload[key];
        if (value is Map<String, dynamic>) return value;
        if (value is Map) return Map<String, dynamic>.from(value);
      }
      return payload;
    }
    if (payload is Map) return Map<String, dynamic>.from(payload);
    return <String, dynamic>{};
  }

  static List<dynamic> asList(
    dynamic payload, {
    List<String> keys = const [],
  }) {
    final unwrapped = unwrap(payload);
    if (unwrapped is List) return unwrapped;

    if (unwrapped is Map<String, dynamic>) {
      for (final key in keys) {
        final value = unwrapped[key];
        if (value is List) return value;
      }
      for (final key in const [
        'items',
        'results',
        'tickets',
        'customers',
        'notifications',
        'alerts'
      ]) {
        final value = unwrapped[key];
        if (value is List) return value;
      }
    }

    if (payload is Map<String, dynamic>) {
      for (final key in keys) {
        final value = payload[key];
        if (value is List) return value;
      }
      for (final key in const [
        'items',
        'results',
        'tickets',
        'customers',
        'notifications',
        'alerts'
      ]) {
        final value = payload[key];
        if (value is List) return value;
      }
      final data = payload['data'];
      if (data is List) return data;
      if (data is Map<String, dynamic>) {
        for (final key in keys) {
          final value = data[key];
          if (value is List) return value;
        }
        for (final key in const [
          'items',
          'results',
          'tickets',
          'customers',
          'notifications',
          'alerts'
        ]) {
          final value = data[key];
          if (value is List) return value;
        }
      }
    }

    return const [];
  }

  static String errorMessage(
    Object error, {
    String fallback = 'Request failed',
  }) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionError) {
        final url = error.requestOptions.uri.toString();
        final origin = Uri.base.origin;
        return 'Network/CORS error while connecting to $url from $origin. '
            'Allow this origin in backend CORS_ORIGINS.';
      }

      final validation = _validationMessage(error.response?.data);
      if (validation != null) return validation;

      final bodyMessage = _messageFromAny(error.response?.data);
      if (bodyMessage != null) return bodyMessage;

      final innerMessage = _messageFromAny(error.error);
      if (innerMessage != null) return innerMessage;

      final raw = error.message?.trim();
      if (raw != null && raw.isNotEmpty) return raw;
      return fallback;
    }

    final raw = _messageFromAny(error);
    return raw ?? fallback;
  }

  static String? _validationMessage(dynamic source) {
    if (source is Map) {
      final map = Map<String, dynamic>.from(source);
      final details = map['details'] ?? map['detail'];
      final rows = <String>[];

      if (details is List) {
        for (final item in details) {
          if (item is Map) {
            final detail = Map<String, dynamic>.from(item);
            final msg = detail['msg']?.toString().trim();
            final loc = detail['loc'];
            final locText =
                (loc is List) ? loc.map((e) => e.toString()).join('.') : null;
            if (msg != null && msg.isNotEmpty) {
              rows.add(
                  locText == null || locText.isEmpty ? msg : '$locText: $msg');
            }
          } else {
            final text = item.toString().trim();
            if (text.isNotEmpty) rows.add(text);
          }
          if (rows.length >= 3) break;
        }
      }

      if (rows.isNotEmpty) {
        final prefix = map['error']?.toString().trim();
        if (prefix != null && prefix.isNotEmpty) {
          return '$prefix: ${rows.join(' | ')}';
        }
        return rows.join(' | ');
      }
    }
    return null;
  }

  static String? _messageFromAny(dynamic source) {
    if (source == null) return null;

    if (source is String) {
      final text = source.trim();
      return text.isEmpty ? null : text;
    }

    if (source is Map<String, dynamic>) {
      for (final key in const [
        'detail',
        'message',
        'error',
        'msg',
        'description'
      ]) {
        final candidate = _messageFromAny(source[key]);
        if (candidate != null) return candidate;
      }
      return null;
    }

    if (source is Map) {
      return _messageFromAny(Map<String, dynamic>.from(source));
    }

    if (source is List && source.isNotEmpty) {
      for (final item in source) {
        final candidate = _messageFromAny(item);
        if (candidate != null) return candidate;
      }
      return null;
    }

    final text = source.toString().trim();
    if (text.isEmpty || text == 'null') return null;
    return text;
  }
}
