import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper around flutter_secure_storage for sensitive data.
class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  Future<void> write(String key, String value) => _storage.write(key: key, value: value);
  Future<String?> read(String key) => _storage.read(key: key);
  Future<void> delete(String key) => _storage.delete(key: key);
  Future<void> deleteAll() => _storage.deleteAll();
  Future<bool> containsKey(String key) => _storage.containsKey(key: key);
  Future<Map<String, String>> readAll() => _storage.readAll();
}

/// Wrapper around SharedPreferences for non-sensitive persistent data.
class LocalStorage {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> setString(String key, String value) async => (await prefs).setString(key, value);
  Future<String?> getString(String key) async => (await prefs).getString(key);
  Future<void> setBool(String key, bool value) async => (await prefs).setBool(key, value);
  Future<bool?> getBool(String key) async => (await prefs).getBool(key);
  Future<void> setInt(String key, int value) async => (await prefs).setInt(key, value);
  Future<int?> getInt(String key) async => (await prefs).getInt(key);
  Future<void> setStringList(String key, List<String> value) async => (await prefs).setStringList(key, value);
  Future<List<String>?> getStringList(String key) async => (await prefs).getStringList(key);
  Future<void> remove(String key) async => (await prefs).remove(key);
  Future<void> clear() async => (await prefs).clear();
}

/// Simple in-memory TTL cache.
class CacheManager {
  final Map<String, _CacheEntry> _cache = {};
  final Duration defaultTtl;

  CacheManager({this.defaultTtl = const Duration(minutes: 5)});

  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (entry.isExpired) { _cache.remove(key); return null; }
    return entry.value as T?;
  }

  void set<T>(String key, T value, {Duration? ttl}) {
    _cache[key] = _CacheEntry(value: value, expiresAt: DateTime.now().add(ttl ?? defaultTtl));
  }

  void remove(String key) => _cache.remove(key);
  void clear() => _cache.clear();
  bool containsKey(String key) => get(key) != null;
}

class _CacheEntry {
  final dynamic value;
  final DateTime expiresAt;
  _CacheEntry({required this.value, required this.expiresAt});
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
