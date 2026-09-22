import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/app_assets.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../main_shell/presentation/screens/main_shell_screen.dart';
import '../../application/controllers/login_controller.dart';
import '../../application/controllers/login_state.dart';
import 'login_screen.dart';

/// Root auth router.
///
/// 1. Branded splash (fade-in, min [AppConstants.splashMinDuration])
/// 2. "Checking session..." while restore is still running
/// 3. [MainShellScreen] or [LoginScreen]
class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  bool _minDurationElapsed = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: AppConstants.splashFadeInDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    Future<void>.delayed(AppConstants.splashMinDuration, () {
      if (mounted) {
        setState(() => _minDurationElapsed = true);
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);

    if (!_minDurationElapsed) {
      return _SplashScreen(fadeAnimation: _fadeAnimation);
    }

    return switch (loginState) {
      LoginCheckingSession() => const _SessionCheckingScreen(),
      LoginSuccess() => const MainShellScreen(),
      _ => const LoginScreen(),
    };
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen({required this.fadeAnimation});

  final Animation<double> fadeAnimation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: fadeAnimation,
          child: Image.asset(
            AppAssets.splashAjaLogo,
            width: 180,
            height: 180,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                AppAssets.appIconAja,
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              );
            },
          ),
        ),
      ),
    );
  }
}

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
