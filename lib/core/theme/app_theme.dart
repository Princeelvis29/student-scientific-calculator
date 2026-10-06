import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color background = Color(0xFF0F172A);
  static const Color display = Color(0xFF111827);
  static const Color numberKey = Color(0xFF1E293B);
  static const Color functionKey = Color(0xFF334155);
  static const Color border = Color(0xFF475569);
  static const Color operator = Color(0xFFB45309);
  static const Color equals = Color(0xFFF59E0B);
  static const Color danger = Color(0xFF991B1B);
  static const Color active = Color(0xFF78350F);
  static const Color primaryText = Color(0xFFF8FAFC);
  static const Color secondaryText = Color(0xFFCBD5E1);
  static const Color mutedText = Color(0xFF94A3B8);

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: equals,
        brightness: Brightness.dark,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
