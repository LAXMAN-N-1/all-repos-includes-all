import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/api_constants.dart';

/// Local-backend JWT auth service.
/// All auth calls go to the self-hosted FastAPI backend at ApiConstants.baseUrl.
/// No Supabase dependency.
class AuthService {
  final Dio _dio;
  static const _storage = FlutterSecureStorage();

  AuthService(this._dio);

  // ─── Token helpers ─────────────────────────────────────────────────────────

  static Future<String?> getStoredToken() =>
      _storage.read(key: 'access_token');

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  // ─── Auth endpoints ─────────────────────────────────────────────────────────

  /// Login with email OR phone + password. Returns parsed auth map.
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      debugPrint('→ POST ${ApiConstants.login}  user=$username');
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': username,
          'username': username,
          'phone_number': username,
          'password': password,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final detail = e.response?.data?['detail'];
      throw Exception(detail ?? 'Login failed. Please check your credentials.');
    } catch (e) {
      throw Exception('Unable to connect to server. Make sure the backend is running.');
    }
  }

  /// Register a new customer account. Returns parsed auth map.
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      debugPrint('→ POST ${ApiConstants.customerApiUrl}/auth/register');
      final response = await _dio.post(
        '${ApiConstants.customerApiUrl}/auth/register',
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final detail = e.response?.data?['detail'];
      throw Exception(detail ?? 'Registration failed.');
    } catch (e) {
      throw Exception('Unable to connect to server. Make sure the backend is running.');
    }
  }

  /// Get current user profile.
  Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final response = await _dio.get(
        ApiConstants.userMe,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? 'Failed to fetch profile.');
    }
  }

  /// Refresh access token using stored refresh token.
  Future<Map<String, dynamic>> refreshAccessToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? 'Token refresh failed.');
    }
  }

  /// Request OTP for registration/login.
  Future<void> requestOtp(String target, {String purpose = 'registration'}) async {
    try {
      await _dio.post(
        ApiConstants.registerRequestOtp,
        data: {'target': target, 'purpose': purpose},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? 'Failed to send OTP.');
    }
  }

  /// Verify OTP code.
  Future<Map<String, dynamic>> verifyOtp({
    required String target,
    required String code,
    String purpose = 'registration',
    String? fullName,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.registerVerifyOtp,
        data: {
          'target': target,
          'code': code,
          'purpose': purpose,
          if (fullName != null) 'full_name': fullName,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? 'OTP verification failed.');
    }
  }

  /// Send forgot-password reset link/OTP.
  Future<void> forgotPassword(String identifier) async {
    try {
      await _dio.post(
        ApiConstants.forgotPassword,
        data: {'identifier': identifier},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? 'Failed to send reset link.');
    }
  }

  /// Reset password with OTP code.
  Future<void> resetPassword({
    required String identifier,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        ApiConstants.resetPassword,
        data: {
          'identifier': identifier,
          'otp': otp,
          'new_password': newPassword,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? 'Password reset failed.');
    }
  }

  /// Change password (authenticated).
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await getStoredToken();
    try {
      await _dio.post(
        ApiConstants.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? 'Failed to change password.');
    }
  }

  /// Sign out — clears tokens locally (backend session invalidation is best-effort).
  Future<void> logout() async {
    final token = await getStoredToken();
    try {
      if (token != null) {
        await _dio.post(
          ApiConstants.logout,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      }
    } catch (_) {
      // Best-effort logout on server
    }
    await clearTokens();
  }

  // ─── Biometric (custom backend endpoints) ──────────────────────────────────

  Future<Map<String, dynamic>> verify2FALogin({
    required String sessionToken,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.twoFAVerify,
        data: {'session_token': sessionToken, 'code': otp},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? '2FA verification failed');
    }
  }

  Future<Map<String, dynamic>> loginWithBiometric({
    required String deviceId,
    required String biometricToken,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.biometricLogin,
        data: {'device_id': deviceId, 'biometric_token': biometricToken},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? 'Biometric login failed');
    }
  }

  Future<Map<String, dynamic>> registerBiometric({
    required String deviceId,
    required String credentialId,
    required String biometricToken,
  }) async {
    final token = await getStoredToken();
    try {
      final response = await _dio.post(
        ApiConstants.biometricRegister,
        data: {
          'device_id': deviceId,
          'credential_id': credentialId,
          'public_key': biometricToken,
          'biometric_token': biometricToken,
        },
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      return response.data ?? {'message': 'Success'};
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? 'Biometric registration failed');
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle({required bool consent}) async {
    throw Exception('Google Sign-In is not available in this build.');
  }

  Future<Map<String, dynamic>> loginWithApple({required bool consent}) async {
    throw Exception('Apple Sign-In is not available in this build.');
  }
}
