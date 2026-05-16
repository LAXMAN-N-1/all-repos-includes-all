import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wezu_customer_app/core/theme/theme_provider.dart';
import 'package:wezu_customer_app/core/network/dio_provider.dart';
import 'package:wezu_customer_app/features/auth/models/user_model.dart';
import 'package:wezu_customer_app/features/auth/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>(
    (ref) => AuthService(ref.read(unauthenticatedDioProvider)));

final storageProvider =
    Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authServiceProvider),
    ref.watch(storageProvider),
    ref.watch(sharedPrefsProvider),
  );
});

// ─── State ───────────────────────────────────────────────────────────────────

class AuthState {
  final bool isLoading;
  final bool isInitialized;
  final String? error;
  final String? token;
  final String? refreshToken;
  final User? user;
  final bool isAuthenticated;
  final bool requires2FA;
  final String? tempSessionToken;
  final bool isBiometricEnabled;
  final int failedBiometricAttempts;

  const AuthState({
    this.isLoading = false,
    this.isInitialized = false,
    this.error,
    this.token,
    this.refreshToken,
    this.user,
    this.isAuthenticated = false,
    this.requires2FA = false,
    this.tempSessionToken,
    this.isBiometricEnabled = false,
    this.failedBiometricAttempts = 0,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isInitialized,
    String? error,
    String? token,
    String? refreshToken,
    User? user,
    bool? isAuthenticated,
    bool? requires2FA,
    String? tempSessionToken,
    bool? isBiometricEnabled,
    int? failedBiometricAttempts,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      requires2FA: requires2FA ?? this.requires2FA,
      tempSessionToken: tempSessionToken ?? this.tempSessionToken,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      failedBiometricAttempts:
          failedBiometricAttempts ?? this.failedBiometricAttempts,
    );
  }
}

