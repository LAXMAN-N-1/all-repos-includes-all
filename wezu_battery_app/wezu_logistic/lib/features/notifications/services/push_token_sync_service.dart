import 'package:flutter/foundation.dart';

import '../../../config/app_constants.dart';
import '../../../services/storage_service.dart';
import '../repository/notifications_repository.dart';

class PushTokenSyncService {
  final StorageService _storage;
  final NotificationsRepository _notificationsRepository;

  PushTokenSyncService({
    required StorageService storage,
    required NotificationsRepository notificationsRepository,
  }) : _storage = storage,
       _notificationsRepository = notificationsRepository;

  Future<void> syncRegisteredToken() async {
    final token = await _storage.getSecureItem(AppConstants.pushDeviceTokenKey);
    if (token == null || token.trim().isEmpty) {
      return;
    }
    final deviceId = await _storage.getSecureItem(AppConstants.pushDeviceIdKey);
    await _notificationsRepository.registerDeviceToken(
      token: token.trim(),
      platform: _platformName,
      deviceId: deviceId,
    );
  }

  Future<void> saveTokenAndSync(String token, {String? deviceId}) async {
    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) {
      return;
    }
    await _storage.setSecureItem(
      AppConstants.pushDeviceTokenKey,
      normalizedToken,
    );
    if (deviceId != null && deviceId.trim().isNotEmpty) {
      await _storage.setSecureItem(
        AppConstants.pushDeviceIdKey,
        deviceId.trim(),
      );
    }
    await syncRegisteredToken();
  }

  Future<void> unregisterStoredToken() async {
    final token = await _storage.getSecureItem(AppConstants.pushDeviceTokenKey);
    final deviceId = await _storage.getSecureItem(AppConstants.pushDeviceIdKey);
    await _notificationsRepository.unregisterDeviceToken(
      token: token,
      deviceId: deviceId,
    );
  }

  String get _platformName {
    if (kIsWeb) return 'web';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'ios';
    return 'android';
  }
}

