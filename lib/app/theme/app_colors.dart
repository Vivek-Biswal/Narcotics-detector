import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand
  static const primary = Color(0xFF1A73E8);
  static const primaryDark = Color(0xFF1557B0);
  static const accent = Color(0xFF00BCD4);

  // Backgrounds
  static const backgroundDark = Color(0xFF0D1117);
  static const backgroundLight = Color(0xFFF5F7FA);

  // Surfaces
  static const surfaceDark = Color(0xFF161B22);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const cardDark = Color(0xFF1C2128);
  static const cardLight = Color(0xFFFFFFFF);

  // Text
  static const textDark = Color(0xFF0D1117);
  static const textLight = Color(0xFFE6EDF3);
  static const textMuted = Color(0xFF8B949E);
  static const textMutedLight = Color(0xFF6E7781);

  // Result colours (also use icon+text — never color alone)
  static const positive = Color(0xFFE53935);      // Red — dangerous
  static const positiveLight = Color(0x1AE53935);
  static const negative = Color(0xFF2E7D32);      // Green — clear
  static const negativeLight = Color(0x1A2E7D32);
  static const inconclusive = Color(0xFFF57C00);  // Amber — uncertain
  static const inconclusiveLight = Color(0x1AF57C00);

  // Status
  static const verified = Color(0xFF1A73E8);
  static const verifiedLight = Color(0x1A1A73E8);
  static const pending = Color(0xFFF57C00);
  static const pendingLight = Color(0x1AF57C00);
  static const failed = Color(0xFFE53935);
  static const failedLight = Color(0x1AE53935);

  // Warning / Info
  static const warning = Color(0xFFF57C00);
  static const info = Color(0xFF1A73E8);
  static const success = Color(0xFF2E7D32);

  // Divider
  static const dividerDark = Color(0xFF21262D);
  static const dividerLight = Color(0xFFD0D7DE);
}
