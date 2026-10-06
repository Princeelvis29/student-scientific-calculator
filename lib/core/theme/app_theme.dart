import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Branded calculator surfaces intentionally stay high-contrast
  // in both app themes.
  static const Color background =
      Color(0xFF0F172A);
  static const Color display =
      Color(0xFF111827);
  static const Color numberKey =
      Color(0xFF1E293B);
  static const Color functionKey =
      Color(0xFF334155);
  static const Color border =
      Color(0xFF475569);
  static const Color operator =
      Color(0xFFB45309);
  static const Color equals =
      Color(0xFFF59E0B);
  static const Color danger =
      Color(0xFF991B1B);
  static const Color active =
      Color(0xFF78350F);
  static const Color primaryText =
      Color(0xFFF8FAFC);
  static const Color secondaryText =
      Color(0xFFCBD5E1);
  static const Color mutedText =
      Color(0xFF94A3B8);

  static ThemeData dark({
    bool highContrast = false,
  }) {
    final ColorScheme scheme =
        ColorScheme.fromSeed(
      seedColor: equals,
      brightness: Brightness.dark,
      surface:
          highContrast
              ? const Color(0xFF050A12)
              : background,
    );

    return _base(
      scheme: scheme,
      scaffold:
          highContrast
              ? const Color(0xFF030712)
              : background,
      highContrast: highContrast,
    );
  }

  static ThemeData light({
    bool highContrast = false,
  }) {
    final ColorScheme scheme =
        ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: Brightness.light,
      surface:
          highContrast
              ? Colors.white
              : const Color(0xFFF8FAFC),
    );

    return _base(
      scheme: scheme,
      scaffold:
          highContrast
              ? Colors.white
              : const Color(0xFFF1F5F9),
      highContrast: highContrast,
    );
  }

  static ThemeData _base({
    required ColorScheme scheme,
    required Color scaffold,
    required bool highContrast,
  }) {
    return ThemeData(
      brightness: scheme.brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: scaffold,
      colorScheme: scheme,
      visualDensity:
          VisualDensity.standard,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scaffold,
        foregroundColor:
            scheme.onSurface,
        surfaceTintColor:
            Colors.transparent,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,
        fillColor:
            scheme.surfaceContainerHighest
                .withOpacity(
          scheme.brightness ==
                  Brightness.dark
              ? 0.24
              : 0.45,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: BorderSide(
            color: highContrast
                ? scheme.outline
                : scheme
                    .outlineVariant,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(18),
          side: BorderSide(
            color: scheme.outlineVariant,
          ),
        ),
      ),
      filledButtonTheme:
          FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize:
              const Size(44, 46),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme:
          OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize:
              const Size(44, 46),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),
      ),
      iconButtonTheme:
          IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize:
              const Size(44, 44),
        ),
      ),
      snackBarTheme:
          const SnackBarThemeData(
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }
}
