import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/i_notification_repository.dart';
import '../models/notification/notification_model.dart';

class NotificationRepositoryImpl implements INotificationRepository {
  @override
  Future<List<NotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      NotificationModel(
        id: '1',
        title: 'Vendor Accepted Your Bid! 🎉',
        message: 'Elite Caterers has accepted your bid for Sarah & John Wedding.',
        type: 'success',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      NotificationModel(
        id: '2',
        title: 'Payment Reminder',
        message: 'Your payment of ₹75,000 for Amit 30th Birthday is due.',
        type: 'warning',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: false,
      ),
      NotificationModel(
        id: '3',
        title: 'Booking Confirmed',
        message: 'Your booking for Product Launch has been confirmed.',
        type: 'info',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ];
  }

  @override
  Future<void> markAsRead(String id) async {
    // Mock impl
  }

  @override
  Future<void> markAllAsRead() async {
    // Mock impl
  }
}

final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  return NotificationRepositoryImpl();
});
