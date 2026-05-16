import 'package:flutter/foundation.dart';
import '../../support/services/notification_service.dart';
import '../../support/services/smart_alert_manager.dart';
import '../../support/models/notification_item.dart';
import '../models/rental_timer.dart';
import '../../../core/network/api_client.dart';

class RentalTimerService {
  final NotificationService _notificationService = NotificationService();
  late final SmartAlertManager _smartAlertManager;

  RentalTimerService() {
    _smartAlertManager = SmartAlertManager(_notificationService);
  }

  // Simulated push notifications tracking
  bool _notified24h = false;
  bool _notified12h = false;
  bool _notified1h = false;

  // Mock nearby stations
  final List<String> _nearbyStations = [
    'Downtown Energy Hub',
    'Greenway Charging Point',
    'Metro Swap Station'
  ];

  Stream<RentalTimer> getCountdown(
      String rentalId, DateTime expiryTime) async* {
    while (true) {
      final now = DateTime.now();

      // Default to local calculation
      Duration remaining =
          expiryTime.isAfter(now) ? expiryTime.difference(now) : Duration.zero;

      double lateFee = 0.0;
      double currentCharge = 100.0;
      double currentHealth = 100.0;
      double currentTemp = 30.0;

      try {
        final rentalIdInt = int.tryParse(rentalId);
        final rentalResponse = await apiClient.get('/rentals/active/current');
        if (rentalResponse.statusCode == 200 &&
            rentalResponse.data is Map<String, dynamic>) {
          final data = rentalResponse.data as Map<String, dynamic>;
          final currentId = (data['id'] as num?)?.toInt();
          if (rentalIdInt == null || currentId == rentalIdInt) {
            final expectedEnd =
                DateTime.tryParse(data['expected_end_time']?.toString() ?? '');
            if (expectedEnd != null) {
              remaining = expectedEnd.isAfter(now)
                  ? expectedEnd.difference(now)
                  : Duration.zero;
            }

            final battery = data['battery'] is Map<String, dynamic>
                ? data['battery'] as Map<String, dynamic>
                : const <String, dynamic>{};
            currentCharge = (battery['current_charge'] as num?)?.toDouble() ??
                currentCharge;
            currentHealth =
                (battery['health_percentage'] as num?)?.toDouble() ??
                    currentHealth;

            final batteryId = (battery['id'] as num?)?.toInt();
            if (batteryId != null) {
              try {
                final telem = await apiClient
                    .get('/telematics/battery/$batteryId/latest');
                if (telem.statusCode == 200 &&
                    telem.data is Map<String, dynamic>) {
                  final t = telem.data as Map<String, dynamic>;
                  currentTemp =
                      (t['temperature'] as num?)?.toDouble() ?? currentTemp;
                  currentCharge =
                      (t['soc'] as num?)?.toDouble() ?? currentCharge;
                  currentHealth =
                      (t['soh'] as num?)?.toDouble() ?? currentHealth;
                }
              } catch (_) {}
            }
          }
        }

        if (rentalIdInt != null) {
          try {
            final fees = await apiClient.get('/rentals/$rentalIdInt/late-fees');
            if (fees.statusCode == 200 && fees.data is Map<String, dynamic>) {
              lateFee =
                  (fees.data['total_late_fee'] as num?)?.toDouble() ?? 0.0;
            }
          } catch (_) {
            // Ignore fee fetch failures; local fallback below handles overdue case.
          }
        }
      } catch (e) {
        debugPrint('Error fetching rental timer status for $rentalId: $e');
        // Fallback to local fee calculation if API fails
        if (remaining == Duration.zero) {
          final overdue = now.difference(expiryTime);
          final overdueHours = overdue.inHours;
          final overdueDays = overdue.inDays;
          const hourlyLateFee = 1.50;
          const dailyCap = 15.00;
          double currentDayFee = (overdueHours % 24) * hourlyLateFee;
          if (currentDayFee > dailyCap) currentDayFee = dailyCap;
          lateFee = (overdueDays * dailyCap) + currentDayFee;
        }
      }

      _smartAlertManager.checkBatteryStatus(
        charge: currentCharge,
        health: currentHealth,
        temperature: currentTemp,
      );

      final timer = RentalTimer(
        rentalId: rentalId,
        expiryTime: expiryTime,
        remainingDuration: remaining,
        lateFeeAmount: lateFee,
      );

      // Requirement: Notifications sent 24 hours before rental expiry
      if (remaining.inHours <= 24 && remaining.inHours > 23 && !_notified24h) {
        _sendFormattedNotification(
          rentalId,
          "Swap Reminder: Your rental expires in 24h. Nearby station: ${_nearbyStations[0]}",
          NotificationType.rental,
        );
        _notified24h = true;
      }

      // Requirement: Notifications sent 12 hours before expiry
      if (remaining.inHours <= 12 && remaining.inHours > 11 && !_notified12h) {
        _sendFormattedNotification(
          rentalId,
          "Plan a Swap: 12h remaining. ${_nearbyStations[1]} is just 0.8km away.",
          NotificationType.rental,
        );
        _notified12h = true;
      }

      // Requirement: Notifications sent 1 hour before expiry
      if (remaining.inMinutes <= 60 &&
          remaining.inMinutes > 50 &&
          !_notified1h) {
        _sendFormattedNotification(
          rentalId,
          "FINAL REMINDER: 1h left! Fast track swap available at ${_nearbyStations[2]}.",
          NotificationType.rental,
        );
        _notified1h = true;
      }

      yield timer;
      await Future.delayed(const Duration(minutes: 1));
    }
  }

  void _sendFormattedNotification(
      String id, String message, NotificationType type) {
    _notificationService.showNotification(NotificationItem(
      id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Rental Update',
      message: message,
      timestamp: DateTime.now(),
      type: type,
      data: {'rentalId': id},
    ));
  }
}
