import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../repositories/notification_repository.dart';

class NotificationsViewModel extends ChangeNotifier {
  final NotificationRepository _notificationRepository;
  bool _showOnlyUnread = false;

  NotificationsViewModel({
    required NotificationRepository notificationRepository,
  }) : _notificationRepository = notificationRepository {
    _notificationRepository.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _notificationRepository.removeListener(notifyListeners);
    super.dispose();
  }

  bool get showOnlyUnread => _showOnlyUnread;

  List<NotificationItem> get notifications {
    if (_showOnlyUnread) {
      return _notificationRepository.notifications
          .where((n) => !n.isRead)
          .toList();
    }
    return _notificationRepository.notifications;
  }

  int get unreadCount =>
      _notificationRepository.notifications.where((n) => !n.isRead).length;

  void toggleFilter(bool onlyUnread) {
    _showOnlyUnread = onlyUnread;
    notifyListeners();
  }

  void markAsRead(String id) {
    _notificationRepository.markAsRead(id);
  }

  void markAllAsRead() {
    _notificationRepository.markAllAsRead();
  }

  void deleteNotification(String id) {
    _notificationRepository.deleteNotification(id);
  }
}
