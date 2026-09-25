import '../entities/app_notification_entity.dart';

abstract class NotificationsRepository {
  Future<List<AppNotificationEntity>> getNotifications();
  Future<void> markAllAsRead();

  /// Marks read locally and acknowledges on the server when [id] is a
  /// server `notificationId`.
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
  /// Upserts locally as unread; does **not** call mark-delivered — that runs
  /// after the Notifications inbox is displayed.
  ///
  /// Returns server `totalCount` (badge source of truth).
  Future<int> syncPendingNotifications({
    required String dojangId,
    required String masterPhone,
  });

  /// `GET /api/Notification/pending/{dojangId}` → `totalCount` for the badge.
  Future<int> getPendingTotalCount({required String dojangId});

  /// Call after inbox items are shown so they drop out of server `pending`.
  Future<void> markDisplayedAsDelivered();
}
