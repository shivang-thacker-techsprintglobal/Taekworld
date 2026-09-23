import '../entities/app_notification_entity.dart';

abstract class NotificationsRepository {
  Future<List<AppNotificationEntity>> getNotifications();
  Future<void> markAllAsRead();
  Future<void> markAsRead(String id);
  Future<void> deleteNotification(String id);
  Future<void> clearAll();
  Future<AppNotificationEntity> addNotification(AppNotificationEntity item);
  Future<int> unreadCount();

  Future<void> registerDevice({
    required String fcmToken,
    required String platform,
    required int dojangId,
    required String deviceInfo,
  });

  Future<void> deleteDevice({required String fcmToken});

  /// Cold-start catch-up from the pending queue (optional path).
  Future<int> syncPendingNotifications({
    required String dojangId,
    required String masterPhone,
  });
}
