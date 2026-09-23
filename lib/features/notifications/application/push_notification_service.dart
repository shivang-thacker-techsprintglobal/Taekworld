import 'dart:async';
import 'dart:io';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../applications/application/controllers/applications_controller.dart';
import '../../main_shell/application/shell_providers.dart';
import '../../trial_members/application/controllers/trial_members_controller.dart';
import '../domain/entities/app_notification_entity.dart';
import '../data/datasources/notifications_local_datasource.dart';
import '../data/mappers/fcm_message_mapper.dart';
import '../data/repositories/notifications_repository_impl.dart';
import 'controllers/notifications_controller.dart';

/// Top-level background handler (must be a top-level or static function).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is initialized in main() before runApp; background isolates need
  // their own init when launched from a terminated state.
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  final local = NotificationsLocalDatasource();
  final entity = notificationFromRemoteMessage(message, masterPhone: null);
  await local.upsert(entity);
  final unread = await local.unreadCount();
  try {
    await AppBadgePlus.updateBadge(unread);
  } catch (_) {}
}

/// Coordinates FCM registration, local heads-up display, history mirroring,
/// and notification tap routing (UI-SPEC §5 / API §4).
class PushNotificationService {
  PushNotificationService(this._ref);

  final Ref _ref;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onOpenedSub;
  StreamSubscription<String>? _onTokenSub;

  NotificationsLocalDatasource get _local =>
      _ref.read(notificationsLocalDatasourceProvider);

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _setupLocalNotifications();

