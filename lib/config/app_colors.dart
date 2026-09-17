import 'package:flutter/material.dart';

/// Single source of truth for application colors.
///
/// Use semantic names in UI — never scatter raw [Color] values
/// for design-system colors inside feature widgets.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF1B4D3E);
  static const Color secondary = Color(0xFF2D6A4F);
  static const Color tertiary = Color(0xFF52B788);

  // Surfaces
  static const Color background = Color(0xFFF7F9F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEF3F0);

  // Text / icons
  static const Color textPrimary = Color(0xFF1A1C1B);
  static const Color textSecondary = Color(0xFF5C635F);
  static const Color textDisabled = Color(0xFF9AA39E);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1C1B);

  // Feedback
  static const Color error = Color(0xFFB3261E);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFE65100);
  static const Color info = Color(0xFF1565C0);

  // Borders / dividers
  static const Color border = Color(0xFFD5DDD8);
  static const Color divider = Color(0xFFE3E9E5);
  static const Color overlay = Color(0x801A1C1B);

  // Dark theme counterparts
  static const Color primaryDark = Color(0xFF52B788);
  static const Color secondaryDark = Color(0xFF74C69D);
  static const Color backgroundDark = Color(0xFF121412);
  static const Color surfaceDark = Color(0xFF1C1F1D);
  static const Color surfaceVariantDark = Color(0xFF262A28);
  static const Color textPrimaryDark = Color(0xFFF2F5F3);
  static const Color textSecondaryDark = Color(0xFFB0B8B3);
  static const Color onPrimaryDark = Color(0xFF003822);
  static const Color onSurfaceDark = Color(0xFFF2F5F3);
  static const Color borderDark = Color(0xFF3A403C);
  static const Color dividerDark = Color(0xFF2E3330);
}
