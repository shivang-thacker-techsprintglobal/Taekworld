import 'package:flutter/material.dart';

import '../../../../config/app_size.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';

/// Email + password form fields for the login screen.
///
/// Wrapped in [RepaintBoundary] for smooth rendering with keyboard suggestions enabled.
class LoginFormFields extends StatelessWidget {
  const LoginFormFields({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    this.enabled = true,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            controller: emailController,
            label: 'Email Address',
            hint: 'Email Address',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            enableSuggestions: true,
            enabled: enabled,
            validator: Validators.email,
            useUnderlineBorder: true,
            prefixIcon: const Icon(
              Icons.mail_outline,
              color: Color(0xFF616161),
              size: 22,
            ),
          ),
          SizedBox(height: AppSize.lg(context)),
          AppTextField(
            controller: passwordController,
            label: 'Password',
            hint: 'Password',
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            enabled: enabled,
            validator: Validators.password,
            useUnderlineBorder: true,
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: Color(0xFF616161),
              size: 22,
            ),
            suffixIcon: GestureDetector(
              onTap: enabled ? onToggleObscure : null,
              behavior: HitTestBehavior.opaque,
              child: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF616161),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
