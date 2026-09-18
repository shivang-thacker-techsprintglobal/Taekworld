import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_scale.dart';
import '../../../../config/app_text_style.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../login/application/controllers/login_controller.dart';
import '../../../login/domain/entities/user_entity.dart';
import '../../../login/presentation/screens/login_screen.dart';
import '../../application/controllers/dashboard_controller.dart';
import '../widgets/dojang_info_card.dart';
import '../widgets/member_statistics_grid.dart';
import '../widgets/website_banner_card.dart';

/// Tab 0: My Dojang Dashboard Screen per UI-SPEC §4.3.
class MyDojangScreen extends ConsumerStatefulWidget {
  const MyDojangScreen({super.key});

  @override
  ConsumerState<MyDojangScreen> createState() => _MyDojangScreenState();
}

class _MyDojangScreenState extends ConsumerState<MyDojangScreen> {
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
    ref.read(dashboardControllerProvider.notifier).loadStatistics(
          dojangId,
          isSilent: isSilent,
        );
  }

  Future<void> _onRefresh() async {
    final user = ref.read(currentUserProvider);
    final dojangId = user?.academyId ?? '5688';
    await ref.read(dashboardControllerProvider.notifier).loadStatistics(
          dojangId,
          isSilent: true,
        );
  }

  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Logout',
          style: AppTextStyle.t1(ctx, color: AppColors.brandNavy),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: AppTextStyle.b2(ctx),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: AppTextStyle.t3(ctx, color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Logout',
              style: AppTextStyle.t3(ctx, color: AppColors.primary).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ref.read(currentUserProvider.notifier).state = null;
      ref.read(loginControllerProvider.notifier).reset();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final state = ref.watch(dashboardControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Dojang',
          style: AppTextStyle.t1(
            context,
            color: Colors.white,
          ).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: state.when(
        initial: () => const Center(child: AppLoader()),
        loading: () => const Center(child: AppLoader()),
        error: (message) => Center(
          child: AppErrorView(
            message: message,
            onRetry: () => _loadData(),
          ),
        ),
        success: (statistics, isRefreshing) {
          final effectiveUser = user ??
              const UserEntity(
                id: '5688',
                email: 'master@taekworld.com',
                name: 'Master Kim',
                academyId: '5688',
                academyName: 'Taekworld Academy',
                phoneNumber: '7037601000',
                status: 'Active',
                statusText: 'Active',
                role: 'master',
              );

          return RefreshIndicator(
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
                  // 1. Dojang Information Card
                  DojangInfoCard(user: effectiveUser),
                  const SizedBox(height: 16.0),

                  // 2. Website Banner Card
                  WebsiteBannerCard(phoneNumber: effectiveUser.phoneNumber),
                  const SizedBox(height: 20.0),

                  // 3. Member Statistics Grid
                  MemberStatisticsGrid(statistics: statistics),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
