import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorage {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  LocalStorage(this._prefs);

  static Future<LocalStorage> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorage(prefs);
  }

  // General Preferences
  Future<void> setBool(String key, bool value) async => await _prefs.setBool(key, value);
  bool? getBool(String key) => _prefs.getBool(key);

  Future<void> setString(String key, String value) async => await _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);

  // Secure Storage (Tokens, Sensitive Data)
  Future<void> saveToken(String token) async => await _secureStorage.write(key: 'access_token', value: token);
  Future<String?> getToken() async => await _secureStorage.read(key: 'access_token');
  Future<void> deleteToken() async => await _secureStorage.delete(key: 'access_token');

  Future<void> clearAll() async {
    await _prefs.clear();
    await _secureStorage.deleteAll();
  }
}
