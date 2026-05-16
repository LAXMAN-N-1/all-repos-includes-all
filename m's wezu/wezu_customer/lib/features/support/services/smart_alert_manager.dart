import 'notification_service.dart';
import '../models/notification_item.dart';

class SmartAlertManager {
  final NotificationService _notificationService;

  SmartAlertManager(this._notificationService);

  // Requirement: Smart battery alert notifications (FR-MOB-SUP-005)
  void checkBatteryStatus({
    required double charge,
    required double health,
    required double temperature,
  }) {
    // Charge below 10%
    if (charge < 10.0) {
      _notificationService.showNotification(NotificationItem(
        id: 'ALERT-LOW-BATT',
        title: 'CRITICAL: Low Battery',
        message: 'Your battery is at ${charge.toStringAsFixed(1)}%. Please swap at a nearby station immediately.',
        timestamp: DateTime.now(),
        type: NotificationType.batteryAlert,
      ));
    }

    // Health below 80%
    if (health < 80.0) {
      _notificationService.showNotification(NotificationItem(
        id: 'ALERT-HEALTH-LOW',
        title: 'Maintenance Alert',
        message: 'Battery health dropped to ${health.toStringAsFixed(1)}%. Schedule a maintenance check-up now.',
        timestamp: DateTime.now(),
        type: NotificationType.batteryAlert,
      ));
    }

    // Temperature abnormal (> 45°C)
    if (temperature > 45.0) {
      _notificationService.showNotification(NotificationItem(
        id: 'ALERT-TEMP-HIGH',
        title: 'Overheating Warning ⚠️',
        message: 'High battery temperature detected (${temperature.toStringAsFixed(1)}°C). Avoid heavy acceleration.',
        timestamp: DateTime.now(),
        type: NotificationType.batteryAlert,
      ));
    }
  }
}
