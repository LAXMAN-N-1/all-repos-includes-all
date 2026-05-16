import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_base_url.dart';

/// Central HTTP service for all API calls in the delivery app.
/// Default base URL is platform-aware:
/// - Web/iOS/desktop: http://127.0.0.1:8000/api/v1
/// - Android emulator: http://10.0.2.2:8000/api/v1
/// For physical devices, pass API_BASE_URL via --dart-define.
class ApiService {
  static const Duration _timeout = Duration(seconds: 20);

  /// Override with:
  /// --dart-define=API_BASE_URL=http://YOUR_HOST:8000/api/v1
  static final String baseUrl = ApiBaseUrl.resolve();

  final http.Client _client;
  String _authToken = '';

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  void setAuthToken(String token) {
    _authToken = token;
  }

  String get authToken => _authToken;

  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken.isNotEmpty) 'Authorization': 'Bearer $_authToken',
  };

  // ── GET ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    var uri = Uri.parse('$baseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    final response = await _client
        .get(uri, headers: _authHeaders)
        .timeout(_timeout);
    return _parseResponse(response);
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    var uri = Uri.parse('$baseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    final response = await _client
        .get(uri, headers: _authHeaders)
        .timeout(_timeout);
    final body = _parseRaw(response);
    if (body is Map && body['data'] is List) return body['data'] as List;
    if (body is List) return body;
    return [];
  }

  // ── POST ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, String>? queryParams,
    dynamic body,
  }) async {
    var uri = Uri.parse('$baseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    final response = await _client
        .post(
          uri,
          headers: _authHeaders,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(_timeout);
    return _parseResponse(response);
  }

  /// POST with application/x-www-form-urlencoded (OAuth2 token endpoint)
  Future<Map<String, dynamic>> postForm(
    String path,
    Map<String, String> fields,
  ) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _client
        .post(
          uri,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
          },
          body: fields,
        )
        .timeout(_timeout);
    return _parseResponse(response);
  }

  // ── PUT ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, String>? queryParams,
    dynamic body,
  }) async {
    var uri = Uri.parse('$baseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    final response = await _client
        .put(
          uri,
          headers: _authHeaders,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(_timeout);
    return _parseResponse(response);
  }

  // ── PATCH ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, String>? queryParams,
    dynamic body,
  }) async {
    var uri = Uri.parse('$baseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    final response = await _client
        .patch(
          uri,
          headers: _authHeaders,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(_timeout);
    return _parseResponse(response);
  }

  // ── DELETE ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, String>? queryParams,
    dynamic body,
  }) async {
    var uri = Uri.parse('$baseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    final response = await _client
        .delete(
          uri,
          headers: _authHeaders,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(_timeout);
    return _parseResponse(response);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  dynamic _parseRaw(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    }
    _throwForStatus(response);
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded};
    }
    _throwForStatus(response);
  }

  Never _throwForStatus(http.Response response) {
    String message = 'Request failed (${response.statusCode})';
    try {
      final body = jsonDecode(response.body);
      if (body is Map) {
        message =
            body['detail']?.toString() ??
            body['message']?.toString() ??
            message;
      }
    } catch (_) {}
    throw ApiException(message: message, statusCode: response.statusCode);
  }

  void dispose() => _client.close();
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({required this.message, this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
