import 'package:flutter/material.dart';

enum AppThemePreference {
  system('System'),
  light('Light'),
  dark('Dark');

  const AppThemePreference(this.label);

  final String label;

  ThemeMode get themeMode {
    switch (this) {
      case AppThemePreference.system:
        return ThemeMode.system;
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.dark:
        return ThemeMode.dark;
    }
  }
}

enum AppTextSize {
  compact('Compact', 0.92),
  standard('Standard', 1.0),
  large('Large', 1.12),
  extraLarge('Extra large', 1.24);

  const AppTextSize(
    this.label,
    this.scale,
  );

  final String label;
  final double scale;
}

class AppUiPreferences {
  const AppUiPreferences({
    this.theme = AppThemePreference.system,
    this.textSize = AppTextSize.standard,
    this.hapticsEnabled = true,
    this.buttonSoundsEnabled = false,
    this.highContrast = false,
    this.onboardingCompleted = false,
  });

  final AppThemePreference theme;
  final AppTextSize textSize;
  final bool hapticsEnabled;
  final bool buttonSoundsEnabled;
  final bool highContrast;
  final bool onboardingCompleted;

  AppUiPreferences copyWith({
    AppThemePreference? theme,
    AppTextSize? textSize,
    bool? hapticsEnabled,
    bool? buttonSoundsEnabled,
    bool? highContrast,
    bool? onboardingCompleted,
  }) {
    return AppUiPreferences(
      theme: theme ?? this.theme,
      textSize: textSize ?? this.textSize,
      hapticsEnabled:
          hapticsEnabled ?? this.hapticsEnabled,
      buttonSoundsEnabled:
          buttonSoundsEnabled ?? this.buttonSoundsEnabled,
      highContrast:
          highContrast ?? this.highContrast,
      onboardingCompleted:
          onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}
