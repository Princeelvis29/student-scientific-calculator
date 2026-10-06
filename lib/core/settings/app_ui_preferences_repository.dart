import 'package:shared_preferences/shared_preferences.dart';

import 'app_ui_preferences.dart';

class AppUiPreferencesRepository {
  static const String _themeKey = 'ui_theme_v1';
  static const String _textSizeKey = 'ui_text_size_v1';
  static const String _hapticsKey = 'ui_haptics_v1';
  static const String _soundsKey = 'ui_button_sounds_v1';
  static const String _contrastKey = 'ui_high_contrast_v1';
  static const String _onboardingKey = 'ui_onboarding_completed_v1';

  Future<AppUiPreferences> load() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    AppThemePreference theme =
        AppThemePreference.system;

    final String? storedTheme =
        prefs.getString(_themeKey);

    if (storedTheme != null) {
      theme = AppThemePreference.values.firstWhere(
        (AppThemePreference item) =>
            item.name == storedTheme,
        orElse: () => AppThemePreference.system,
      );
    }

    AppTextSize textSize =
        AppTextSize.standard;

    final String? storedSize =
        prefs.getString(_textSizeKey);

    if (storedSize != null) {
      textSize = AppTextSize.values.firstWhere(
        (AppTextSize item) =>
            item.name == storedSize,
        orElse: () => AppTextSize.standard,
      );
    }

    return AppUiPreferences(
      theme: theme,
      textSize: textSize,
      hapticsEnabled:
          prefs.getBool(_hapticsKey) ?? true,
      buttonSoundsEnabled:
          prefs.getBool(_soundsKey) ?? false,
      highContrast:
          prefs.getBool(_contrastKey) ?? false,
      onboardingCompleted:
          prefs.getBool(_onboardingKey) ?? false,
    );
  }

  Future<void> save(
    AppUiPreferences value,
  ) async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await Future.wait(<Future<bool>>[
      prefs.setString(
        _themeKey,
        value.theme.name,
      ),
      prefs.setString(
        _textSizeKey,
        value.textSize.name,
      ),
      prefs.setBool(
        _hapticsKey,
        value.hapticsEnabled,
      ),
      prefs.setBool(
        _soundsKey,
        value.buttonSoundsEnabled,
      ),
      prefs.setBool(
        _contrastKey,
        value.highContrast,
      ),
      prefs.setBool(
        _onboardingKey,
        value.onboardingCompleted,
      ),
    ]);
  }
}
