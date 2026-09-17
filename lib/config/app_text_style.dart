import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_scale.dart';

/// Centralized typography system.
///
/// Prefer semantic styles ([h1], [t1], [b1], [l1], …) over ad-hoc [TextStyle]
/// objects in screens and widgets. All sizing goes through [AppScale].
abstract final class AppTextStyle {
  /// Default font family. Override when custom fonts are added to pubspec.
  static const String fontFamily = 'Roboto';

  static TextStyle _base(
    BuildContext context, {
    required double size,
    required FontWeight weight,
    Color? color,
    double height = 1.3,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: AppScale.text(context, size),
      fontWeight: weight,
      color: color ?? AppColors.textPrimary,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // ---------------------------------------------------------------------------
  // Headings
  // ---------------------------------------------------------------------------

  static TextStyle h1(BuildContext context, {Color? color}) => _base(
        context,
        size: 32,
        weight: FontWeight.w700,
        height: 1.2,
        color: color,
      );

  static TextStyle h2(BuildContext context, {Color? color}) => _base(
        context,
        size: 28,
        weight: FontWeight.w700,
        height: 1.25,
        color: color,
      );

  static TextStyle h3(BuildContext context, {Color? color}) => _base(
        context,
        size: 24,
        weight: FontWeight.w600,
        height: 1.25,
        color: color,
      );

  static TextStyle h4(BuildContext context, {Color? color}) => _base(
        context,
        size: 20,
        weight: FontWeight.w600,
        height: 1.3,
        color: color,
      );

  // ---------------------------------------------------------------------------
  // Titles
  // ---------------------------------------------------------------------------

  static TextStyle t1(BuildContext context, {Color? color}) => _base(
        context,
        size: 18,
        weight: FontWeight.w600,
        color: color,
      );

  static TextStyle t2(BuildContext context, {Color? color}) => _base(
        context,
        size: 16,
        weight: FontWeight.w600,
        color: color,
      );

  static TextStyle t3(BuildContext context, {Color? color}) => _base(
        context,
        size: 14,
        weight: FontWeight.w600,
        color: color,
      );

  static TextStyle t4(BuildContext context, {Color? color}) => _base(
        context,
        size: 12,
        weight: FontWeight.w600,
        color: color,
      );

  // ---------------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------------

  static TextStyle b1(BuildContext context, {Color? color}) => _base(
        context,
        size: 16,
        weight: FontWeight.w400,
        color: color,
      );

  static TextStyle b2(BuildContext context, {Color? color}) => _base(
        context,
        size: 14,
        weight: FontWeight.w400,
        color: color,
      );

  static TextStyle b3(BuildContext context, {Color? color}) => _base(
        context,
        size: 12,
        weight: FontWeight.w400,
        color: color,
      );

  static TextStyle b4(BuildContext context, {Color? color}) => _base(
        context,
        size: 10,
        weight: FontWeight.w400,
        color: color,
      );

  // ---------------------------------------------------------------------------
  // Labels
  // ---------------------------------------------------------------------------

  static TextStyle l1(BuildContext context, {Color? color}) => _base(
        context,
        size: 14,
        weight: FontWeight.w500,
        letterSpacing: 0.1,
        color: color,
      );

  static TextStyle l2(BuildContext context, {Color? color}) => _base(
        context,
        size: 12,
        weight: FontWeight.w500,
        letterSpacing: 0.2,
        color: color,
      );

  static TextStyle l3(BuildContext context, {Color? color}) => _base(
        context,
        size: 11,
        weight: FontWeight.w500,
        letterSpacing: 0.3,
        color: color,
      );

  static TextStyle l4(BuildContext context, {Color? color}) => _base(
        context,
        size: 10,
        weight: FontWeight.w500,
        letterSpacing: 0.4,
        color: color,
      );
}
