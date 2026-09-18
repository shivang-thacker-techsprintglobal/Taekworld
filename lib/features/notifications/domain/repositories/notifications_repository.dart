import '../entities/app_notification_entity.dart';

abstract class NotificationsRepository {
  Future<List<AppNotificationEntity>> getNotifications();
  Future<void> markAllAsRead();
  Future<void> markAsRead(String id);
  Future<void> deleteNotification(String id);
  Future<void> clearAll();
}
