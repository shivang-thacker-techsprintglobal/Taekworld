import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/app_size.dart';
import '../../config/app_text_style.dart';

/// Full-section empty state.
class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSize.lg(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppSize.iconLarge(context) * 1.5,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: AppSize.md(context)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyle.b1(context, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
