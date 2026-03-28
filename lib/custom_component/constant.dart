import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (Nature + Growth)
  static const Color primary = Color(0xFF2E7D32); // Deep Green
  static const Color secondary = Color(0xFF66BB6A); // Fresh Green

  // Accent (Tech Feel)
  static const Color accent = Color(0xFF26A69A); // Teal (AI/IoT touch)

  // Background & Surface
  static const Color background = Color(
    0xFFF1F8E9,
  ); // Light greenish background
  static const Color surface = Color(0xFFFFFFFF); // Clean white

  // Text Colors
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onBackground = Color(0xFF1B5E20); // Dark green text
  static const Color onSurface = Color(0xFF1B5E20);
  static const Color textSecondary = Color(0xFF4E6E58); // Muted natural tone

  // Status Colors (Adjusted to fit nature palette)
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF9A825); // Harvest yellow
  static const Color info = Color(0xFF0288D1);
  static const Color success = Color(0xFF388E3C); // Green success

  // Border & Divider
  static const Color outline = Color(0xFFC8E6C9); // Soft green border

  // Soil / Earth Accent (optional use)
  static const Color soil = Color(0xFF8D6E63); // Brown

  // Helper method to create Material ColorScheme
  static ColorScheme get colorScheme => const ColorScheme(
    primary: primary,
    secondary: secondary,
    surface: surface,
    error: error,
    onPrimary: onPrimary,
    onSecondary: onSecondary,
    onSurface: onSurface,
    onError: Colors.white,
    brightness: Brightness.light,
  );
}
