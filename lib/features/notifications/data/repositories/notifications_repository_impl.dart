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
  Future<void> markAsRead(String id) async {
    await _local.markAsRead(id);
    await _acknowledgeIfPossible(id);
  }

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
      // Use server notification id so acknowledge/{id} works on open.
      await _local.upsert(
        AppNotificationEntity(
          id: '${item.id}',
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

  /// Resolves a local inbox id to the server notification id, if any.
  static String? serverNotificationId(String localId) {
    final raw = localId.trim();
    if (raw.isEmpty) return null;
    if (raw.startsWith('pending_')) {
      final stripped = raw.substring('pending_'.length);
      return RegExp(r'^\d+$').hasMatch(stripped) ? stripped : null;
    }
    // FCM / pending rows use numeric notificationId; skip synthetic fcm_* keys.
    if (RegExp(r'^\d+$').hasMatch(raw)) return raw;
    return null;
  }

  Future<void> _acknowledgeIfPossible(String localId) async {
    final serverId = serverNotificationId(localId);
    if (serverId == null) return;
    try {
      await _remote.acknowledge(serverId);
    } catch (_) {
      // Local read already applied; server ack can fail offline.
    }
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
