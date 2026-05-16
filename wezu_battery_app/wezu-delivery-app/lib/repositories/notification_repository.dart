import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationRepository extends ChangeNotifier {
  final ApiService _api;

  List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationRepository({required ApiService api}) : _api = api {
    fetchNotifications();
  }

  /// GET /notifications/my
  Future<void> fetchNotifications() async {
    try {
      final list = await _api.getList(
        '/notifications/my',
        queryParams: {'limit': '50'},
      );
      _notifications = list
          .whereType<Map<String, dynamic>>()
          .map(_mapNotification)
          .toList();
      notifyListeners();
    } on ApiException {
      // On error, keep existing (possibly empty) list
    }
  }

  NotificationItem _mapNotification(Map<String, dynamic> json) {
    DateTime ts;
    try {
      ts = DateTime.parse(json['created_at']?.toString() ?? '');
    } catch (_) {
      ts = DateTime.now();
    }

    final typeStr =
        json['notification_type']?.toString() ??
        json['type']?.toString() ??
        'system';
    NotificationType type;
    switch (typeStr) {
      case 'order':
      case 'delivery':
        type = NotificationType.order;
        break;
      case 'promotion':
      case 'promo':
        type = NotificationType.promotion;
        break;
      default:
        type = NotificationType.system;
    }

    return NotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notification',
      body: json['body']?.toString() ?? json['message']?.toString() ?? '',
      timestamp: ts,
      isRead: json['is_read'] == true || json['read'] == true,
      type: type,
    );
  }

  /// Mark a single notification as read via backend.
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      notifyListeners();
      unawaited(_api.patch('/notifications/$id/read'));
    }
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
    unawaited(_api.patch('/notifications/read-all'));
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
    unawaited(_api.delete('/notifications/$id'));
  }
}
