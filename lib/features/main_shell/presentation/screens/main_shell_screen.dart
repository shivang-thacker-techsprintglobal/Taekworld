import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/app_colors.dart';
import '../../../applications/presentation/screens/applications_screen.dart';
import '../../../dashboard/presentation/screens/my_dojang_screen.dart';
import '../../../notifications/application/controllers/notifications_controller.dart';
import '../../../notifications/application/push_notification_service.dart';
import '../../../notifications/data/repositories/notifications_repository_impl.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../notifications/presentation/widgets/notification_permission_dialog.dart';
import '../../../trial_members/presentation/screens/trial_members_screen.dart';
import '../../application/shell_providers.dart';
import '../widgets/nav_badge_icon.dart';

export '../../application/shell_providers.dart';

/// Main Shell Container Screen per UI-SPEC §3.2 & §4.2.
class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_bootstrapNotifications());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(
        ref.read(pushNotificationServiceProvider).onAppResumed(),
      );
    }
  }

  Future<void> _bootstrapNotifications() async {
    final push = ref.read(pushNotificationServiceProvider);
    await push.initialize();

    final local = ref.read(notificationsLocalDatasourceProvider);
    final asked = await local.wasPermissionPromptShown();
    if (!asked && mounted) {
      final enable = await NotificationPermissionDialog.show(context);
      await local.markPermissionPromptShown();
      if (enable == true) {
        await push.requestOsPermission();
      }
    }

    await push.registerDeviceWithBackend(force: true);
    await push.consumePendingOpenIfAny();
    await ref
        .read(notificationsControllerProvider.notifier)
        .loadNotifications(isSilent: true);
  }

  Future<void> _openBrowserUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        _showCouldNotOpenBrowser(url);
      }
    } catch (_) {
      if (mounted) {
        _showCouldNotOpenBrowser(url);
      }
    }
  }

  void _showCouldNotOpenBrowser(String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Could not open browser'),
        action: SnackBarAction(
          label: 'Copy Link',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: url));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final appBadge = ref.watch(applicationsBadgeProvider);
    final trialBadge = ref.watch(trialMembersBadgeProvider);
    final notifBadge = ref.watch(notificationsBadgeProvider);

    ref.listen<String?>(pendingBrowserOpenProvider, (previous, next) {
      if (next == null || next.isEmpty) return;
      ref.read(pendingBrowserOpenProvider.notifier).state = null;
      unawaited(_openBrowserUrl(next));
    });

    final pages = const [
      MyDojangScreen(),
      ApplicationsScreen(),
      TrialMembersScreen(),
      NotificationsScreen(),
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
              // mark-delivered only after inbox is displayed — not mark-all-read.
              unawaited(
                ref
                    .read(notificationsControllerProvider.notifier)
                    .onInboxOpened(),
              );
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
}
