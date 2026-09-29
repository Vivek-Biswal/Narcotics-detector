import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTextStyles {
  static TextTheme textTheme(Brightness brightness) {
    final base = brightness == Brightness.dark ? Colors.white : Colors.black87;
    final muted = brightness == Brightness.dark
        ? const Color(0xFF8B949E)
        : const Color(0xFF6E7781);

    return GoogleFonts.interTextTheme(
      TextTheme(
        displayLarge: TextStyle(
          fontSize: 57, fontWeight: FontWeight.w700, color: base),
        displayMedium: TextStyle(
          fontSize: 45, fontWeight: FontWeight.w700, color: base),
        displaySmall: TextStyle(
          fontSize: 36, fontWeight: FontWeight.w600, color: base),
        headlineLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.w700, color: base),
        headlineMedium: TextStyle(
          fontSize: 28, fontWeight: FontWeight.w600, color: base),
        headlineSmall: TextStyle(
          fontSize: 24, fontWeight: FontWeight.w600, color: base),
        titleLarge: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w600, color: base),
        titleMedium: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w500, color: base),
        titleSmall: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, color: base),
        bodyLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w400, color: base),
        bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400, color: base),
        bodySmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w400, color: muted),
        labelLarge: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: base,
          letterSpacing: 0.3),
        labelMedium: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500, color: muted),
        labelSmall: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w500, color: muted,
          letterSpacing: 0.5),
      ),
    );
  }

  // Static helpers for common styles
  static const titleLarge = TextStyle(fontSize: 22, fontWeight: FontWeight.w600);
  static const titleMedium = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  static const labelLarge = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.3);
  static const mono = TextStyle(fontFamily: 'monospace', fontSize: 12);
}
