import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Centralized responsive scaling utility.
///
/// Responsibilities:
/// - Dimension / width scaling from a design frame
/// - Large vertical section scaling (separate from spacing/icons)
/// - Responsive text scaling that respects accessibility
/// - Border-radius scaling
/// - Minimum touch-target sizing
/// - Phone / tablet / desktop detection
/// - Maximum content width
///
/// No global [init] call is required — pass [BuildContext] where needed.
abstract final class AppScale {
  static const double designWidth = 390;
  static const double designHeight = 844;

  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 1024;

  static const double maxContentWidth = 720;
  static const double minTouchTarget = 48;

  /// Horizontal scale factor relative to [designWidth], clamped for sanity.
  static double widthFactor(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return (width / designWidth).clamp(0.85, 1.35);
  }

  /// Vertical scale for large Figma/design sections (heroes, banners).
  /// Kept separate from spacing/icon scaling.
  static double heightFactor(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return (height / designHeight).clamp(0.8, 1.25);
  }

  /// Standard dimension scaling (spacing, icons, small components).
  static double scale(BuildContext context, double value) {
    return value * widthFactor(context);
  }

  /// Scales a design-frame width value.
  static double width(BuildContext context, double value) {
    return value * widthFactor(context);
  }

  /// Scales large vertical design dimensions (heroes, illustrations).
  static double vertical(BuildContext context, double value) {
    return value * heightFactor(context);
  }

  /// Responsive text size based on screen width.
  ///
  /// Uses a moderated width factor so large phones/tablets do not
  /// inflate typography proportionally to the full screen width.
  ///
  /// Does **not** apply [MediaQuery] text scaling — Flutter's [Text]
  /// and Material widgets already respect accessibility text scale.
  static double text(BuildContext context, double fontSize) {
    final factor = widthFactor(context);
    final moderated = 1 + ((factor - 1) * 0.5);
    return fontSize * moderated;
  }

  /// Border-radius scaling with a gentle clamp.
  static double radius(BuildContext context, double value) {
    return (value * widthFactor(context)).clamp(value * 0.9, value * 1.2);
  }

  /// Ensures a size meets the minimum touch target.
  static double touchTarget(BuildContext context, double value) {
    final scaled = scale(context, value);
    return math.max(scaled, minTouchTarget);
  }

  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tabletBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktopBreakpoint;

  /// Constrains content on wide screens.
  static double contentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return math.min(width, maxContentWidth);
  }

  /// Horizontal padding that grows slightly on larger screens.
  static double pagePadding(BuildContext context) {
    if (isDesktop(context)) return 32;
    if (isTablet(context)) return 28;
    return scale(context, 20);
  }
}
