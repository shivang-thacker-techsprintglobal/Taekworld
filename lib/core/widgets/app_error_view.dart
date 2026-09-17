import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/app_size.dart';
import '../../config/app_text_style.dart';
import 'app_button.dart';

/// Full-section error state with optional retry.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSize.lg(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: AppSize.iconLarge(context) * 1.5,
              color: AppColors.error,
            ),
            SizedBox(height: AppSize.md(context)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyle.b1(context, color: AppColors.textSecondary),
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppSize.lg(context)),
              AppButton(label: 'Try again', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
