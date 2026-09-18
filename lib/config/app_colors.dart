import 'package:flutter/material.dart';

/// Single source of truth for application colors.
///
/// Use semantic names in UI — never scatter raw [Color] values
/// for design-system colors inside feature widgets.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFFB00000); // Brand red (kRed)
  static const Color brandNavy = Color(0xFF001A57); // Brand navy (kBlue)
  static const Color secondary = Color(0xFF001A57);
  static const Color tertiary = Color(0xFFFF9800);

  // Surfaces
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Text / icons
  static const Color textPrimary = Color(0xFF1A1C1B);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFF9AA39E);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1C1B);

  // Feedback & Inline Error
  static const Color error = Color(0xFFD32F2F);
  static const Color errorBackground = Color(0xFFFFEBEE);
  static const Color errorBorder = Color(0xFFEF9A9A);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Borders / dividers
  static const Color border = Color(0xFFEEEEEE);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color overlay = Color(0x801A1C1B);

  // Dark theme counterparts
  static const Color primaryDark = Color(0xFFB00000);
  static const Color secondaryDark = Color(0xFF001A57);
  static const Color backgroundDark = Color(0xFF121412);
  static const Color surfaceDark = Color(0xFF1C1F1D);
  static const Color surfaceVariantDark = Color(0xFF262A28);
  static const Color textPrimaryDark = Color(0xFFF2F5F3);
  static const Color textSecondaryDark = Color(0xFFB0B8B3);
  static const Color onPrimaryDark = Color(0xFFFFFFFF);
  static const Color onSurfaceDark = Color(0xFFF2F5F3);
  static const Color borderDark = Color(0xFF3A403C);
  static const Color dividerDark = Color(0xFF2E3330);
}
