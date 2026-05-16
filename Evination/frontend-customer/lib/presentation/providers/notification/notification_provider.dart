import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/notification/notification_model.dart';
import '../../../data/repositories/notification_repository_impl.dart';

class NotificationNotifier extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final Ref ref;

  NotificationNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(notificationRepositoryProvider);
      final notifications = await repository.getNotifications();
      state = AsyncValue.data(notifications);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String id) async {
    state.whenData((notifications) {
      final updated = notifications.map((n) {
        if (n.id == id) return n.copyWith(isRead: true);
        return n;
      }).toList();
      state = AsyncValue.data(updated);
    });
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, AsyncValue<List<NotificationModel>>>((ref) {
  return NotificationNotifier(ref);
});
