import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'storage_service.g.dart';

class StorageService {
  final FlutterSecureStorage _storage;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  StorageService(this._storage);

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> clearAuth() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}

@riverpod
StorageService storageService(StorageServiceRef ref) {
  return StorageService(const FlutterSecureStorage());
}
