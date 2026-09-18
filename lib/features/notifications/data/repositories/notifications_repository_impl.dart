import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  static List<AppNotificationEntity> _notifications = [
    AppNotificationEntity(
      id: 'notif_1',
      title: 'New Student Application',
      message: 'Olivia Davis submitted a new student application for Taekworld Academy.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      type: 'application',
      isRead: false,
      url: 'https://www.blackbelthw.com/7037601000',
    ),
    AppNotificationEntity(
      id: 'notif_2',
      title: 'New 7-Day Trial Member',
      message: 'Jay Smith registered for a 7-day free trial.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      type: 'trial',
      isRead: false,
      url: 'https://www.blackbelthw.com/7037601000',
    ),
    AppNotificationEntity(
      id: 'notif_3',
      title: 'Parent Recommendation Invitation',
      message: 'Elena Martinez invited a friend to join the academy.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: 'invitation',
      isRead: true,
      url: 'https://www.blackbelthw.com/7037601000',
    ),
    AppNotificationEntity(
      id: 'notif_4',
      title: 'Student Registration Confirmed',
      message: 'Lucas Brown completed registration and payment.',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      type: 'registration',
      isRead: true,
      url: 'https://www.blackbelthw.com/7037601000',
    ),
  ];

  @override
  Future<List<AppNotificationEntity>> getNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.of(_notifications);
  }

  @override
  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
  }

  @override
  Future<void> markAsRead(String id) async {
    _notifications = _notifications.map((n) {
      if (n.id == id) return n.copyWith(isRead: true);
      return n;
    }).toList();
  }

  @override
  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
  }

  @override
  Future<void> clearAll() async {
    _notifications.clear();
  }
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepositoryImpl();
});
