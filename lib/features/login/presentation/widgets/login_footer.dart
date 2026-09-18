import 'package:flutter/material.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';

/// Copyright footer for the login screen.
class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        '© 2024 Taekworld. All rights reserved.',
        style: AppTextStyle.b2(
          context,
          color: AppColors.textSecondary,
        ).copyWith(
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
