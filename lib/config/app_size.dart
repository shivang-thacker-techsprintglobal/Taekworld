import 'package:flutter/material.dart';

import 'app_scale.dart';

/// Centralized design tokens for commonly used dimensions.
///
/// Values use [AppScale] when responsive scaling is appropriate.
/// Keep this a clean token system — do not add a token for every
/// arbitrary measurement used in a single screen.
abstract final class AppSize {
  // ---------------------------------------------------------------------------
  // Spacing
  // ---------------------------------------------------------------------------

  static double xs(BuildContext context) => AppScale.scale(context, 4);
  static double sm(BuildContext context) => AppScale.scale(context, 8);
  static double md(BuildContext context) => AppScale.scale(context, 16);
  static double lg(BuildContext context) => AppScale.scale(context, 24);
  static double xl(BuildContext context) => AppScale.scale(context, 32);
  static double xxl(BuildContext context) => AppScale.scale(context, 48);

  // ---------------------------------------------------------------------------
  // Radius
  // ---------------------------------------------------------------------------

  static double radiusSmall(BuildContext context) =>
      AppScale.radius(context, 8);
  static double radiusMedium(BuildContext context) =>
      AppScale.radius(context, 12);
  static double radiusLarge(BuildContext context) =>
      AppScale.radius(context, 16);
  static double radiusDialog(BuildContext context) =>
      AppScale.radius(context, 20);
  static double radiusFull(BuildContext context) =>
      AppScale.radius(context, 999);

  // ---------------------------------------------------------------------------
  // Icons
  // ---------------------------------------------------------------------------

  static double iconXs(BuildContext context) => AppScale.scale(context, 12);
  static double iconSmall(BuildContext context) => AppScale.scale(context, 16);
  static double iconMedium(BuildContext context) => AppScale.scale(context, 24);
  static double iconLarge(BuildContext context) => AppScale.scale(context, 32);

  // ---------------------------------------------------------------------------
  // Common components
  // ---------------------------------------------------------------------------

  static double buttonHeight(BuildContext context) =>
      AppScale.touchTarget(context, 48);
  static double inputHeight(BuildContext context) =>
      AppScale.touchTarget(context, 52);
  static double appBarHeight(BuildContext context) =>
      AppScale.scale(context, 56);

  // ---------------------------------------------------------------------------
  // Border widths (fixed tokens — do not scale)
  // ---------------------------------------------------------------------------

  static const double borderThin = 1;
  static const double borderMedium = 1.5;
  static const double borderThick = 2;
}
