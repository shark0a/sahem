import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary Brand
  static const Color primary = Color(0xFFF4A226);
  static const Color primaryLight = Color(0xFFFFF8EE);
  static const Color primaryShadow = Color(0x4DF4A226); // 30% opacity

  // Background
  static const Color background = Color(0xFFFAFAF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F3F5);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFD4183D);
  static const Color warning = Color(0xFFF4A226);
  static const Color info = Color(0xFF3B82F6);

  // Favorites
  static const Color heartActive = Color(0xFFEF4444);
  static const Color heartInactive = Color(0xFF374151);

  // Gradient
  static const List<Color> headerGradient = [
    Color(0xFFFFF8EE),
    Color(0xFFFFFFFF),
  ];

  // Card
  static const Color cardShadow = Color(0x14000000); // 8% black
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Dark theme
  static const Color darkBackground = Color(0xFF0F0F0F);
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2E);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFF8E8E93);

  // Offline banner
  static const Color offlineBg = Color(0xFFEF4444);
  static const Color onlineBg = Color(0xFF22C55E);
}
