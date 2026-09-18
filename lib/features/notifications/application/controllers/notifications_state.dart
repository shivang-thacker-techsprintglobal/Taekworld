import '../../domain/entities/app_notification_entity.dart';

abstract class NotificationsState {
  const NotificationsState();
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsSuccess extends NotificationsState {
  const NotificationsSuccess({
    required this.notifications,
    this.isRefreshing = false,
  });

  final List<AppNotificationEntity> notifications;
  final bool isRefreshing;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationsSuccess copyWith({
    List<AppNotificationEntity>? notifications,
    bool? isRefreshing,
  }) {
    return NotificationsSuccess(
      notifications: notifications ?? this.notifications,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class NotificationsError extends NotificationsState {
  const NotificationsError(this.message);
  final String message;
}
