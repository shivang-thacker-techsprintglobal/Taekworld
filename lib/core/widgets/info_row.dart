import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/app_text_style.dart';

/// Reusable label-value row for cards and bottom sheets.
///
/// Per UI-SPEC §6: Label is 100px wide (w600 grey), followed by the value text
/// which wraps and defaults to "N/A" if empty or null.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    this.value,
    this.labelWidth = 100.0,
    this.valueColor,
  });

  final String label;
  final String? value;
  final double labelWidth;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final displayValue = (value == null || value!.trim().isEmpty) ? 'N/A' : value!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: AppTextStyle.t3(
                context,
                color: AppColors.textSecondary,
              ).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: AppTextStyle.b2(
                context,
                color: valueColor ?? AppColors.textPrimary,
              ).copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
