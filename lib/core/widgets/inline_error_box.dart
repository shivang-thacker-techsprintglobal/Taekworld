import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/app_size.dart';
import '../../config/app_text_style.dart';

/// Reusable inline error alert box.
///
/// Designed per UI-SPEC §4.1: background #FFEBEE, border #EF9A9A, text #D32F2F 14sp.
class InlineErrorBox extends StatelessWidget {
  const InlineErrorBox({
    super.key,
    required this.message,
    this.margin,
  });

  final String message;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: margin ?? EdgeInsets.only(bottom: AppSize.md(context)),
      padding: EdgeInsets.all(AppSize.sm(context) + 4),
      decoration: BoxDecoration(
        color: AppColors.errorBackground,
        borderRadius: BorderRadius.circular(AppSize.radiusSmall(context)),
        border: Border.all(
          color: AppColors.errorBorder,
          width: AppSize.borderThin,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: AppSize.iconSmall(context),
            color: AppColors.error,
          ),
          SizedBox(width: AppSize.sm(context)),
          Expanded(
            child: Text(
              message,
              style: AppTextStyle.b2(
                context,
                color: AppColors.error,
              ).copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
