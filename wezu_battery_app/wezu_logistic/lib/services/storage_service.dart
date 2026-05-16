import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_constants.dart';

/// Unified storage service for the app.
/// Uses SharedPreferences for general data and FlutterSecureStorage for
/// sensitive data like tokens.
class StorageService {
  static StorageService? _instance;

  late final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  StorageService._();

  /// Initialize the storage service. Must be called before using any methods.
  static Future<StorageService> init() async {
    if (_instance != null) return _instance!;
    final service = StorageService._();
    service._prefs = await SharedPreferences.getInstance();
    _instance = service;
    return _instance!;
  }

  /// Singleton accessor. Must call [init] first.
  static StorageService get instance {
    assert(_instance != null, 'StorageService must be initialized before use.');
    return _instance!;
  }

  // ─── Secure Storage (Tokens) ──────────────────────────────────────

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.tokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
  }

  // ─── Generic Helpers ──────────────────────────────────────────────

  /// Save simple data (String, bool, int, double).
  Future<void> setItem(String key, dynamic value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else {
      throw Exception('Unsupported value type for SharedPrefs: ${value.runtimeType}');
    }
  }

  /// Retrieve simple data. returns T? if possible.
  T? getItem<T>(String key) {
    final value = _prefs.get(key);
    if (value is T) return value;
    return null;
  }


  Future<void> setSecureItem(String key, String value) => _secureStorage.write(key: key, value: value);
  Future<String?> getSecureItem(String key) => _secureStorage.read(key: key);
  Future<void> removeSecureItem(String key) => _secureStorage.delete(key: key);

  // ─── Caching Strategy ─────────────────────────────────────────────

  /// Save data to cache with an expiration duration.
  /// Data is stored as a JSON string with an expiry timestamp.
  Future<void> cacheData(String key, String data, {Duration duration = const Duration(minutes: 5)}) async {
    final expiry = DateTime.now().add(duration).millisecondsSinceEpoch;
    final payload = '$expiry|$data'; // Simple delimiter format: timestamp|data
    await _prefs.setString('cache_$key', payload);
  }

  /// Retrieve cached data if valid. Returns null if expired or missing.
  String? getCachedData(String key) {
    final payload = _prefs.getString('cache_$key');
    if (payload == null) return null;

    final parts = payload.split('|');
    if (parts.length < 2) return null;

    final expiry = int.tryParse(parts[0]);
    if (expiry == null) return null;

    if (DateTime.now().millisecondsSinceEpoch > expiry) {
      _prefs.remove('cache_$key'); // Clean up expired
      return null;
    }

    return payload.substring(parts[0].length + 1); // Return data part (handles data containing |)
  }

  /// Clear a specific cache entry.
  Future<void> clearCache(String key) => _prefs.remove('cache_$key');

  // ─── User Data ────────────────────────────────────────────────────

  Future<void> saveUserData(String jsonString) async {
    await _prefs.setString(AppConstants.userDataKey, jsonString);
  }

  String? getUserData() {
    return _prefs.getString(AppConstants.userDataKey);
  }

  Future<void> clearUserData() async {
    await _prefs.remove(AppConstants.userDataKey);
  }

  // ─── Theme Data ───────────────────────────────────────────────────

  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(AppConstants.themeKey, mode);
  }

  String? getThemeMode() {
    return _prefs.getString(AppConstants.themeKey);
  }

  Future<void> saveAmoledMode(bool enabled) async {
    await _prefs.setBool('amoled_mode', enabled);
  }

  bool getAmoledMode() {
    return _prefs.getBool('amoled_mode') ?? false;
  }

  // ─── Onboarding ───────────────────────────────────────────────────

  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(AppConstants.onboardingKey, true);
  }

  bool get isOnboardingComplete {
    return _prefs.getBool(AppConstants.onboardingKey) ?? false;
  }

  // ─── Clear All ────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await _prefs.clear();
    await _secureStorage.deleteAll();
  }
}
