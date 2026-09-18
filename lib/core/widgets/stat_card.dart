import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/app_text_style.dart';

/// Reusable Stat Card widget.
///
/// Per UI-SPEC §4.3 & §6:
/// White card, elevation 2, 4px left accent border, 14sp grey title,
/// 32sp bold accent value.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.accentColor,
    this.onTap,
  });

  final String title;
  final String value;
  final Color accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 2.0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border, width: 1.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4.0,
                    color: accentColor,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 14.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: AppTextStyle.t3(
                              context,
                              color: AppColors.textSecondary,
                            ).copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6.0),
                          Text(
                            value,
                            style: AppTextStyle.h1(
                              context,
                              color: accentColor,
                            ).copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
