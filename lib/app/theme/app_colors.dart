import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand
  static const primary = Color(0xFF1976D2); // Blue primary actions
  static const primaryDark = Color(0xFF0D47A1);
  static const accent = Color(0xFF00BCD4);

  // Backgrounds
  static const backgroundDark = Color(0xFF041225); // Dark navy primary theme
  static const backgroundLight = Color(0xFFF3F4F6); // Light gray/white background

  // Surfaces
  static const surfaceDark = Color(0xFF081F40); // Slightly lighter navy for app bars
  static const surfaceLight = Color(0xFFFFFFFF);
  static const cardDark = Color(0xFF0D2A53); // Cards on dark theme
  static const cardLight = Color(0xFFFFFFFF); // White/light cards

  // Text
  static const textDark = Color(0xFF111827); // Dark text for light mode
  static const textLight = Color(0xFFF9FAFB); // Light text for dark mode
  static const textMuted = Color(0xFF9CA3AF);
  static const textMutedLight = Color(0xFF6B7280);

  // Result colours (also use icon+text — never color alone)
  static const positive = Color(0xFFDC2626);      // Red — dangerous
  static const positiveLight = Color(0x1ADC2626);
  static const negative = Color(0xFF16A34A);      // Green — clear
  static const negativeLight = Color(0x1A16A34A);
  static const inconclusive = Color(0xFFD97706);  // Amber — uncertain
  static const inconclusiveLight = Color(0x1AD97706);

  // Status
  static const verified = Color(0xFF16A34A);      // Green success/verified states
  static const verifiedLight = Color(0x1A16A34A);
  static const pending = Color(0xFFD97706);
  static const pendingLight = Color(0x1AD97706);
  static const failed = Color(0xFFDC2626);        // Red positive/tampered states
  static const failedLight = Color(0x1ADC2626);

  // Warning / Info
  static const warning = Color(0xFFD97706);
  static const info = Color(0xFF1976D2);
  static const success = Color(0xFF16A34A);

  // Divider
  static const dividerDark = Color(0xFF1E3A8A);
  static const dividerLight = Color(0xFFE5E7EB);
}
