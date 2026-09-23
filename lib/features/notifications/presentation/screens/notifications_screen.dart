import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_scale.dart';
import '../../../../config/app_text_style.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../application/controllers/notifications_controller.dart';
import '../../application/controllers/notifications_state.dart';
import '../widgets/notification_card.dart';

/// Tab 3: Notifications History Screen per UI-SPEC §4.7.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsControllerProvider.notifier).loadNotifications();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(notificationsControllerProvider.notifier).loadNotifications(isSilent: true);
  }

  Future<void> _showClearHistoryDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Clear History',
          style: AppTextStyle.t1(ctx, color: AppColors.brandNavy),
        ),
        content: Text(
          'Are you sure you want to clear all notification history?',
          style: AppTextStyle.b2(ctx),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: AppTextStyle.t3(ctx, color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Clear',
              style: AppTextStyle.t3(ctx, color: AppColors.error).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(notificationsControllerProvider.notifier).clearAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification history cleared')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: AppTextStyle.t1(
            context,
            color: Colors.white,
          ).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          if (state is NotificationsSuccess && state.notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'mark_all') {
                  ref.read(notificationsControllerProvider.notifier).markAllAsRead();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All notifications marked as read')),
                  );
                } else if (value == 'clear_all') {
                  _showClearHistoryDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_all',
                  child: Text('Mark all as read'),
                ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Text(
                    'Clear history',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: state is NotificationsLoading
          ? const Center(child: AppLoader())
          : state is NotificationsSuccess
              ? state.notifications.isEmpty
                  ? _buildEmptyView(context)
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _onRefresh,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppScale.pagePadding(context),
                          vertical: 16.0,
                        ),
                        itemCount: state.notifications.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10.0),
                        itemBuilder: (context, index) {
                          final item = state.notifications[index];
                          return NotificationCard(
                            notification: item,
                            onTap: () {
                              ref
                                  .read(notificationsControllerProvider.notifier)
                                  .markAsRead(item.id);
                            },
                            onDismissed: () {
                              ref
                                  .read(notificationsControllerProvider.notifier)
                                  .deleteNotification(item.id);
                            },
                          );
                        },
                      ),
                    )
              : const SizedBox.shrink(),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 16.0),
            Text(
              'No notifications yet',
              style: AppTextStyle.t1(
                context,
                color: AppColors.textPrimary,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Notifications will appear here when you receive them',
              style: AppTextStyle.b2(
                context,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
