import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_scale.dart';
import '../../../../config/app_text_style.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/section_header.dart';
import '../../application/controllers/applications_controller.dart';
import '../../application/controllers/applications_state.dart';
import '../../domain/entities/application_item_entity.dart';
import '../widgets/application_card.dart';
import '../widgets/application_detail_sheet.dart';

/// Tab 1: Student Applications Screen per UI-SPEC §4.4.
class ApplicationsScreen extends ConsumerStatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  ConsumerState<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends ConsumerState<ApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    // UI-SPEC §4.4 — load 0.5s after mount.
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _loadData();
    });
  }

  void _loadData({bool isSilent = false}) {
    final user = ref.read(currentUserProvider);
    final dojangId = user?.academyId ?? '5688';
    ref.read(applicationsControllerProvider.notifier).loadApplications(
          dojangId,
          isSilent: isSilent,
        );
  }

  Future<void> _onRefresh() async {
    final user = ref.read(currentUserProvider);
    final dojangId = user?.academyId ?? '5688';
    await ref.read(applicationsControllerProvider.notifier).loadApplications(
          dojangId,
          isSilent: true,
        );
  }

  void _openDetail(ApplicationItemEntity item) {
    ref.read(applicationsControllerProvider.notifier).markAsViewed(item.id);
    ApplicationDetailSheet.show(
      context,
      applicationId: '${item.id}',
      initialStudentName: item.studentName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(applicationsControllerProvider);

    int unviewedCount = 0;
    if (state is ApplicationsSuccess) {
      unviewedCount = state.unviewedCount;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Student Applications',
              style: AppTextStyle.t1(
                context,
                color: Colors.white,
              ).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            if (unviewedCount > 0) ...[
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  '$unviewedCount new',
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
      body: state is ApplicationsLoading
          ? const Center(child: AppLoader())
          : state is ApplicationsError
              ? Center(
                  child: AppErrorView(
                    message: state.message,
                    onRetry: () => _loadData(),
                  ),
                )
              : state is ApplicationsSuccess
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
                            // 1. Pending Applications Section Header
                            SectionHeader(
                              title: 'Pending Applications',
                              underlineColor: AppColors.brandNavy,
                              underlineThickness: 2.0,
                              titleColor: AppColors.brandNavy,
                              titleFontSize: 20,
                              pillText: state.unviewedCount > 0
                                  ? '${state.unviewedCount} new'
                                  : null,
                              countText: '${state.unviewedCount}/${state.totalPending}',
                              isHighlighted: state.unviewedCount > 0,
                            ),
                            const SizedBox(height: 12.0),

                            // Pending List
                            if (state.pending.isEmpty)
                              _buildEmptyCard('No pending applications')
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.pending.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10.0),
                                itemBuilder: (context, index) {
                                  final item = state.pending[index];
                                  return ApplicationCard(
                                    item: item,
                                    onTap: () => _openDetail(item),
                                  );
                                },
                              ),

                            const SizedBox(height: 24.0),

                            // 2. Application History Section Header
                            SectionHeader(
                              title: 'Application History',
                              underlineColor: Colors.grey.shade300,
                              underlineThickness: 1.0,
                              titleColor: AppColors.textSecondary,
                              titleFontSize: 18,
                              countText: '${state.totalHistory}',
                              isHighlighted: false,
                            ),
                            const SizedBox(height: 12.0),

                            // History List
                            if (state.history.isEmpty)
                              _buildEmptyCard('No application history')
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.history.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10.0),
                                itemBuilder: (context, index) {
                                  final item = state.history[index];
                                  return ApplicationCard(
                                    item: item,
                                    onTap: () => _openDetail(item),
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
