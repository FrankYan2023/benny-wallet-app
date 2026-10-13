import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static const _bodyFont = 'Manrope';
  static const _displayFont = 'Sora';
  static const _titleFont = 'Plus Jakarta Sans';

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryBright,
      brightness: Brightness.light,
    );

    final bodyTextTheme = ThemeData.light().textTheme.apply(
      fontFamily: _bodyFont,
      bodyColor: AppColors.textSecondary,
      displayColor: AppColors.textPrimary,
    );
    const display = TextStyle(
      fontFamily: _displayFont,
      color: AppColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme.copyWith(
        primary: AppColors.primary,
        onPrimary: const Color(0xFFFFF0E5),
        primaryContainer: AppColors.primaryBright,
        onPrimaryContainer: const Color(0xFF4C2B00),
        secondary: AppColors.secondaryStrong,
        onSecondary: const Color(0xFFE9F4FF),
        secondaryContainer: AppColors.secondary,
        onSecondaryContainer: const Color(0xFF004C6E),
        tertiary: AppColors.tertiaryStrong,
        onTertiary: const Color(0xFFFFF1D8),
        tertiaryContainer: AppColors.tertiary,
        onTertiaryContainer: const Color(0xFF634B00),
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        outline: AppColors.outline,
        outlineVariant: AppColors.surfaceContainerHigh,
        error: AppColors.danger,
        onError: const Color(0xFFFFEFEC),
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: bodyTextTheme.copyWith(
        displayLarge: display.copyWith(
          fontSize: 40,
          height: 0.98,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
        ),
        displayMedium: display.copyWith(
          fontSize: 28,
          height: 1.04,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
        ),
        displaySmall: display.copyWith(
          fontSize: 24,
          height: 1.08,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        headlineSmall: display.copyWith(
          fontSize: 20,
          height: 1.12,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: const TextStyle(
          fontFamily: _titleFont,
          fontSize: 18,
          height: 1.12,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: const TextStyle(
          fontFamily: _displayFont,
          fontSize: 15,
          height: 1.15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        bodyLarge: const TextStyle(
          fontFamily: _bodyFont,
          fontSize: 14,
          height: 1.45,
          color: AppColors.textSecondary,
        ),
        bodyMedium: const TextStyle(
          fontFamily: _bodyFont,
          fontSize: 12,
          height: 1.4,
          color: AppColors.textSecondary,
        ),
        bodySmall: const TextStyle(
          fontFamily: _bodyFont,
          fontSize: 11,
          height: 1.35,
          color: AppColors.textSecondary,
        ),
        labelMedium: const TextStyle(
          fontFamily: _bodyFont,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.3,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontFamily: _displayFont,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        hintStyle: TextStyle(
          fontFamily: _bodyFont,
          color: AppColors.textSecondary.withValues(alpha: 0.82),
          fontSize: 13,
        ),
        labelStyle: const TextStyle(
          fontFamily: _bodyFont,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: AppColors.primaryBright.withValues(alpha: 0.45),
            width: 1.2,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: const Color(0xFFFFF0E5),
          disabledBackgroundColor: AppColors.surfaceContainer,
          disabledForegroundColor: AppColors.textSecondary,
          textStyle: const TextStyle(
            fontFamily: _displayFont,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.surface,
          side: BorderSide.none,
          textStyle: const TextStyle(
            fontFamily: _displayFont,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontFamily: _displayFont,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
      dividerColor: Colors.transparent,
      shadowColor: AppColors.shadow,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: const TextStyle(
          fontFamily: _bodyFont,
          color: AppColors.surface,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    );
  }
}
