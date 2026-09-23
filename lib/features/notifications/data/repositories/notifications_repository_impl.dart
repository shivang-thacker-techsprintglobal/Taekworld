import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_local_datasource.dart';
import '../datasources/notifications_remote_datasource.dart';
import '../models/pending_notifications_response.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl({
    required NotificationsLocalDatasource local,
    required NotificationsRemoteDatasource remote,
  })  : _local = local,
        _remote = remote;

  final NotificationsLocalDatasource _local;
  final NotificationsRemoteDatasource _remote;

  @override
  Future<List<AppNotificationEntity>> getNotifications() =>
      _local.getNotifications();

  @override
  Future<void> markAllAsRead() => _local.markAllAsRead();

  @override
  Future<void> markAsRead(String id) => _local.markAsRead(id);

  @override
  Future<void> deleteNotification(String id) => _local.deleteNotification(id);

  @override
  Future<void> clearAll() => _local.clearAll();

  @override
  Future<AppNotificationEntity> addNotification(AppNotificationEntity item) =>
      _local.upsert(item);

  @override
  Future<int> unreadCount() => _local.unreadCount();

  @override
  Future<void> registerDevice({
    required String fcmToken,
    required String platform,
    required int dojangId,
    required String deviceInfo,
  }) {
    return _remote.registerDevice(
      fcmToken: fcmToken,
      platform: platform,
      dojangId: dojangId,
      deviceInfo: deviceInfo,
    );
  }

  @override
  Future<void> deleteDevice({required String fcmToken}) {
    return _remote.deleteDevice(fcmToken: fcmToken);
  }

  @override
  Future<int> syncPendingNotifications({
    required String dojangId,
    required String masterPhone,
  }) async {
    final deviceId = await _local.getOrCreateDeviceId();
    late final PendingNotificationsResponse pending;
    try {
      pending = await _remote.getPending(
        dojangId: dojangId,
        deviceId: deviceId,
      );
    } catch (_) {
      return 0;
    }

    if (pending.notifications.isEmpty) return 0;

    final webUrl = masterPhone.trim().isNotEmpty
        ? 'https://www.blackbelthw.com/${masterPhone.trim()}'
        : 'https://www.blackbelthw.com/master';

    for (final item in pending.notifications) {
      await _local.upsert(
        AppNotificationEntity(
          id: 'pending_${item.id}',
          title: item.title,
          message: item.message,
          timestamp: item.createdAt ?? DateTime.now(),
          type: AppNotificationEntity.normalizeType(item.type),
          isRead: false,
          url: webUrl,
          entityId: item.entityId.isNotEmpty ? item.entityId : null,
        ),
      );
    }

    try {
      await _remote.markDelivered(
        notificationIds: pending.notifications.map((e) => e.id).toList(),
        deviceId: deviceId,
      );
    } catch (_) {
      // History is already mirrored locally; delivery ack can retry later.
    }

    return pending.notifications.length;
  }
}

final notificationsLocalDatasourceProvider =
    Provider<NotificationsLocalDatasource>((ref) {
  return NotificationsLocalDatasource();
});

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  return NotificationsRepositoryImpl(
    local: ref.watch(notificationsLocalDatasourceProvider),
    remote: ref.watch(notificationsRemoteDatasourceProvider),
  );
});
