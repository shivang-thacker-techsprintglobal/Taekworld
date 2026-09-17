import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_size.dart';
import 'app_text_style.dart';

/// Integration layer between the design system and Flutter Material widgets.
///
/// Does **not** duplicate colors, typography, or dimensions.
/// Reuses [AppColors], [AppTextStyle], and [AppSize].
abstract final class AppTheme {
  static ThemeData light(BuildContext context) {
    final colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onPrimary,
      tertiary: AppColors.tertiary,
      error: AppColors.error,
      onError: AppColors.onPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerHighest: AppColors.surfaceVariant,
      outline: AppColors.border,
    );

    return _build(
      context: context,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackground: AppColors.background,
      dividerColor: AppColors.divider,
      inputFill: AppColors.surface,
    );
  }

  static ThemeData dark(BuildContext context) {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.primaryDark,
      onPrimary: AppColors.onPrimaryDark,
      secondary: AppColors.secondaryDark,
      onSecondary: AppColors.onPrimaryDark,
      tertiary: AppColors.tertiary,
      error: AppColors.error,
      onError: AppColors.onPrimary,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.onSurfaceDark,
      surfaceContainerHighest: AppColors.surfaceVariantDark,
      outline: AppColors.borderDark,
    );

    return _build(
      context: context,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackground: AppColors.backgroundDark,
      dividerColor: AppColors.dividerDark,
      inputFill: AppColors.surfaceDark,
    );
  }

  static ThemeData _build({
    required BuildContext context,
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required Color dividerColor,
    required Color inputFill,
  }) {
    final isDark = brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      fontFamily: AppTextStyle.fontFamily,
      dividerColor: dividerColor,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: scaffoldBackground,
        foregroundColor: textPrimary,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: AppTextStyle.t1(context, color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: Size(double.infinity, AppSize.buttonHeight(context)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSize.radiusMedium(context)),
          ),
          textStyle: AppTextStyle.l1(context, color: colorScheme.onPrimary),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: Size(double.infinity, AppSize.buttonHeight(context)),
          side: BorderSide(
            color: colorScheme.outline,
            width: AppSize.borderThin,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSize.radiusMedium(context)),
          ),
          textStyle: AppTextStyle.l1(context, color: colorScheme.primary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: AppTextStyle.l1(context, color: colorScheme.primary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSize.md(context),
          vertical: AppSize.sm(context) + 4,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.radiusMedium(context)),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.radiusMedium(context)),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.radiusMedium(context)),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: AppSize.borderMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.radiusMedium(context)),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSize.radiusMedium(context)),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: AppSize.borderMedium,
          ),
        ),
        hintStyle: AppTextStyle.b2(context, color: textSecondary),
        labelStyle: AppTextStyle.l1(context, color: textSecondary),
        errorStyle: AppTextStyle.b3(context, color: colorScheme.error),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return null;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.radiusSmall(context) / 2),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
      ),
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: AppSize.borderThin,
        space: AppSize.md(context),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.radiusDialog(context)),
        ),
        titleTextStyle: AppTextStyle.h4(context, color: textPrimary),
        contentTextStyle: AppTextStyle.b2(context, color: textSecondary),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.textPrimary,
        contentTextStyle: AppTextStyle.b2(
          context,
          color: isDark ? AppColors.textPrimaryDark : AppColors.onPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.radiusSmall(context)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
      ),
    );
  }
}
