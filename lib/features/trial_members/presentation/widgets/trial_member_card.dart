import 'package:flutter/material.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';
import '../../domain/entities/trial_member_entity.dart';

/// Trial Member Card widget per UI-SPEC §4.6.
class TrialMemberCard extends StatelessWidget {
  const TrialMemberCard({
    super.key,
    required this.member,
    required this.onTap,
  });

  final TrialMemberEntity member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final is7Day = member.isSevenDay;
    final accentColor = is7Day ? AppColors.accentOrange : AppColors.accentGreen;
    // UI-SPEC §4.6 — "?" when there is no name.
    final trimmedName = member.name.trim();
    final initial = trimmedName.isNotEmpty
        ? trimmedName[0].toUpperCase()
        : '?';
    final trialDaysLabel = '${is7Day ? 7 : 30} days';

    return Material(
      color: AppColors.surface,
      elevation: 2.0,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(10.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: AppColors.border, width: 1.0),
          ),
          child: Row(
            children: [
              // Circle Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: accentColor.withValues(alpha: 0.18),
                child: Text(
                  initial,
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),

              // Member Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.displayName,
                      style: AppTextStyle.t2(
                        context,
                        color: AppColors.textPrimary,
                      ).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3.0),
                    if (member.email.isNotEmpty)
                      Text(
                        member.email,
                        style: AppTextStyle.b3(
                          context,
                          color: AppColors.textSecondary,
                        ).copyWith(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (member.parentPhone.isNotEmpty)
                      Text(
                        member.parentPhone,
                        style: AppTextStyle.b3(
                          context,
                          color: AppColors.textSecondary,
                        ).copyWith(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 8.0),

              // Right Column (Pill + Days left / Expired)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      trialDaysLabel,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    member.isExpired
                        ? 'Expired'
                        : '${member.daysRemaining} days left',
                    style: TextStyle(
                      color: member.isExpired ? AppColors.error : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: member.isExpired ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
