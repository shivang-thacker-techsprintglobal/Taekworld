import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../main_shell/application/shell_providers.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../domain/entities/app_notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import 'notifications_state.dart';

class NotificationsController extends StateNotifier<NotificationsState> {
  NotificationsController(this._repository, this._ref)
      : super(const NotificationsInitial());

  final NotificationsRepository _repository;
  final Ref _ref;

  Future<void> loadNotifications({bool isSilent = false}) async {
    if (!isSilent) {
      if (state is! NotificationsSuccess) {
        state = const NotificationsLoading();
      }
    }

    try {
      final items = await _repository.getNotifications();
      final newState = NotificationsSuccess(
        notifications: items,
        isRefreshing: false,
      );
      state = newState;
      await _publishUnread(newState.unreadCount);
    } catch (_) {
      if (state is! NotificationsSuccess) {
        state = const NotificationsError('Failed to load notifications.');
      }
    }
  }

  Future<void> addIncoming(AppNotificationEntity item) async {
    await _repository.addNotification(item);
    await loadNotifications(isSilent: true);
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    if (state is NotificationsSuccess) {
      final current = state as NotificationsSuccess;
      final updated =
          current.notifications.map((n) => n.copyWith(isRead: true)).toList();
      state = current.copyWith(notifications: updated);
      await _publishUnread(0);
    }
  }

  /// Notifications tab opened: mark-delivered after inbox is shown.
  /// Does **not** clear unread UI / badge — that happens on item tap or
  /// explicit "Mark all as read".
  Future<void> onInboxOpened() async {
    try {
      await _repository.markDisplayedAsDelivered();
    } catch (_) {}
  }

  Future<void> markAsRead(String id) async {
    // Local read + server acknowledge/{notificationId} when id is numeric.
    await _repository.markAsRead(id);
    if (state is NotificationsSuccess) {
      final current = state as NotificationsSuccess;
      final updated = current.notifications.map((n) {
        if (n.id == id) return n.copyWith(isRead: true);
        return n;
      }).toList();
      final newState = current.copyWith(notifications: updated);
      state = newState;
      await _publishUnread(newState.unreadCount);
    }
  }

  Future<void> deleteNotification(String id) async {
    await _repository.deleteNotification(id);
    if (state is NotificationsSuccess) {
      final current = state as NotificationsSuccess;
      final updated = current.notifications.where((n) => n.id != id).toList();
      final newState = current.copyWith(notifications: updated);
      state = newState;
      await _publishUnread(newState.unreadCount);
    }
  }

  Future<void> clearAll() async {
    await _repository.clearAll();
    state = const NotificationsSuccess(notifications: []);
    await _publishUnread(0);
  }

  Future<void> _publishUnread(int count) async {
    _ref.read(notificationsBadgeProvider.notifier).state = count;
    try {
      await AppBadgePlus.updateBadge(count);
    } catch (_) {}
  }
}

final notificationsControllerProvider =
    StateNotifierProvider<NotificationsController, NotificationsState>((ref) {
  return NotificationsController(
    ref.watch(notificationsRepositoryProvider),
    ref,
  );
});
