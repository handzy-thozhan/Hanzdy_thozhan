import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    // ==========================================================
    // COLORS
    // ==========================================================

    scaffoldBackgroundColor:
        AppColors.background,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,

      primary: AppColors.primary,
      secondary: AppColors.secondary,

      surface: AppColors.background,
    ),

    // ==========================================================
    // APP BAR
    // ==========================================================

    appBarTheme: const AppBarTheme(
      backgroundColor:
          AppColors.background,

      foregroundColor:
          AppColors.textPrimary,

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

      titleLarge: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),

      titleMedium: TextStyle(
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
    ),

    // ==========================================================
    // ELEVATED BUTTON
    // ==========================================================

    elevatedButtonTheme:
        ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            AppColors.primary,

        foregroundColor:
            AppColors.textOnPrimary,

        elevation: 0,

        minimumSize:
            const Size(
          double.infinity,
          54,
        ),

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),

        textStyle:
            const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ==========================================================
    // OUTLINED BUTTON
    // ==========================================================

    outlinedButtonTheme:
        OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor:
            AppColors.primary,

        minimumSize:
            const Size(
          double.infinity,
          54,
        ),

        side:
            const BorderSide(
          color:
              AppColors.primary,
        ),

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),
      ),
    ),

    // ==========================================================
    // INPUT FIELDS
    // ==========================================================

    inputDecorationTheme:
        InputDecorationTheme(
      filled: true,

      fillColor:
          AppColors.background,

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),

      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),

        borderSide:
            const BorderSide(
          color:
              AppColors.border,
        ),
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),

        borderSide:
            const BorderSide(
          color:
              AppColors.border,
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),

        borderSide:
            const BorderSide(
          color:
              AppColors.primary,
          width: 2,
        ),
      ),
    ),

    // ==========================================================
    // CARD
    // ==========================================================

    cardTheme:
        CardThemeData(
      color:
          AppColors.card,

      elevation: 0,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),

        side:
            const BorderSide(
          color:
              AppColors.border,
        ),
      ),
    ),
  );
}
