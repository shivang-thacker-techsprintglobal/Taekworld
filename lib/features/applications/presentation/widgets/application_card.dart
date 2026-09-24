import 'package:flutter/material.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../domain/entities/application_item_entity.dart';

/// Application Card widget per UI-SPEC §4.4.
class ApplicationCard extends StatelessWidget {
  const ApplicationCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final ApplicationItemEntity item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isNew = item.isNew;
    final isPending = item.status.toLowerCase() == 'pending';

    // Avatar background color
    final Color avatarBgColor;
    final Color avatarTextColor;
    if (isNew) {
      avatarBgColor = const Color(0xFFFFD54F); // Yellow
      avatarTextColor = AppColors.brandNavy;
    } else if (isPending) {
      avatarBgColor = AppColors.primary; // Brand red
      avatarTextColor = Colors.white;
    } else {
      avatarBgColor = Colors.grey.shade400; // Grey history
      avatarTextColor = Colors.white;
    }

    final initial = item.studentName.trim().isNotEmpty
        ? item.studentName.trim()[0].toUpperCase()
        : 'S';

    return Material(
      color: AppColors.surface,
      elevation: 2.0,
      shadowColor: Colors.black.withValues(alpha: 0.06),
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
                  // 4px left highlight for NEW applications
                  if (isNew)
                    Container(
                      width: 4.0,
                      color: const Color(0xFFFFC107),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                      child: Row(
                        children: [
                          // Circle Avatar with student initial
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: avatarBgColor,
                            child: Text(
                              initial,
                              style: TextStyle(
                                color: avatarTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          // Content Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        item.studentName,
                                        style: AppTextStyle.t2(
                                          context,
                                          color: AppColors.textPrimary,
                                        ).copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isNew) ...[
                                      const SizedBox(width: 6.0),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6.0,
                                          vertical: 2.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFEB3B),
                                          borderRadius: BorderRadius.circular(6.0),
                                          border: Border.all(
                                            color: const Color(0xFFFBC02D),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: const Text(
                                          'NEW',
                                          style: TextStyle(
                                            color: Color(0xFF5D4037),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3.0),
                                Text(
                                  'Parent: ${item.parentName}',
                                  style: AppTextStyle.b2(
                                    context,
                                    color: AppColors.textSecondary,
                                  ).copyWith(fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2.0),
                                // Green check only for viewed items; unviewed show Applied date.
                                if (item.isViewed &&
                                    (item.viewedDateFormatted.isNotEmpty ||
                                        (item.viewedDate?.isNotEmpty ?? false)))
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: AppColors.success,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        _viewedLabel(item),
                                        style: AppTextStyle.b3(
                                          context,
                                          color: AppColors.textSecondary,
                                        ).copyWith(fontSize: 12),
                                      ),
                                    ],
                                  )
                                else if (item.applicationDate.isNotEmpty)
                                  Text(
                                    'Applied: ${AppDateFormat.display(item.applicationDate)}',
                                    style: AppTextStyle.b3(
                                      context,
                                      color: AppColors.textSecondary,
                                    ).copyWith(fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.textDisabled,
                            size: 22,
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

  String _viewedLabel(ApplicationItemEntity item) {
    // Prefer full UTC viewedDate (has time) over date-only viewedDateFormatted.
    final raw = (item.viewedDate?.trim().isNotEmpty ?? false)
        ? item.viewedDate!.trim()
        : item.viewedDateFormatted.trim();
    if (raw.toLowerCase().startsWith('viewed')) {
      final withoutPrefix = raw.replaceFirst(
        RegExp(r'^viewed\s+on\s+', caseSensitive: false),
        '',
      );
      return 'Viewed on ${AppDateFormat.display(withoutPrefix, fallback: withoutPrefix)}';
    }
    return 'Viewed on ${AppDateFormat.display(raw, fallback: raw)}';
  }
}
