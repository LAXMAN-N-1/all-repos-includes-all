import 'dart:async';

import 'api_service.dart';

/// Handles authentication with the WEZU backend.
///
/// Flow:
///   1. [requestOtp] → POST /auth/register/request-otp  (purpose=login)
///   2. [verifyOtp]  → POST /auth/verify-otp            (returns JWT access_token)
///   3. [validateToken] → GET /users/me                 (verifies stored token)
///   4. [fetchUserProfile] → GET /users/me              (returns profile map)
class AuthService {
  final ApiService _api;

  AuthService({required ApiService api}) : _api = api;

  /// Step 1 – request OTP for the given phone number.
  /// Returns true if the server accepted the request.
  Future<bool> requestOtp(String phoneNumber) async {
    try {
      await _api.post(
        '/auth/register/request-otp',
        body: {'target': phoneNumber, 'purpose': 'login'},
      );
      return true;
    } on ApiException catch (e) {
      // 429 = rate limited, treat as failure but don't crash
      if (e.statusCode == 429) return false;
      rethrow;
    } on TimeoutException {
      return false;
    } on Exception {
      return false;
    }
  }

  /// Step 2 – verify OTP and obtain JWT token.
  /// Returns the access_token string on success, null on failure.
  Future<String?> verifyOtp(String phoneNumber, String code) async {
    try {
      final response = await _api.post(
        '/auth/verify-otp',
        body: {'target': phoneNumber, 'code': code, 'purpose': 'login'},
      );
      final token = response['access_token'] as String?;
      if (token != null && token.isNotEmpty) {
        _api.setAuthToken(token);
      }
      return token;
    } on ApiException {
      return null;
    } on TimeoutException {
      return null;
    } on Exception {
      return null;
    }
  }

  /// Validates a stored token by calling /users/me.
  /// Returns true if the token is still valid.
  Future<bool> validateToken(String token) async {
    if (token.isEmpty) return false;
    try {
      _api.setAuthToken(token);
      await _api.get('/users/me');
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        _api.setAuthToken('');
        return false;
      }
      // Network error – assume token is still valid (offline mode)
      return true;
    } on TimeoutException {
      return true;
    } on Exception {
      return true;
    }
  }

  /// Fetches the current user profile from /users/me.
  /// Returns a map with user fields, or null on failure.
  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final response = await _api.get('/users/me');
      return response;
    } on ApiException {
      return null;
    } on TimeoutException {
      return null;
    } on Exception {
      return null;
    }
  }

  /// Fetches driver-specific profile data from /drivers/me.
  /// This includes driver profile id required by logistics endpoints.
  Future<Map<String, dynamic>?> fetchDriverProfile() async {
    try {
      final response = await _api.get('/drivers/me');
      final data = response['data'];
      if (data is Map<String, dynamic>) return data;
      return null;
    } on ApiException {
      return null;
    } on TimeoutException {
      return null;
    } on Exception {
      return null;
    }
  }

  /// Sets the auth token on the underlying [ApiService] so all subsequent
  /// requests include it as a Bearer token.
  void applyToken(String token) => _api.setAuthToken(token);

  void clearToken() => _api.setAuthToken('');
}
