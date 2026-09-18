import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/app_size.dart';
import '../../config/app_text_style.dart';

/// Primary application button.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.backgroundColor,
    this.borderRadius,
    this.textStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Color? backgroundColor;
  final double? borderRadius;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final enabled = isEnabled && !isLoading && onPressed != null;

    final effectiveBg = backgroundColor ?? AppColors.primary;
    final effectiveRadius = borderRadius ?? 8.0;
    final effectiveTextStyle = textStyle ??
        AppTextStyle.b1(
          context,
          color: AppColors.onPrimary,
        ).copyWith(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        );

    return SizedBox(
      height: AppSize.buttonHeight(context),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBg,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: effectiveBg.withValues(alpha: 0.6),
          disabledForegroundColor: AppColors.onPrimary.withValues(alpha: 0.8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(effectiveRadius),
          ),
        ),
        onPressed: enabled ? onPressed : null,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                ),
              )
            : Text(
                label,
                style: effectiveTextStyle,
              ),
      ),
    );
  }
}