    final messaging = FirebaseMessaging.instance;
    // Foreground: do not use the OS banner — we show flutter_local_notifications.
    await messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );

    _onMessageSub = FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    _onOpenedSub =
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);
    _onTokenSub = messaging.onTokenRefresh.listen((token) async {
      await _local.saveFcmToken(token);
      await registerDeviceWithBackend(force: true);
    });

    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      await _storePendingOpenFromMessage(initial);
    }
  }

  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        // payload format: type|url|notificationId
        final parts = payload.split('|');
        final type = parts.isNotEmpty ? parts[0] : 'other';
        final url = parts.length > 1 ? parts[1] : null;
        final notificationId = parts.length > 2 ? parts[2] : null;
        unawaited(
          _routeNotificationTap(
            type: type,
            url: url?.isEmpty == true ? null : url,
            notificationId: notificationId?.isEmpty == true ? null : notificationId,
          ),
        );
      },
    );

    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        description: 'Taekworld Master alerts',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound('notification'),
        ledColor: Color(0xFFFF0000),
      ),
    );
  }

  /// Soft-ask result → OS permission request when user taps Enable.
  Future<bool> requestOsPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );
    final enabled = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    if (Platform.isAndroid) {
      final androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    }

    return enabled;
  }

  Future<NotificationSettings> getPermissionSettings() {
    return FirebaseMessaging.instance.getNotificationSettings();
  }

  Future<void> registerDeviceWithBackend({bool force = false}) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;
    final dojangId = user.dojangId;
    if (dojangId == null) return;

    if (!force) {
      final last = await _local.readLastRegisterAt();
      if (last != null &&
          DateTime.now().difference(last) <
              AppConstants.deviceReregisterInterval) {
        return;
      }
    }

    final settings = await getPermissionSettings();
    final allowed = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    if (!allowed) return;

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;

      await _local.saveFcmToken(token);
      final deviceInfo = await _buildDeviceInfo();
      await _ref.read(notificationsRepositoryProvider).registerDevice(
            fcmToken: token,
            platform: Platform.isIOS ? 'ios' : 'android',
            dojangId: dojangId,
            deviceInfo: deviceInfo,
          );
      await _local.saveLastRegisterAt(DateTime.now());

      // Optional pending-queue catch-up after (re)register.
      await _ref.read(notificationsRepositoryProvider).syncPendingNotifications(
            dojangId: user.academyId,
            masterPhone: user.phoneNumber,
          );
      await _ref
          .read(notificationsControllerProvider.notifier)
          .loadNotifications(isSilent: true);
      await _syncAppBadge();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FCM register-device failed: $e');
      }
    }
  }

  Future<void> unregisterDevice() async {
    final token = await _local.readFcmToken();
    if (token == null || token.isEmpty) return;
    try {
      await _ref
          .read(notificationsRepositoryProvider)
          .deleteDevice(fcmToken: token);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FCM delete-device failed: $e');
      }
    } finally {
      await _local.clearFcmToken();
      try {
        await FirebaseMessaging.instance.deleteToken();
      } catch (_) {}
    }
  }

  Future<void> onAppResumed() async {
    await registerDeviceWithBackend(force: false);
    await consumePendingOpenIfAny();
  }

  Future<void> consumePendingOpenIfAny() async {
    final pending = await _local.consumePendingOpen();
    if (pending.url == null && pending.type == null) return;
    await _routeNotificationTap(
      type: pending.type ?? 'other',
      url: pending.url,
      notificationId: pending.notificationId,
    );
  }

  Future<String> _buildDeviceInfo() async {
    final plugin = DeviceInfoPlugin();
    try {
      if (Platform.isIOS) {
        final ios = await plugin.iosInfo;
        return '${ios.name} - iOS ${ios.systemVersion}';
      }
      if (Platform.isAndroid) {
        final android = await plugin.androidInfo;
        return '${android.model} - Android ${android.version.release}';
      }
    } catch (_) {}
    return Platform.operatingSystem;
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final user = _ref.read(currentUserProvider);
    final entity = notificationFromRemoteMessage(
      message,
      masterPhone: user?.phoneNumber,
    );
    await _mirrorAndRefresh(entity);
    await _showLocalHeadsUp(entity);
  }

  Future<void> _handleNotificationOpen(RemoteMessage message) async {
    final user = _ref.read(currentUserProvider);
    final entity = notificationFromRemoteMessage(
      message,
      masterPhone: user?.phoneNumber,
    );
    await _mirrorAndRefresh(entity);
    await _routeNotificationTap(
      type: entity.type,
      url: entity.url,
      notificationId: entity.id,
    );
  }

  Future<void> _storePendingOpenFromMessage(RemoteMessage message) async {
    final user = _ref.read(currentUserProvider);
    final entity = notificationFromRemoteMessage(
      message,
      masterPhone: user?.phoneNumber,
    );
    await _local.upsert(entity);
    await _local.savePendingOpen(
      url: entity.url,
      type: entity.type,
      notificationId: entity.id,
    );
  }

  Future<void> _mirrorAndRefresh(AppNotificationEntity entity) async {
    await _ref.read(notificationsRepositoryProvider).addNotification(entity);
    await _ref
        .read(notificationsControllerProvider.notifier)
        .loadNotifications(isSilent: true);
    await _syncAppBadge();
    _refreshRelatedTabs(entity.type);
  }

  void _refreshRelatedTabs(String type) {
    final user = _ref.read(currentUserProvider);
    final dojangId = user?.academyId;
    if (dojangId == null || dojangId.isEmpty) return;

    final normalized = AppNotificationEntity.normalizeType(type);
    if (normalized == 'application') {
      unawaited(
        _ref
            .read(applicationsControllerProvider.notifier)
            .loadApplications(dojangId, isSilent: true),
      );
    } else if (normalized == 'trial' || normalized == 'registration') {
      unawaited(
        _ref
            .read(trialMembersControllerProvider.notifier)
            .loadTrialMembers(dojangId, isSilent: true),
      );
    }
  }

  Future<void> _showLocalHeadsUp(AppNotificationEntity entity) async {
    final androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: 'Taekworld Master alerts',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
      enableLights: true,
      ledColor: const Color(0xFFFF0000),
      styleInformation: BigTextStyleInformation(
        entity.message,
        contentTitle: entity.title,
        summaryText: 'Tap to open Taekworld',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification.caf',
      subtitle: 'Taekworld Master',
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    await _localNotifications.show(
      entity.id.hashCode,
      entity.title,
      entity.message,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: '${entity.type}|${entity.url ?? ''}|${entity.id}',
    );
  }

  Future<void> _routeNotificationTap({
    required String type,
    String? url,
    String? notificationId,
  }) async {
    if (notificationId != null && notificationId.isNotEmpty) {
      // Local read + POST /api/Notification/acknowledge/{notificationId}
      await _ref
          .read(notificationsControllerProvider.notifier)
          .markAsRead(notificationId);
    }

    final tab = tabIndexForNotificationType(type);
    if (tab != null) {
      _ref.read(bottomNavIndexProvider.notifier).state = tab;
      _refreshRelatedTabs(type);
      return;
    }

    // Fallback / unknown types → external browser.
    _ref.read(pendingBrowserOpenProvider.notifier).state = url;
  }

  Future<void> _syncAppBadge() async {
    final unread = await _ref.read(notificationsRepositoryProvider).unreadCount();
    _ref.read(notificationsBadgeProvider.notifier).state = unread;
    try {
      if (unread <= 0) {
        await AppBadgePlus.updateBadge(0);
      } else {
        await AppBadgePlus.updateBadge(unread);
      }
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _onMessageSub?.cancel();
    await _onOpenedSub?.cancel();
    await _onTokenSub?.cancel();
  }
}

/// Holds a URL that MainShell should open in the external browser.
// pendingBrowserOpenProvider lives in shell_providers.dart

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  final service = PushNotificationService(ref);
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});
