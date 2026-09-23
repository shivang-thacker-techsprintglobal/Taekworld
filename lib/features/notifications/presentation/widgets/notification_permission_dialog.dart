import 'package:flutter/material.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';

/// Soft-ask permission dialog per UI-SPEC §5 (both platforms).
class NotificationPermissionDialog extends StatelessWidget {
  const NotificationPermissionDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const NotificationPermissionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Enable Notifications?',
        style: AppTextStyle.t1(context, color: AppColors.brandNavy).copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Get notified about important updates and new messages. You can change this later in Settings.',
            style: AppTextStyle.b2(context),
          ),
          const SizedBox(height: 12),
          Text(
            'Note: Notifications are optional and the app works without them.',
            style: AppTextStyle.b3(context, color: AppColors.textSecondary),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Not Now',
            style: AppTextStyle.t3(context, color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            'Enable',
            style: AppTextStyle.t3(context, color: AppColors.primary).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
