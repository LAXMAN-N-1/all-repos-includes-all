import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/notification_item.dart';

class NotificationService {
  final _controller = StreamController<NotificationItem>.broadcast();
  Stream<NotificationItem> get notifications => _controller.stream;

  // Requirement: Notification preferences customizable
  bool pushEnabled = true;
  bool promoEnabled = true;
  bool criticalAlertsOnly = false;

  Future<void> showNotification(NotificationItem item) async {
    if (!pushEnabled) return;
    if (item.type == NotificationType.promo && !promoEnabled) return;
    if (criticalAlertsOnly && item.type != NotificationType.batteryAlert) return;

    debugPrint("--- [NEW PUSH NOTIFICATION] ---");
    debugPrint("Type: ${item.type.name.toUpperCase()}");
    debugPrint("Title: ${item.title}");
    debugPrint("Message: ${item.message}");
    debugPrint("-------------------------------");
    
    _controller.add(item);
  }

  // Requirement: Personalized promotional notifications (FR-MOB-SUP-006)
  void simulatePromotionalOffer() {
    showNotification(NotificationItem(
      id: 'PROMO-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Birthday Special! 🎂',
      message: 'Happy Birthday! Enjoy 20% off on your next 7-day rental swap.',
      timestamp: DateTime.now(),
      type: NotificationType.promo,
    ));
  }

  void dispose() {
    _controller.close();
  }
}
