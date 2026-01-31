import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color.fromARGB(255, 10, 38, 77);
  static const Color secondary = Color.fromARGB(255, 30, 90, 160);

  // Background & Surface
  static const Color background = Color.fromARGB(255, 248, 250, 252);
  static const Color surface = Color.fromARGB(255, 255, 255, 255);

  // Text Colors
  static const Color onPrimary = Color.fromARGB(255, 255, 255, 255);
  static const Color onSecondary = Color.fromARGB(255, 255, 255, 255);
  static const Color onBackground = Color.fromARGB(255, 10, 38, 77);
  static const Color onSurface = Color.fromARGB(255, 10, 38, 77);
  static const Color textSecondary = Color.fromARGB(255, 59, 70, 87);

  // Status Colors
  static const Color error = Color.fromARGB(255, 220, 70, 70);
  static const Color warning = Color.fromARGB(255, 220, 150, 40);
  static const Color info = Color.fromARGB(255, 50, 140, 220);
  static const Color success = Color.fromARGB(255, 40, 180, 100);

  // Border & Divider
  static const Color outline = Color.fromARGB(255, 225, 230, 240);

  // Helper method to create Material ColorScheme
  static ColorScheme get colorScheme => const ColorScheme(
    primary: primary,
    secondary: secondary,
    surface: surface,
    error: error,
    onPrimary: onPrimary,
    onSecondary: onSecondary,
    onSurface: onSurface,
    onError: onPrimary,
    brightness: Brightness.light,
  );
}
