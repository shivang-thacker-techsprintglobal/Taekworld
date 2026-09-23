import 'package:firebase_messaging/firebase_messaging.dart';

import '../../domain/entities/app_notification_entity.dart';

/// Parses an FCM [RemoteMessage] into a local history entity.
AppNotificationEntity notificationFromRemoteMessage(
  RemoteMessage message, {
  required String? masterPhone,
}) {
  final data = message.data;
  final notification = message.notification;

  final title = (data['title']?.toString().isNotEmpty == true)
      ? data['title'].toString()
      : (notification?.title ?? 'Taekworld Master');
  final body = (data['body']?.toString().isNotEmpty == true)
      ? data['body'].toString()
      : (notification?.body ?? '');

  final type = AppNotificationEntity.normalizeType(
    data['type']?.toString() ?? data['notificationType']?.toString(),
  );

  final id = data['notificationId']?.toString().isNotEmpty == true
      ? data['notificationId'].toString()
      : (message.messageId ??
          'fcm_${DateTime.now().millisecondsSinceEpoch}');

  final timestamp = DateTime.tryParse(data['timestamp']?.toString() ?? '') ??
      message.sentTime ??
      DateTime.now();

  final phone = masterPhone?.trim() ?? '';
  final url = phone.isNotEmpty
      ? 'https://www.blackbelthw.com/$phone'
      : 'https://www.blackbelthw.com/master';

  return AppNotificationEntity(
    id: id,
    title: title,
    message: body,
    timestamp: timestamp,
    type: type,
    isRead: false,
    url: url,
    entityId: data['entityId']?.toString(),
  );
}

/// Tab index for in-app navigation from a notification type.
///
/// Returns null when the app should fall back to the website browser hand-off.
int? tabIndexForNotificationType(String type) {
  switch (AppNotificationEntity.normalizeType(type)) {
    case 'application':
      return 1;
    case 'trial':
      return 2;
    default:
      return null;
  }
}
