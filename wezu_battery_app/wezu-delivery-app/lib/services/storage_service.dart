import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Onboarding ──────────────────────────────────────────────────────────

  Future<bool> hasCompletedOnboarding() async {
    return _prefs?.getBool('has_completed_onboarding') ?? false;
  }

  Future<void> setCompletedOnboarding() async {
    await _prefs?.setBool('has_completed_onboarding', true);
  }

  // ── Auth token ─────────────────────────────────────────────────────────

  Future<String?> getAuthToken() async {
    return _prefs?.getString('auth_token');
  }

  Future<void> setAuthToken(String token) async {
    await _prefs?.setString('auth_token', token);
  }

  Future<void> clearAuthToken() async {
    await _prefs?.remove('auth_token');
    await _prefs?.remove('driver_profile_id');
    await _prefs?.remove('phone_number');
  }

  // ── Driver profile ─────────────────────────────────────────────────────

  Future<int?> getDriverProfileId() async {
    final id = _prefs?.getInt('driver_profile_id');
    return id;
  }

  Future<void> setDriverProfileId(int id) async {
    await _prefs?.setInt('driver_profile_id', id);
  }

  // ── Phone number (used for OTP flow) ──────────────────────────────────

  Future<String?> getPhoneNumber() async {
    return _prefs?.getString('phone_number');
  }

  Future<void> setPhoneNumber(String phone) async {
    await _prefs?.setString('phone_number', phone);
  }

  // ── Biometric / app unlock preference ───────────────────────────────────

  Future<bool> isBiometricUnlockEnabled() async {
    return _prefs?.getBool('biometric_unlock_enabled') ?? true;
  }

  Future<void> setBiometricUnlockEnabled(bool enabled) async {
    await _prefs?.setBool('biometric_unlock_enabled', enabled);
  }
}
