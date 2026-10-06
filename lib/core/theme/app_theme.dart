import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // =====================================================
      // BASIC THEME
      // =====================================================

      brightness: Brightness.light,
      fontFamily: 'Roboto',

      // Home / normal page background
      scaffoldBackgroundColor: AppColors.background,

      splashColor: AppColors.primary.withValues(alpha: 0.08),
      highlightColor: AppColors.primary.withValues(alpha: 0.04),

      // =====================================================
      // COLOR SCHEME
      // =====================================================

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,

        secondary: AppColors.secondary,
        onSecondary: AppColors.textOnPrimary,

        error: AppColors.error,
        onError: AppColors.textOnPrimary,

        surface: AppColors.card,
        onSurface: AppColors.textPrimary,

        outline: AppColors.border,
      ),

      // =====================================================
      // APP BAR THEME
      // =====================================================

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.header,
        foregroundColor: AppColors.textOnPrimary,

        elevation: 0,
        scrolledUnderElevation: 0,

        centerTitle: false,

        titleTextStyle: TextStyle(
          color: AppColors.textOnPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),

        iconTheme: IconThemeData(
          color: AppColors.textOnPrimary,
          size: 24,
        ),
      ),

      // =====================================================
      // TEXT THEME
      // =====================================================

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),

        displayMedium: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),

        displaySmall: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),

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
          fontWeight: FontWeight.w400,
        ),

        bodyMedium: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w400,
        ),

        bodySmall: TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w400,
        ),

        labelLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),

        labelMedium: TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),

        labelSmall: TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),

      // =====================================================
      // ELEVATED BUTTON THEME
      // =====================================================

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,

          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textSecondary,

          elevation: 0,

          minimumSize: const Size(0, 50),

          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 14,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // =====================================================
      // FILLED BUTTON THEME
      // =====================================================

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,

          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textSecondary,

          minimumSize: const Size(0, 50),

          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 14,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // =====================================================
      // OUTLINED BUTTON THEME
      // =====================================================

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,

          minimumSize: const Size(0, 50),

          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 14,
          ),

          side: const BorderSide(
            color: AppColors.primary,
            width: 1.2,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // =====================================================
      // TEXT BUTTON THEME
      // =====================================================

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,

          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      // =====================================================
      // INPUT DECORATION THEME
      // =====================================================

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
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

        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),

        prefixIconColor: AppColors.darkIcon,
        suffixIconColor: AppColors.darkIcon,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),

        errorStyle: const TextStyle(
          color: AppColors.error,
          fontSize: 12,
        ),
      ),

      // =====================================================
      // CARD THEME
      // =====================================================

      cardTheme: CardThemeData(
        color: AppColors.card,
        surfaceTintColor: AppColors.card,

        elevation: 0,

        margin: EdgeInsets.zero,

        shadowColor: AppColors.shadow,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),

          side: const BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),

      // =====================================================
      // ICON THEME
      // =====================================================

      iconTheme: const IconThemeData(
        color: AppColors.darkIcon,
        size: 24,
      ),

      // =====================================================
      // DIVIDER THEME
      // =====================================================

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // =====================================================
      // BOTTOM NAVIGATION BAR
      // =====================================================

      bottomNavigationBarTheme:
          const BottomNavigationBarThemeData(
        backgroundColor: AppColors.card,

        selectedItemColor: AppColors.bottomActive,
        unselectedItemColor: AppColors.textSecondary,

        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),

        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),

        type: BottomNavigationBarType.fixed,

        elevation: 0,
      ),

      // =====================================================
      // NAVIGATION BAR - MATERIAL 3
      // =====================================================

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.card,

        indicatorColor:
            AppColors.bottomActive.withValues(
          alpha: 0.12,
        ),

        surfaceTintColor: AppColors.card,

        elevation: 0,

        labelTextStyle:
            WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return const TextStyle(
                color: AppColors.bottomActive,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              );
            }

            return const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            );
          },
        ),

        iconTheme:
            WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return const IconThemeData(
                color: AppColors.bottomActive,
                size: 24,
              );
            }

            return const IconThemeData(
              color: AppColors.darkIcon,
              size: 24,
            );
          },
        ),
      ),

      // =====================================================
      // CHECKBOX THEME
      // =====================================================

      checkboxTheme: CheckboxThemeData(
        fillColor:
            WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return AppColors.primary;
            }

            return AppColors.card;
          },
        ),

        checkColor: WidgetStateProperty.all(
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

      // =====================================================
      // RADIO THEME
      // =====================================================

      radioTheme: RadioThemeData(
        fillColor:
            WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return AppColors.primary;
            }

            return AppColors.textSecondary;
          },
        ),
      ),

      // =====================================================
      // SWITCH THEME
      // =====================================================

      switchTheme: SwitchThemeData(
        thumbColor:
            WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return AppColors.onlineToggle;
            }

            return AppColors.textSecondary;
          },
        ),

        trackColor:
            WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return AppColors.onlineToggle
                  .withValues(alpha: 0.35);
            }

            return AppColors.border;
          },
        ),

        trackOutlineColor:
            WidgetStateProperty.all(
          AppColors.border,
        ),
      ),

      // =====================================================
      // PROGRESS INDICATOR THEME
      // =====================================================

      progressIndicatorTheme:
          const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.border,
        circularTrackColor: AppColors.border,
      ),

      // =====================================================
      // SNACKBAR THEME
      // =====================================================

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkTeal,

        contentTextStyle: const TextStyle(
          color: AppColors.textOnPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),

        actionTextColor: AppColors.lightMint,

        behavior: SnackBarBehavior.floating,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      // =====================================================
      // DIALOG THEME
      // =====================================================

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: AppColors.card,

        elevation: 0,

        shadowColor: AppColors.shadow,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),

        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),

        contentTextStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),

      // =====================================================
      // BOTTOM SHEET THEME
      // =====================================================

      bottomSheetTheme:
          const BottomSheetThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: AppColors.card,

        modalBackgroundColor: AppColors.card,

        showDragHandle: true,

        dragHandleColor: AppColors.border,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
      ),

      // =====================================================
      // TOOLTIP THEME
      // =====================================================

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.darkTeal,
          borderRadius: BorderRadius.circular(8),
        ),

        textStyle: const TextStyle(
          color: AppColors.textOnPrimary,
          fontSize: 12,
        ),
      ),
    );
  }
}