import 'package:flutter/material.dart';

import '../../config/app_colors.dart';

/// Global crash / error screen per UI-SPEC §4.8.
///
/// White page, red 48px error icon, title + subtitle, always shows Reload.
/// Uses plain [TextStyle]s so it still renders as [ErrorWidget] without Theme.
class AppCrashScreen extends StatelessWidget {
  const AppCrashScreen({
    super.key,
    required this.onRestart,
  });

  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        child: Center(
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
                const Text(
                  'Something went wrong',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please restart the app',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onRestart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Reload App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
