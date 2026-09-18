import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/app_text_style.dart';

/// Global crash / error screen per UI-SPEC §4.8.
class AppCrashScreen extends StatelessWidget {
  const AppCrashScreen({
    super.key,
    this.onRestart,
  });

  final VoidCallback? onRestart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: AppTextStyle.t1(
                  context,
                  color: AppColors.textPrimary,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Please restart the app',
                style: AppTextStyle.b2(
                  context,
                  color: AppColors.textSecondary,
                ),
              ),
              if (onRestart != null) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onRestart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Reload App'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
