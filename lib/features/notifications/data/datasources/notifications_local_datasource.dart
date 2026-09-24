import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/app_notification_entity.dart';

/// Local notification history + device metadata (SharedPreferences).
///
/// Safe to use from the FCM background isolate (no Riverpod).
class NotificationsLocalDatasource {
  NotificationsLocalDatasource([SharedPreferences? prefs]) : _prefs = prefs;

  static const _historyKey = 'notifications.history_v1';
  static const _undeliveredIdsKey = 'notifications.undelivered_ids_v1';
  static const _deviceIdKey = 'notifications.device_id';
  static const _fcmTokenKey = 'notifications.fcm_token';
  static const _lastRegisterKey = 'notifications.last_register_at';
  static const _permissionAskedKey = 'notifications.permission_asked';
  static const _pendingOpenUrlKey = 'notifications.pending_open_url';
  static const _pendingOpenTypeKey = 'notifications.pending_open_type';
  static const _pendingOpenIdKey = 'notifications.pending_open_id';
  static const _pendingOpenEntityIdKey = 'notifications.pending_open_entity_id';
  static const _registerNeedsRetryKey = 'notifications.register_needs_retry';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _ensurePrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<String> getOrCreateDeviceId() async {
    final prefs = await _ensurePrefs();
    final existing = prefs.getString(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final id = const Uuid().v4();
    await prefs.setString(_deviceIdKey, id);
    return id;
  }

  Future<String?> readFcmToken() async {
    final prefs = await _ensurePrefs();
    return prefs.getString(_fcmTokenKey);
  }

  Future<void> saveFcmToken(String token) async {
    final prefs = await _ensurePrefs();
    await prefs.setString(_fcmTokenKey, token);
  }

  Future<void> clearFcmToken() async {
    final prefs = await _ensurePrefs();
    await prefs.remove(_fcmTokenKey);
  }

  Future<DateTime?> readLastRegisterAt() async {
    final prefs = await _ensurePrefs();
    final raw = prefs.getString(_lastRegisterKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> saveLastRegisterAt(DateTime at) async {
    final prefs = await _ensurePrefs();
    await prefs.setString(_lastRegisterKey, at.toUtc().toIso8601String());
  }

  Future<bool> readRegisterNeedsRetry() async {
    final prefs = await _ensurePrefs();
    return prefs.getBool(_registerNeedsRetryKey) ?? false;
  }

  Future<void> setRegisterNeedsRetry(bool value) async {
    final prefs = await _ensurePrefs();
    if (value) {
      await prefs.setBool(_registerNeedsRetryKey, true);
    } else {
      await prefs.remove(_registerNeedsRetryKey);
    }
  }

  Future<bool> wasPermissionPromptShown() async {
    final prefs = await _ensurePrefs();
    return prefs.getBool(_permissionAskedKey) ?? false;
  }

  Future<void> markPermissionPromptShown() async {
    final prefs = await _ensurePrefs();
    await prefs.setBool(_permissionAskedKey, true);
  }

  Future<void> savePendingOpen({
    String? url,
    String? type,
    String? notificationId,
    String? entityId,
  }) async {
    final prefs = await _ensurePrefs();
    if (url == null || url.isEmpty) {
      await prefs.remove(_pendingOpenUrlKey);
    } else {
      await prefs.setString(_pendingOpenUrlKey, url);
    }
    if (type == null || type.isEmpty) {
      await prefs.remove(_pendingOpenTypeKey);
    } else {
      await prefs.setString(_pendingOpenTypeKey, type);
    }
    if (notificationId == null || notificationId.isEmpty) {
      await prefs.remove(_pendingOpenIdKey);
    } else {
      await prefs.setString(_pendingOpenIdKey, notificationId);
    }
    if (entityId == null || entityId.isEmpty) {
      await prefs.remove(_pendingOpenEntityIdKey);
    } else {
      await prefs.setString(_pendingOpenEntityIdKey, entityId);
    }
  }

  Future<
      ({
        String? url,
        String? type,
        String? notificationId,
        String? entityId,
      })> consumePendingOpen() async {
    final prefs = await _ensurePrefs();
    final url = prefs.getString(_pendingOpenUrlKey);
    final type = prefs.getString(_pendingOpenTypeKey);
    final notificationId = prefs.getString(_pendingOpenIdKey);
    final entityId = prefs.getString(_pendingOpenEntityIdKey);
    await prefs.remove(_pendingOpenUrlKey);
    await prefs.remove(_pendingOpenTypeKey);
    await prefs.remove(_pendingOpenIdKey);
    await prefs.remove(_pendingOpenEntityIdKey);
    return (
      url: url,
      type: type,
      notificationId: notificationId,
      entityId: entityId,
    );
  }

  Future<List<AppNotificationEntity>> getNotifications() async {
    final prefs = await _ensurePrefs();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(AppNotificationEntity.fromJson)
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (_) {
      return const [];
    }
  }

  Future<void> _writeAll(List<AppNotificationEntity> items) async {
    final prefs = await _ensurePrefs();
    final capped = items.take(AppConstants.maxLocalNotifications).toList();
    await prefs.setString(
      _historyKey,
      jsonEncode(capped.map((e) => e.toJson()).toList()),
    );
  }

  Future<AppNotificationEntity> upsert(AppNotificationEntity item) async {
    final current = await getNotifications();
    final without = current.where((n) => n.id != item.id).toList();
    final next = [item, ...without];
    await _writeAll(next);
    return item;
  }

  /// Server notification ids that still need `mark-delivered` after the
  /// inbox has been shown (not when pending is first synced).
  Future<List<int>> readUndeliveredIds() async {
    final prefs = await _ensurePrefs();
    final raw = prefs.getStringList(_undeliveredIdsKey) ?? const <String>[];
    return raw
        .map(int.tryParse)
        .whereType<int>()
        .toList(growable: false);
  }

  Future<void> enqueueUndeliveredIds(Iterable<int> ids) async {
    final incoming = ids.where((id) => id > 0).toSet();
    if (incoming.isEmpty) return;
    final prefs = await _ensurePrefs();
    final current = (prefs.getStringList(_undeliveredIdsKey) ?? const <String>[])
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
    current.addAll(incoming);
    await prefs.setStringList(
      _undeliveredIdsKey,
      current.map((e) => '$e').toList(),
    );
  }

  Future<void> clearUndeliveredIds([Iterable<int>? ids]) async {
    final prefs = await _ensurePrefs();
    if (ids == null) {
      await prefs.remove(_undeliveredIdsKey);
      return;
    }
    final remove = ids.toSet();
    final current = (prefs.getStringList(_undeliveredIdsKey) ?? const <String>[])
        .map(int.tryParse)
        .whereType<int>()
        .where((id) => !remove.contains(id))
        .map((e) => '$e')
        .toList();
    if (current.isEmpty) {
      await prefs.remove(_undeliveredIdsKey);
    } else {
      await prefs.setStringList(_undeliveredIdsKey, current);
    }
  }

  Future<void> markAllAsRead() async {
    final current = await getNotifications();
    await _writeAll(current.map((n) => n.copyWith(isRead: true)).toList());
  }

  Future<void> markAsRead(String id) async {
    final current = await getNotifications();
    await _writeAll(
      current.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList(),
    );
  }

  Future<void> deleteNotification(String id) async {
    final current = await getNotifications();
    await _writeAll(current.where((n) => n.id != id).toList());
  }

  Future<void> clearAll() async {
    final prefs = await _ensurePrefs();
    await prefs.remove(_historyKey);
    await prefs.remove(_undeliveredIdsKey);
  }

  Future<int> unreadCount() async {
    final items = await getNotifications();
    return items.where((n) => !n.isRead).length;
  }
}
