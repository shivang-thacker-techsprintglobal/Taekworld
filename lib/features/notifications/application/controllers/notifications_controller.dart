import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../main_shell/presentation/screens/main_shell_screen.dart';
import '../../data/repositories/notifications_repository_impl.dart';
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
      _ref.read(notificationsBadgeProvider.notifier).state = newState.unreadCount;
    } catch (_) {
      if (state is! NotificationsSuccess) {
        state = const NotificationsError('Failed to load notifications.');
      }
    }
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    if (state is NotificationsSuccess) {
      final current = state as NotificationsSuccess;
      final updated = current.notifications.map((n) => n.copyWith(isRead: true)).toList();
      state = current.copyWith(notifications: updated);
      _ref.read(notificationsBadgeProvider.notifier).state = 0;
    }
  }

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
    if (state is NotificationsSuccess) {
      final current = state as NotificationsSuccess;
      final updated = current.notifications.map((n) {
        if (n.id == id) return n.copyWith(isRead: true);
        return n;
      }).toList();
      final newState = current.copyWith(notifications: updated);
      state = newState;
      _ref.read(notificationsBadgeProvider.notifier).state = newState.unreadCount;
    }
  }

  Future<void> deleteNotification(String id) async {
    await _repository.deleteNotification(id);
    if (state is NotificationsSuccess) {
      final current = state as NotificationsSuccess;
      final updated = current.notifications.where((n) => n.id != id).toList();
      final newState = current.copyWith(notifications: updated);
      state = newState;
      _ref.read(notificationsBadgeProvider.notifier).state = newState.unreadCount;
    }
  }

  Future<void> clearAll() async {
    await _repository.clearAll();
    state = const NotificationsSuccess(notifications: []);
    _ref.read(notificationsBadgeProvider.notifier).state = 0;
  }
}

final notificationsControllerProvider =
    StateNotifierProvider<NotificationsController, NotificationsState>((ref) {
  return NotificationsController(
    ref.watch(notificationsRepositoryProvider),
    ref,
  );
});
