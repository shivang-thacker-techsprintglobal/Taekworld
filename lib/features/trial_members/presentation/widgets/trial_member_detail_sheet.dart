import 'package:flutter/material.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';
import '../../../../core/widgets/info_row.dart';
import '../../domain/entities/trial_member_entity.dart';

/// Trial Member Detail Bottom Sheet (60% screen height) per UI-SPEC §4.6.
class TrialMemberDetailSheet extends StatelessWidget {
  const TrialMemberDetailSheet({
    super.key,
    required this.member,
  });

  final TrialMemberEntity member;

  static Future<void> show(BuildContext context, {required TrialMemberEntity member}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.60,
        child: TrialMemberDetailSheet(member: member),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final is7Day = member.isSevenDay;
    final accentColor = is7Day ? AppColors.accentOrange : AppColors.accentGreen;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12.0),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          const SizedBox(height: 16.0),

          // Header Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    member.displayName,
                    style: AppTextStyle.h3(
                      context,
                      color: AppColors.brandNavy,
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    '${member.trialType}-Day Trial',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16.0),
          const Divider(height: 1, color: AppColors.border),

          // Details List
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1.0),
                ),
                child: Column(
                  children: [
                    InfoRow(label: 'Email', value: member.email, labelWidth: 120),
                    InfoRow(label: 'Phone', value: member.parentPhone, labelWidth: 120),
                    InfoRow(label: 'User Code', value: member.userCode, labelWidth: 120),
                    InfoRow(label: 'Registration Date', value: member.registrationDate, labelWidth: 120),
                    InfoRow(label: 'Trial Ends', value: member.trialEndDate, labelWidth: 120),
                    InfoRow(
                      label: 'Days Remaining',
                      value: member.isExpired ? 'Expired' : '${member.daysRemaining} days',
                      labelWidth: 120,
                      valueColor: member.isExpired ? AppColors.error : null,
                    ),
                    InfoRow(
                      label: 'New Student',
                      value: member.isNewStudent ? 'Yes' : 'No',
                      labelWidth: 120,
                      valueColor: member.isNewStudent ? AppColors.success : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
