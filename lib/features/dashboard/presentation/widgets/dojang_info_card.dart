import 'package:flutter/material.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';
import '../../../../core/widgets/info_row.dart';
import '../../../login/domain/entities/user_entity.dart';

/// Dojang Information Card per UI-SPEC §4.3.
class DojangInfoCard extends StatelessWidget {
  const DojangInfoCard({
    super.key,
    required this.user,
  });

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppColors.border,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dojang Information',
            style: AppTextStyle.t1(
              context,
              color: AppColors.brandNavy,
            ).copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12.0),
          // API Fields:
          // 1. Name -> user.academyName
          InfoRow(label: 'Name', value: user.academyName.isNotEmpty ? user.academyName : 'Taekworld Academy'),
          // 2. ID -> user.academyId (dojang id used in all requests)
          InfoRow(label: 'ID', value: user.academyId.isNotEmpty ? user.academyId : '5688'),
          // 3. Master -> user.name / displayName
          InfoRow(label: 'Master', value: user.name.isNotEmpty ? user.name : 'Master Kim'),
          // 4. Email -> user.email
          InfoRow(label: 'Email', value: user.email.isNotEmpty ? user.email : 'master@taekworld.com'),
          // 5. Phone -> user.phoneNumber (academy / master phone)
          InfoRow(label: 'Phone', value: _formatPhoneNumber(user.phoneNumber)),
          // 6. Status -> user.statusText / user.status
          InfoRow(
            label: 'Status',
            value: user.statusText.isNotEmpty ? user.statusText : (user.status.isNotEmpty ? user.status : 'Active'),
            valueColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  String _formatPhoneNumber(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    return raw.isNotEmpty ? raw : '(703) 760-1000';
  }
}
