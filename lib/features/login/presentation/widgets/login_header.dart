import 'package:flutter/material.dart';

import '../../../../config/app_assets.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_size.dart';
import '../../../../config/app_text_style.dart';

/// Top header section for the login screen per UI-SPEC §4.1.
///
/// Displays the 80x80 app logo, "Taekworld Master" title (32sp bold navy),
/// and "Master Login Portal" subtitle (16sp grey).
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // App Logo (80x80 per UI-SPEC §4.1)
        // Scaled to trim outer white margins from image file
        SizedBox(
          width: 80,
          height: 80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Transform.scale(
              scale: 1.18,
              child: Image.asset(
                AppAssets.appIconAja,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.sports_martial_arts_rounded,
                  size: 44,
                  color: AppColors.brandNavy,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: AppSize.lg(context)),
        // App Name Title
        Text(
          'Taekworld Master',
          style: AppTextStyle.h1(
            context,
            color: AppColors.brandNavy,
          ).copyWith(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSize.xs(context) + 2),
        // Subtitle
        Text(
          'Master Login Portal',
          style: AppTextStyle.b1(
            context,
            color: AppColors.textSecondary,
          ).copyWith(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