// ─── Notifier ────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final FlutterSecureStorage _storage;
  final SharedPreferences _prefs;
  Timer? _inactivityTimer;

  static const String _biometricEnabledKey = 'is_biometric_enabled_v2';
  static const Duration _sessionIdleTtl = Duration(days: 365);

  AuthNotifier(this._authService, this._storage, this._prefs)
      : super(const AuthState()) {
    _initializeAuth();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> _initializeAuth() async {
    try {
      final isBiometricEnabled = _prefs.getBool(_biometricEnabledKey) ?? false;
      final biometricToken = await _storage.read(key: 'biometric_token');
      final deviceId = await _storage.read(key: 'device_id');

      User? cachedUser;
      final userRaw = await _storage.read(key: 'user_data');
      if (userRaw != null && userRaw.isNotEmpty) {
        try {
          cachedUser = User.fromJson(jsonDecode(userRaw) as Map<String, dynamic>);
        } catch (_) {
          cachedUser = null;
        }
      }

      state = state.copyWith(
        isBiometricEnabled:
            isBiometricEnabled && biometricToken != null && deviceId != null,
      );

      // Restore session from secure storage
      final accessToken = await _storage.read(key: 'access_token');
      final refreshToken = await _storage.read(key: 'refresh_token');

      if (accessToken != null && accessToken.isNotEmpty) {
        state = state.copyWith(
          token: accessToken,
          refreshToken: refreshToken,
          user: cachedUser,
          isAuthenticated: true,
          isInitialized: true,
        );
        _startInactivityTimer();
        // Non-blocking profile hydration; if access token expired,
        // try one refresh before forcing logout.
        unawaited(() async {
          final refreshed = await refreshUser();
          if (!refreshed &&
              (refreshToken != null && refreshToken.isNotEmpty)) {
            await refreshTokenAction();
            await refreshUser();
          }
        }());
        return;
      }

      // No session found.
      state = state.copyWith(
        isAuthenticated: false,
        token: null,
        refreshToken: null,
        user: null,
        isInitialized: true,
      );
    } catch (_) {
      state = state.copyWith(isInitialized: true);
    }
  }

  // ── Auth actions ──────────────────────────────────────────────────────────

  Future<void> login({required String username, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authService.login(
          username: username, password: password);
      await _handleAuthSuccess(result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authService.register(data);
      await _handleAuthSuccess(result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> _handleAuthSuccess(Map<String, dynamic> result) async {
    final accessToken = result['access_token'] as String?;
    final refreshToken = result['refresh_token'] as String?;
    final userData = result['user'];

    if (accessToken == null) {
      state = state.copyWith(isLoading: false, error: 'No token received from server.');
      return;
    }

    await AuthService.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken ?? '',
    );

    User? user;
    if (userData is Map<String, dynamic>) {
      user = User.fromJson(userData);
      await _storage.write(key: 'user_data', value: jsonEncode(user.toJson()));
    }

    state = state.copyWith(
      isLoading: false,
      token: accessToken,
      refreshToken: refreshToken,
      isAuthenticated: true,
      isInitialized: true,
      user: user,
      error: null,
    );
    _startInactivityTimer();
  }

  Future<bool> refreshUser() async {
    if (state.token == null) return false;
    try {
      final userData = await _authService.getUserProfile(state.token!);
      final updatedUser = User.fromJson(userData);
      updateUser(updatedUser);
      return true;
    } catch (e) {
      debugPrint('refreshUser error: $e');
      return false;
    }
  }

  Future<bool> requestOtp(String target) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.requestOtp(target);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> verifyOtp({
    required String target,
    required String code,
    String? fullName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authService.verifyOtp(
          target: target, code: code, fullName: fullName);
      await _handleAuthSuccess(result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> forgotPassword(String identifier) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.forgotPassword(identifier);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String identifier,
    required String otp,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.resetPassword(
          identifier: identifier, otp: otp, newPassword: newPassword);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.changePassword(
          currentPassword: currentPassword, newPassword: newPassword);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  // ── Social login (stubs) ──────────────────────────────────────────────────

  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.loginWithGoogle(consent: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loginWithApple({String? fullName}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.loginWithApple(consent: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Biometric ─────────────────────────────────────────────────────────────

  Future<void> enableBiometric() async {
    final localAuth = LocalAuthentication();
    final canCheck = await localAuth.canCheckBiometrics;
    final isSupported = await localAuth.isDeviceSupported();

    if (!canCheck || !isSupported) {
      throw Exception('Biometrics not supported on this device.');
    }

    final authenticated = await localAuth.authenticate(
      localizedReason: 'Scan your biometric to enable quick login',
    );
    if (!authenticated) {
      throw Exception('Biometric authentication was cancelled.');
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final deviceId = const Uuid().v4();
      final credentialId = const Uuid().v4();
      final biometricToken = const Uuid().v4();

      await _authService.registerBiometric(
        deviceId: deviceId,
        credentialId: credentialId,
        biometricToken: biometricToken,
      );

      await _storage.write(key: 'device_id', value: deviceId);
      await _storage.write(key: 'biometric_token', value: biometricToken);
      await _prefs.setBool(_biometricEnabledKey, true);

      state = state.copyWith(isLoading: false, isBiometricEnabled: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> disableBiometric() async {
    await _storage.delete(key: 'device_id');
    await _storage.delete(key: 'biometric_token');
    await _prefs.setBool(_biometricEnabledKey, false);
    state = state.copyWith(isBiometricEnabled: false);
  }

  Future<void> loginWithBiometrics() async {
    if (state.failedBiometricAttempts >= 3) {
      throw Exception('Biometric login locked. Please log in with password.');
    }

    final localAuth = LocalAuthentication();
    final authenticated = await localAuth.authenticate(
      localizedReason: 'Scan your biometric to securely login',
    );

    if (!authenticated) {
      final fails = state.failedBiometricAttempts + 1;
      state = state.copyWith(failedBiometricAttempts: fails);
      throw Exception('Biometric authentication failed. Attempt $fails/3');
    }

    state = state.copyWith(isLoading: true, error: null, failedBiometricAttempts: 0);

    try {
      final deviceId = await _storage.read(key: 'device_id');
      final biometricToken = await _storage.read(key: 'biometric_token');

      if (deviceId == null || biometricToken == null) {
        throw Exception('Biometric credentials not found locally.');
      }

      final result = await _authService.loginWithBiometric(
        deviceId: deviceId,
        biometricToken: biometricToken,
      );
      await _handleAuthSuccess(result);
    } catch (e) {
      final fails = state.failedBiometricAttempts + 1;
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        failedBiometricAttempts: fails,
      );
      if (fails >= 3) {
        throw Exception('Biometric locked after 3 failures. Use password login.');
      } else {
        rethrow;
      }
    }
  }

  // ── 2FA ───────────────────────────────────────────────────────────────────

  Future<void> submitLoginOTP(String otp) async {
    if (state.tempSessionToken == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authService.verify2FALogin(
        sessionToken: state.tempSessionToken!,
        otp: otp,
      );
      await _handleAuthSuccess(result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void clear2FAState() {
    state = state.copyWith(requires2FA: false, tempSessionToken: null);
  }

  // ── Utility ───────────────────────────────────────────────────────────────

  void updateUser(User updatedUser) async {
    state = state.copyWith(user: updatedUser);
    await _storage.write(
        key: 'user_data', value: jsonEncode(updatedUser.toJson()));
  }

  Future<void> refreshTokenAction() async {
    final refresh = state.refreshToken;
    if (refresh == null) return;
    try {
      final result = await _authService.refreshAccessToken(refresh);
      final newToken = result['access_token'] as String?;
      final newRefresh = result['refresh_token'] as String?;
      if (newToken != null) {
        await AuthService.saveTokens(
          accessToken: newToken,
          refreshToken: newRefresh ?? refresh,
        );
        state = state.copyWith(
          token: newToken,
          refreshToken: newRefresh ?? refresh,
          isAuthenticated: true,
          isInitialized: true,
        );
      }
    } catch (_) {
      logout();
    }
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_sessionIdleTtl, logout);
  }

  void userActivityDetected() {
    if (state.isAuthenticated) _startInactivityTimer();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> logout() async {
    _inactivityTimer?.cancel();
    try {
      await _authService.logout();
    } catch (_) {}
    await _storage.delete(key: 'user_data');
    state = AuthState(
      isBiometricEnabled: state.isBiometricEnabled,
      isInitialized: true,
    );
  }
}
