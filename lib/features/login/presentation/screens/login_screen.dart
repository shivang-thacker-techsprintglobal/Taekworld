import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_scale.dart';
import '../../../../config/app_size.dart';
import '../../../../config/app_text_style.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/inline_error_box.dart';
import '../../application/controllers/login_controller.dart';
import '../../application/controllers/login_state.dart';
import '../widgets/login_footer.dart';
import '../widgets/login_form_fields.dart';
import '../widgets/login_header.dart';

/// Login form screen per UI-SPEC §4.1.
///
/// Session bootstrap / routing is handled by [AuthGate] — this screen only
/// renders the form (initial / loading / error).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'info@taekworld.com');
  final _passwordController = TextEditingController(text: 'Password123');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref.read(loginControllerProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);
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
                    const LoginHeader(),
                    const SizedBox(height: 28),
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
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                            ),
                            if (errorMessage != null) ...[
                              const SizedBox(height: 16),
                              InlineErrorBox(message: errorMessage),
                            ],
                            const SizedBox(height: 28),
                            AppButton(
                              label: 'Login',
                              isLoading: isLoading,
                              isEnabled: !isLoading,
                              backgroundColor: AppColors.primary,
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
