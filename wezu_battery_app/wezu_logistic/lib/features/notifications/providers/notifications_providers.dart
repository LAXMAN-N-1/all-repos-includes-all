import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../repository/notifications_repository.dart';
import '../services/push_token_sync_service.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  return NotificationsRepository(api: ref.read(apiClientProvider));
});

final pushTokenSyncServiceProvider = Provider<PushTokenSyncService>((ref) {
  return PushTokenSyncService(
    storage: ref.read(storageServiceProvider),
    notificationsRepository: ref.read(notificationsRepositoryProvider),
  );
});
