import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surfaceLight,
        error: AppColors.negative,
      ),
      textTheme: AppTextStyles.textTheme(Brightness.light),
      appBarTheme: _appBarTheme(Brightness.light),
      cardTheme: _cardTheme(Brightness.light),
      elevatedButtonTheme: _elevatedButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(),
      inputDecorationTheme: _inputDecorationTheme(Brightness.light),
      dividerTheme: const DividerThemeData(space: 1, thickness: 1),
      scaffoldBackgroundColor: AppColors.backgroundLight,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surfaceDark,
        error: AppColors.negative,
      ),
      textTheme: AppTextStyles.textTheme(Brightness.dark),
      appBarTheme: _appBarTheme(Brightness.dark),
      cardTheme: _cardTheme(Brightness.dark),
      elevatedButtonTheme: _elevatedButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(),
      inputDecorationTheme: _inputDecorationTheme(Brightness.dark),
      dividerTheme: DividerThemeData(
        space: 1,
        thickness: 1,
        color: Colors.white.withValues(alpha: 0.1),
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
    );
  }

  static AppBarTheme _appBarTheme(Brightness brightness) {
    // Both light and dark themes get the dark navy app header
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: AppColors.surfaceDark, // Dark navy app header
      foregroundColor: Colors.white,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    );
  }

  static CardThemeData _cardTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      margin: EdgeInsets.zero,
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        textStyle: AppTextStyles.labelLarge,
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        textStyle: AppTextStyles.labelLarge,
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.12),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.negative),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(
        color: isDark ? Colors.white38 : Colors.black38,
        fontSize: 15,
      ),
    );
  }
}
