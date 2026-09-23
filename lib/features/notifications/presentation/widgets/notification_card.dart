import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';
import '../../domain/entities/app_notification_entity.dart';

/// Notification row card widget per UI-SPEC §4.7.
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismissed,
  });

  final AppNotificationEntity notification;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  Future<void> _handleTap(BuildContext context) async {
    onTap();
    final targetUrl = notification.url ?? 'https://www.blackbelthw.com/master';
    final uri = Uri.parse(targetUrl);
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        _showCouldNotOpen(context, targetUrl);
      }
    } catch (_) {
      if (context.mounted) {
        _showCouldNotOpen(context, targetUrl);
      }
    }
  }

  void _showCouldNotOpen(BuildContext context, String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Could not open browser'),
        action: SnackBarAction(
          label: 'Copy Link',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: url));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    final (IconData iconData, Color iconColor) =
        switch (notification.type.toLowerCase()) {
      'application' => (Icons.person_add, AppColors.primary),
      'trial' => (Icons.people, AppColors.accentOrange),
      'registration' => (Icons.how_to_reg, AppColors.accentGreen),
      'invitation' => (Icons.mail, AppColors.accentPurple),
      _ => (Icons.notifications, AppColors.brandNavy),
    };

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 24),
            SizedBox(width: 6),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      child: Material(
        color: isUnread ? const Color(0xFFF0F7FF) : AppColors.surface,
        elevation: 1.0,
        shadowColor: Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10.0),
        child: InkWell(
          onTap: () => _handleTap(context),
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: isUnread ? const Color(0xFFBBDEFB) : AppColors.border,
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: iconColor.withValues(alpha: 0.14),
                  child: Icon(iconData, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTextStyle.t2(
                                context,
                                color: AppColors.textPrimary,
                              ).copyWith(
                                fontWeight:
                                    isUnread ? FontWeight.w700 : FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.accentBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        notification.message,
                        style: AppTextStyle.b3(
                          context,
                          color: AppColors.textSecondary,
                        ).copyWith(
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        notification.relativeTime,
                        style: AppTextStyle.b4(
                          context,
                          color: AppColors.textDisabled,
                        ).copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
