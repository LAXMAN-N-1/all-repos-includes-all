import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/supabase_auth_service.dart';

/// Supabase-first auth service for production.
///
/// Flow:
///  1) Authenticate with Supabase (email/password, phone/password, OAuth, OTP).
///  2) Call backend `GET /auth/me` with Supabase access token.
///  3) Persist Supabase access/refresh tokens for API requests.
class AuthService {
  final Dio _dio;
  final SupabaseAuthService _supabaseAuth;
  static const _storage = FlutterSecureStorage();

  AuthService(this._dio, this._supabaseAuth);

  // ─── Token helpers ─────────────────────────────────────────────────────────

  static Future<String?> getStoredToken() => _storage.read(key: 'access_token');

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: 'access_token', value: accessToken),
      _storage.write(key: 'refresh_token', value: refreshToken),
    ]);
  }

  static Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: 'access_token'),
      _storage.delete(key: 'refresh_token'),
    ]);
  }

  // ─── Core auth bootstrap ───────────────────────────────────────────────────

  bool _isEmail(String value) => value.trim().contains('@');

  String _normalizePhoneForSupabase(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('+')) {
      return '+${trimmed.substring(1).replaceAll(RegExp(r'[^0-9]'), '')}';
    }

    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 10) {
      // Default to India E.164 if user entered a local 10-digit number.
      return '+91$digits';
    }
    if (digits.length == 11 && digits.startsWith('0')) {
      return '+91${digits.substring(1)}';
    }
    if (digits.length == 12 && digits.startsWith('91')) {
      return '+$digits';
    }
    return '+$digits';
  }

  String? _extractErrorDetail(dynamic data) {
    if (data is Map) {
      final detail = data['detail'] ?? data['message'] ?? data['error'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail.trim();
      }
    }
    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }
    return null;
  }

  Exception _mapBackendBootstrapError(
    DioException e, {
    required String fallback,
  }) {
    final detail = _extractErrorDetail(e.response?.data);
    switch (detail) {
      case 'identity_unmapped':
        return Exception(
          'This Supabase account is not linked to a customer profile yet. Contact support.',
        );
      case 'identity_mapping_conflict':
        return Exception(
          'Your account has multiple profile mappings. Contact support.',
        );
      case 'identity_disabled':
        return Exception('This account is disabled. Contact support.');
      case 'token_expired':
      case 'token_invalid':
        return Exception(
            'Session is invalid or expired. Please sign in again.');
      default:
        return Exception(detail ?? fallback);
    }
  }

  Future<Map<String, dynamic>> _fetchAuthMe(String accessToken) async {
    final response = await _dio.get(
      ApiConstants.authMe,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data as Map);
    }
    throw Exception('Unexpected response from ${ApiConstants.authMe}.');
  }

  Map<String, dynamic> _supabaseUserToAppUser(User user) {
    return {
      'id': 0,
      'email': user.email,
      'full_name': user.userMetadata?['full_name'],
      'phone_number': user.phone,
      'kyc_status': 'PENDING',
      'is_active': true,
      'is_superuser': false,
    };
  }

  Future<Map<String, dynamic>> loginWithSupabaseSession({
    required String accessToken,
    String? refreshToken,
    User? supabaseUser,
  }) async {
    try {
      final me = await _fetchAuthMe(accessToken);
      final payloadUser = me['user'];

      Map<String, dynamic>? userMap;
      if (payloadUser is Map<String, dynamic>) {
        userMap = payloadUser;
      } else if (payloadUser is Map) {
        userMap = Map<String, dynamic>.from(payloadUser);
      }

      userMap ??=
          supabaseUser != null ? _supabaseUserToAppUser(supabaseUser) : null;
      if (userMap == null) {
        throw Exception('Unable to load customer profile from backend.');
      }

      return {
        'access_token': accessToken,
        'refresh_token': refreshToken ?? '',
        'user': userMap,
        'roles': me['roles'] ?? const <dynamic>[],
        'permissions': me['permissions'] ?? const <dynamic>[],
      };
    } on DioException catch (e) {
      throw _mapBackendBootstrapError(
        e,
        fallback: 'Login succeeded, but profile bootstrap failed.',
      );
    }
  }

  // ─── Auth endpoints ─────────────────────────────────────────────────────────

  /// Login with email/phone + password via Supabase.
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final credential = username.trim();
      debugPrint('→ Supabase signInWithPassword  credential=$credential');

      final response = await _supabaseAuth.signInWithCredentialPassword(
        credential: _isEmail(credential)
            ? credential
            : _normalizePhoneForSupabase(credential),
        password: password,
      );

      final session = response.session;
      if (session == null) {
        throw Exception('Login failed: Supabase did not return a session.');
      }

      return loginWithSupabaseSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        supabaseUser: response.user,
      );
    } on SupabaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unable to connect to authentication services.');
    }
  }

  /// Registration now uses Supabase sign-up.
  ///
  /// If email confirmation is enabled, Supabase may not return a session until
  /// the user verifies email.
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final email = (data['email'] ?? '').toString().trim();
    final password = (data['password'] ?? '').toString();
    final fullName = (data['full_name'] ?? '').toString().trim();
    final phoneNumber = (data['phone_number'] ?? '').toString().trim();

    if (email.isEmpty) {
      throw Exception('Email is required for sign up in this app version.');
    }
    if (password.length < 8) {
      throw Exception('Password must be at least 8 characters long.');
    }

    try {
      final response = await _supabaseAuth.signUpWithEmail(
        email: email,
        password: password,
        metadata: {
          if (fullName.isNotEmpty) 'full_name': fullName,
          if (phoneNumber.isNotEmpty)
            'phone_number': _normalizePhoneForSupabase(phoneNumber),
        },
      );

      final session = response.session;
      if (session == null) {
        throw Exception(
          'Account created. Please verify your email, then sign in.',
        );
      }

      return loginWithSupabaseSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        supabaseUser: response.user,
      );
    } on SupabaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Get current user profile from canonical auth endpoint.
  Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final payload = await _fetchAuthMe(token);
      final user = payload['user'];
      if (user is Map<String, dynamic>) return user;
      if (user is Map) return Map<String, dynamic>.from(user);
      return payload;
    } on DioException catch (e) {
      final detail = _extractErrorDetail(e.response?.data);
      throw Exception(detail ?? 'Failed to fetch profile.');
    }
  }

  /// Refresh access token via Supabase session refresh.
  Future<Map<String, dynamic>> refreshAccessToken(String refreshToken) async {
    try {
      final session = await _supabaseAuth.refreshSession(
        refreshToken: refreshToken,
      );
      if (session == null) {
        throw Exception('Token refresh failed.');
      }
      return {
        'access_token': session.accessToken,
        'refresh_token': session.refreshToken ?? refreshToken,
      };
    } on SupabaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Request OTP using Supabase OTP flows.
  Future<void> requestOtp(String target,
      {String purpose = 'registration'}) async {
    try {
      final trimmed = target.trim();
      if (_isEmail(trimmed)) {
        await _supabaseAuth.sendEmailOtp(
          trimmed,
          shouldCreateUser: purpose != 'login',
        );
      } else {
        await _supabaseAuth.sendPhoneOtp(
          _normalizePhoneForSupabase(trimmed),
          shouldCreateUser: purpose != 'login',
        );
      }
    } on SupabaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Verify OTP via Supabase and bootstrap backend profile.
  Future<Map<String, dynamic>> verifyOtp({
    required String target,
    required String code,
    String purpose = 'registration',
    String? fullName,
  }) async {
    try {
      final trimmed = target.trim();
      final AuthResponse response;

      if (_isEmail(trimmed)) {
        if (purpose == 'reset_password') {
          response = await _supabaseAuth.verifyPasswordRecoveryOtp(
            email: trimmed,
            otp: code,
          );
        } else {
          response = await _supabaseAuth.verifyEmailOtp(
            email: trimmed,
            otp: code,
          );
        }
      } else {
        response = await _supabaseAuth.verifyPhoneOtp(
          phone: _normalizePhoneForSupabase(trimmed),
          otp: code,
        );
      }

      final session = response.session;
      if (session == null) {
        throw Exception('OTP verified but no session was returned.');
      }

      return loginWithSupabaseSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        supabaseUser: response.user,
      );
    } on SupabaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Send password reset email via Supabase.
  Future<void> forgotPassword(String identifier) async {
    final target = identifier.trim();
    if (!_isEmail(target)) {
      throw Exception('Password reset currently supports email only.');
    }
    try {
      await _supabaseAuth.sendPasswordResetEmail(target);
    } on SupabaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Reset password through Supabase recovery OTP flow.
  Future<void> resetPassword({
    required String identifier,
    required String otp,
    required String newPassword,
  }) async {
    final target = identifier.trim();
    if (!_isEmail(target)) {
      throw Exception('Password reset currently supports email only.');
    }

    try {
      await _supabaseAuth.verifyPasswordRecoveryOtp(email: target, otp: otp);
      await _supabaseAuth.updatePassword(newPassword);
    } on SupabaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Change password via Supabase.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Supabase update endpoint validates current session; currentPassword is
      // retained for API compatibility with existing UI.
      await _supabaseAuth.updatePassword(newPassword);
    } on SupabaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Best-effort backend logout + local token cleanup.
  Future<void> logout() async {
    final token = await getStoredToken();
    try {
      if (token != null && token.isNotEmpty) {
        await _dio.post(
          ApiConstants.logout,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      }
    } catch (_) {
      // Backend logout is best-effort.
    }
    await clearTokens();
  }

  // ─── Unsupported legacy flows in Supabase-only backend ─────────────────────

  Future<Map<String, dynamic>> verify2FALogin({
    required String sessionToken,
    required String otp,
  }) async {
    throw Exception(
        'Legacy backend 2FA endpoint is not available in production.');
  }

  Future<Map<String, dynamic>> loginWithBiometric({
    required String deviceId,
    required String biometricToken,
  }) async {
    throw Exception(
        'Legacy biometric login endpoint is not available in production.');
  }

  Future<Map<String, dynamic>> registerBiometric({
    required String deviceId,
    required String credentialId,
    required String biometricToken,
  }) async {
    throw Exception(
      'Legacy biometric registration endpoint is not available in production.',
    );
  }

  /// Backward-compatible shim: token is expected to be a Supabase access token.
  Future<Map<String, dynamic>> loginWithSocialToken({
    required String provider,
    required String supabaseToken,
    String? email,
    String? fullName,
  }) async {
    return loginWithSupabaseSession(
      accessToken: supabaseToken,
      supabaseUser: null,
    );
  }

  Future<Map<String, dynamic>> loginWithGoogle({required bool consent}) async {
    throw Exception('Use Supabase OAuth flow directly.');
  }

  Future<Map<String, dynamic>> loginWithApple({required bool consent}) async {
    throw Exception('Use Supabase OAuth flow directly.');
  }
}
