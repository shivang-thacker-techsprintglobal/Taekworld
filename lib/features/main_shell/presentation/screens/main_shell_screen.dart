import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';
import '../../../dashboard/presentation/screens/my_dojang_screen.dart';
import '../widgets/nav_badge_icon.dart';

/// Main Shell Navigation Provider (current active tab index)
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// Badge counts providers for tabs
final applicationsBadgeProvider = StateProvider<int>((ref) => 0);
final trialMembersBadgeProvider = StateProvider<int>((ref) => 0);
final notificationsBadgeProvider = StateProvider<int>((ref) => 0);

/// Main Shell Container Screen per UI-SPEC §3.2 & §4.2.
class MainShellScreen extends ConsumerWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final appBadge = ref.watch(applicationsBadgeProvider);
    final trialBadge = ref.watch(trialMembersBadgeProvider);
    final notifBadge = ref.watch(notificationsBadgeProvider);

    final pages = [
      const MyDojangScreen(),
      _buildTabPlaceholder(
        context,
        title: 'Student Applications',
        icon: Icons.school_outlined,
        label: 'Applications Tab',
      ),
      _buildTabPlaceholder(
        context,
        title: 'Trial Members',
        icon: Icons.people_outline,
        label: 'Trial Members Tab',
      ),
      _buildTabPlaceholder(
        context,
        title: 'Notifications',
        icon: Icons.notifications_outlined,
        label: 'Notifications Tab',
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            ref.read(bottomNavIndexProvider.notifier).state = index;
            if (index == 3) {
              // Clear notification badge when opened per UI-SPEC §3.2
              ref.read(notificationsBadgeProvider.notifier).state = 0;
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'My Dojang',
            ),
            BottomNavigationBarItem(
              icon: NavBadgeIcon(
                icon: const Icon(Icons.school_outlined),
                badgeCount: appBadge,
                badgeColor: AppColors.primary,
              ),
              activeIcon: NavBadgeIcon(
                icon: const Icon(Icons.school),
                badgeCount: appBadge,
                badgeColor: AppColors.primary,
              ),
              label: 'Applications',
            ),
            BottomNavigationBarItem(
              icon: NavBadgeIcon(
                icon: const Icon(Icons.people_outline),
                badgeCount: trialBadge,
                badgeColor: AppColors.accentBlue,
              ),
              activeIcon: NavBadgeIcon(
                icon: const Icon(Icons.people),
                badgeCount: trialBadge,
                badgeColor: AppColors.accentBlue,
              ),
              label: 'Trial Members',
            ),
            BottomNavigationBarItem(
              icon: NavBadgeIcon(
                icon: const Icon(Icons.notifications_outlined),
                badgeCount: notifBadge,
                badgeColor: AppColors.primary,
              ),
              activeIcon: NavBadgeIcon(
                icon: const Icon(Icons.notifications),
                badgeCount: notifBadge,
                badgeColor: AppColors.primary,
              ),
              label: 'Notifications',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPlaceholder(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String label,
  }) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          title,
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
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: AppTextStyle.t2(
                context,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
