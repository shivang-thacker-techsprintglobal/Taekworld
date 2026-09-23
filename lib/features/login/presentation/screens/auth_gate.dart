import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';
import '../../../main_shell/presentation/screens/main_shell_screen.dart';
import '../../application/controllers/login_controller.dart';
import '../../application/controllers/login_state.dart';
import 'login_screen.dart';

/// Root auth router.
///
/// Cold start shows UI-SPEC §4.1 "Checking session..." while restore runs,
/// then [MainShellScreen] or [LoginScreen].
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginControllerProvider);

    return switch (loginState) {
      LoginCheckingSession() => const _SessionCheckingScreen(),
      LoginSuccess() => const MainShellScreen(),
      _ => const LoginScreen(),
    };
  }
}

/// UI-SPEC §4.1 A — background #FAFAFA, centred navy 24px spinner,
/// "Checking session..." 16sp grey.
class _SessionCheckingScreen extends StatelessWidget {
  const _SessionCheckingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandNavy),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Checking session...',
              style: AppTextStyle.b1(
                context,
                color: AppColors.textSecondary,
              ).copyWith(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
