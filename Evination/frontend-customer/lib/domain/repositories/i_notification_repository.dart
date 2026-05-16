import '../../data/models/notification/notification_model.dart';

abstract class INotificationRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}
