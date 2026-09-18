import 'package:flutter/material.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../domain/entities/dojang_statistics_entity.dart';

/// Member Statistics grid section per UI-SPEC §4.3.
class MemberStatisticsGrid extends StatelessWidget {
  const MemberStatisticsGrid({
    super.key,
    required this.statistics,
  });

  final DojangStatisticsEntity statistics;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Member Statistics',
          style: AppTextStyle.t1(
            context,
            color: AppColors.brandNavy,
          ).copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12.0),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Current Students',
                value: '${statistics.currentStudents}',
                accentColor: AppColors.accentBlue,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: StatCard(
                title: '7 Days Trial',
                value: '${statistics.sevenDaysTrial}',
                accentColor: AppColors.accentOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: '30 Days Trial',
                value: '${statistics.thirtyDaysTrial}',
                accentColor: AppColors.accentRed,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: StatCard(
                title: 'New Students',
                value: '${statistics.newStudents}',
                accentColor: AppColors.accentGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        SizedBox(
          width: double.infinity,
          child: StatCard(
            title: 'Recommendations',
            value: '${statistics.recommendationCount}',
            accentColor: AppColors.accentPurple,
          ),
        ),
      ],
    );
  }
}
