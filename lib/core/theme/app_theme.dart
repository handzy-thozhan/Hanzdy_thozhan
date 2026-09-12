import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    // ==========================================================
    // COLORS
    // ==========================================================

    scaffoldBackgroundColor: AppColors.background,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.card,
      background: AppColors.background,
      onPrimary: AppColors.textOnPrimary,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
    ),

    // ==========================================================
    // APP BAR
    // ==========================================================

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),

    // ==========================================================
    // TEXT
    // ==========================================================

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),

      headlineMedium: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),

      headlineSmall: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),

      titleLarge: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),

      titleMedium: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),

      titleSmall: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),

      bodyLarge: TextStyle(
        color: AppColors.textPrimary,
      ),

      bodyMedium: TextStyle(
        color: AppColors.textSecondary,
      ),

      bodySmall: TextStyle(
        color: AppColors.textSecondary,
      ),

      labelLarge: TextStyle(
        color: AppColors.textOnPrimary,
        fontWeight: FontWeight.w600,
      ),

      labelMedium: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),

      labelSmall: TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    ),

    // ==========================================================
    // ELEVATED BUTTON
    // ==========================================================

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,

        minimumSize: const Size(
          double.infinity,
          54,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),

        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),

        overlayColor: AppColors.secondary,
      ),
    ),

    // ==========================================================
    // OUTLINED BUTTON
    // ==========================================================

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,

        minimumSize: const Size(
          double.infinity,
          54,
        ),

        side: const BorderSide(
          color: AppColors.primary,
          width: 1.3,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),

        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ==========================================================
    // TEXT BUTTON
    // ==========================================================

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,

        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ==========================================================
    // INPUT FIELDS
    // ==========================================================

    inputDecorationTheme: InputDecorationTheme(
      filled: true,

      fillColor: AppColors.card,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),

      hintStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
      ),

      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
      ),

      prefixIconColor: AppColors.primary,

      suffixIconColor: AppColors.primary,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),

        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),

        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),

        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),

        borderSide: const BorderSide(
          color: AppColors.error,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),

        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
    ),

    // ==========================================================
    // CARD
    // ==========================================================

    cardTheme: CardThemeData(
      color: AppColors.card,

      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),

        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
    ),

    // ==========================================================
    // ICON THEME
    // ==========================================================

    iconTheme: const IconThemeData(
      color: AppColors.primary,
      size: 24,
    ),

    // ==========================================================
    // DIVIDER
    // ==========================================================

    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),

    // ==========================================================
    // SWITCH
    // ==========================================================

    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }

          return AppColors.textSecondary;
        },
      ),

      trackColor: MaterialStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.secondary;
          }

          return AppColors.border;
        },
      ),

      trackOutlineColor: MaterialStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }

          return AppColors.border;
        },
      ),
    ),

    // ==========================================================
    // BOTTOM NAVIGATION BAR
    // ==========================================================

    bottomNavigationBarTheme:
        const BottomNavigationBarThemeData(
      backgroundColor: AppColors.card,

      selectedItemColor: AppColors.primary,

      unselectedItemColor: AppColors.textSecondary,

      type: BottomNavigationBarType.fixed,

      elevation: 0,

      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),

      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),

    // ==========================================================
    // PROGRESS INDICATOR
    // ==========================================================

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.lightTeal,
      circularTrackColor: AppColors.lightTeal,
    ),

    // ==========================================================
    // CHECKBOX
    // ==========================================================

    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }

          return AppColors.card;
        },
      ),

      checkColor: const MaterialStatePropertyAll<Color>(
        AppColors.textOnPrimary,
      ),

      side: const BorderSide(
        color: AppColors.border,
        width: 1.5,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    ),

    // ==========================================================
    // RADIO BUTTON
    // ==========================================================

    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }

          return AppColors.textSecondary;
        },
      ),
    ),
  );
}