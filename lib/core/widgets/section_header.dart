import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/app_text_style.dart';

/// Reusable section header per UI-SPEC §6.
///
/// Features a title, coloured bottom underline, and an optional count chip on the right.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.underlineColor = AppColors.brandNavy,
    this.underlineThickness = 2.0,
    this.titleColor,
    this.titleFontSize = 18,
    this.countText,
    this.isHighlighted = false,
    this.pillText,
  });

  final String title;
  final Color underlineColor;
  final double underlineThickness;
  final Color? titleColor;
  final double titleFontSize;
  final String? countText;
  final bool isHighlighted;
  final String? pillText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: AppTextStyle.t1(
                context,
                color: titleColor ?? AppColors.brandNavy,
              ).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: titleFontSize,
              ),
            ),
            if (pillText != null) ...[
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  pillText!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const Spacer(),
            if (countText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? AppColors.accentOrange.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  countText!,
                  style: TextStyle(
                    color: isHighlighted
                        ? AppColors.accentOrange
                        : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6.0),
        Container(
          height: underlineThickness,
          width: double.infinity,
          color: underlineColor,
        ),
      ],
    );
  }
}
