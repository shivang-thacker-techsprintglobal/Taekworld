import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_scale.dart';
import '../../../../config/app_text_style.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/section_header.dart';
import '../../application/controllers/trial_members_controller.dart';
import '../../application/controllers/trial_members_state.dart';
import '../../domain/entities/trial_member_entity.dart';
import '../widgets/trial_member_card.dart';
import '../widgets/trial_member_detail_sheet.dart';

/// Tab 2: Trial Members Screen per UI-SPEC §4.6.
class TrialMembersScreen extends ConsumerStatefulWidget {
  const TrialMembersScreen({super.key});

  @override
  ConsumerState<TrialMembersScreen> createState() => _TrialMembersScreenState();
}

class _TrialMembersScreenState extends ConsumerState<TrialMembersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData({bool isSilent = false}) {
    final user = ref.read(currentUserProvider);
    final dojangId = user?.academyId ?? '5688';
    ref.read(trialMembersControllerProvider.notifier).loadTrialMembers(
          dojangId,
          isSilent: isSilent,
        );
  }

  Future<void> _onRefresh() async {
    final user = ref.read(currentUserProvider);
    final dojangId = user?.academyId ?? '5688';
    await ref.read(trialMembersControllerProvider.notifier).loadTrialMembers(
          dojangId,
          isSilent: true,
        );
  }

  void _openDetail(TrialMemberEntity member) {
    TrialMemberDetailSheet.show(context, member: member);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trialMembersControllerProvider);

    int newMembersCount = 0;
    if (state is TrialMembersSuccess) {
      newMembersCount = state.newMembersCount;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Trial Members',
              style: AppTextStyle.t1(
                context,
                color: Colors.white,
              ).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            if (newMembersCount > 0) ...[
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  '$newMembersCount NEW',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: () => _loadData(),
          ),
        ],
      ),
      body: state is TrialMembersLoading
          ? const Center(child: AppLoader())
          : state is TrialMembersError
              ? Center(
                  child: AppErrorView(
                    message: state.message,
                    onRetry: () => _loadData(),
                  ),
                )
              : state is TrialMembersSuccess
                  ? RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _onRefresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppScale.pagePadding(context),
                          vertical: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Summary Stats Card (7-Day, 30-Day, Total)
                            _buildSummaryCard(context, state),
                            const SizedBox(height: 20.0),

                            // 2. 7-Day Trial Members Section
                            SectionHeader(
                              title: '7-Day Trial Members',
                              underlineColor: AppColors.accentOrange,
                              underlineThickness: 2.0,
                              titleColor: AppColors.accentOrange,
                              countText: '${state.totalSevenDay}',
                              isHighlighted: state.totalSevenDay > 0,
                            ),
                            const SizedBox(height: 12.0),

                            if (state.sevenDay.isEmpty)
                              _buildEmptyCard('No new 7-day trial members')
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.sevenDay.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10.0),
                                itemBuilder: (context, index) {
                                  final member = state.sevenDay[index];
                                  return TrialMemberCard(
                                    member: member,
                                    onTap: () => _openDetail(member),
                                  );
                                },
                              ),

                            const SizedBox(height: 24.0),

                            // 3. 30-Day Trial Members Section
                            SectionHeader(
                              title: '30-Day Trial Members',
                              underlineColor: AppColors.accentGreen,
                              underlineThickness: 2.0,
                              titleColor: AppColors.accentGreen,
                              countText: '${state.totalThirtyDay}',
                              isHighlighted: state.totalThirtyDay > 0,
                            ),
                            const SizedBox(height: 12.0),

                            if (state.thirtyDay.isEmpty)
                              _buildEmptyCard('No new 30-day trial members')
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.thirtyDay.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10.0),
                                itemBuilder: (context, index) {
                                  final member = state.thirtyDay[index];
                                  return TrialMemberCard(
                                    member: member,
                                    onTap: () => _openDetail(member),
                                  );
                                },
                              ),

                            const SizedBox(height: 24.0),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
    );
  }

  Widget _buildSummaryCard(BuildContext context, TrialMembersSuccess state) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.border, width: 1.0),
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
            'New Trial Members',
            style: AppTextStyle.t1(
              context,
              color: AppColors.brandNavy,
            ).copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  label: '7-Day',
                  value: '${state.totalSevenDay}',
                  color: AppColors.accentOrange,
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.border),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  label: '30-Day',
                  value: '${state.totalThirtyDay}',
                  color: AppColors.accentGreen,
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.border),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  label: 'Total',
                  value: '${state.totalMembers}',
                  color: AppColors.brandNavy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyle.h1(
            context,
            color: color,
          ).copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          label,
          style: AppTextStyle.t3(
            context,
            color: AppColors.textSecondary,
          ).copyWith(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Center(
        child: Text(
          message,
          style: AppTextStyle.b2(
            context,
            color: AppColors.textDisabled,
          ),
        ),
      ),
    );
  }
}
