import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_scale.dart';
import '../../../../config/app_size.dart';
import '../../../../config/app_text_style.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/inline_error_box.dart';
import '../../application/controllers/login_controller.dart';
import '../../application/controllers/login_state.dart';
import '../widgets/login_footer.dart';
import '../widgets/login_form_fields.dart';
import '../widgets/login_header.dart';

/// Pixel-accurate & fully responsive Login Screen per UI-SPEC §4.1.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    // Trigger inline validation errors for empty or invalid fields
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref.read(loginControllerProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LoginState>(loginControllerProvider, (previous, next) {
      next.whenOrNull(
        success: (user) {
          context.showSnackBar('Welcome, ${user.name}');
        },
      );
    });

    final loginState = ref.watch(loginControllerProvider);

    if (loginState is LoginCheckingSession) {
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

    final isLoading = loginState is LoginLoading;
    final errorMessage = loginState is LoginError ? loginState.message : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: AppScale.pagePadding(context),
              vertical: AppSize.lg(context),
            ),
            child: Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 400,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    // Header (Logo + Title + Subtitle)
                    const LoginHeader(),

                    const SizedBox(height: 28),

                    // Card Container (Form Card)
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.border,
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            LoginFormFields(
                              emailController: _emailController,
                              passwordController: _passwordController,
                              obscurePassword: _obscurePassword,
                              enabled: !isLoading,
                              onToggleObscure: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),

                            if (errorMessage != null) ...[
                              const SizedBox(height: 16),
                              InlineErrorBox(message: errorMessage),
                            ],

                            const SizedBox(height: 28),

                            // Red Login Button (Radius 8, 18sp bold white text)
                            AppButton(
                              label: 'Login',
                              isLoading: isLoading,
                              isEnabled: !isLoading,
                              backgroundColor: AppColors.primary, // #B00000
                              borderRadius: 8.0,
                              textStyle: AppTextStyle.b1(
                                context,
                                color: AppColors.onPrimary,
                              ).copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              onPressed: _onSubmit,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Footer Copyright Text
                    const LoginFooter(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
