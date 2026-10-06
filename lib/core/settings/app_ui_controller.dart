import 'package:flutter/material.dart';

import 'app_ui_preferences.dart';
import 'app_ui_preferences_repository.dart';

class AppUiController extends ChangeNotifier {
  AppUiController({
    AppUiPreferencesRepository? repository,
  }) : _repository =
            repository ??
            AppUiPreferencesRepository();

  final AppUiPreferencesRepository _repository;

  AppUiPreferences _value =
      const AppUiPreferences();

  bool _loaded = false;

  AppUiPreferences get value => _value;
  bool get loaded => _loaded;

  ThemeMode get themeMode =>
      _value.theme.themeMode;

  Future<void> load() async {
    _value = await _repository.load();
    _loaded = true;
    notifyListeners();
  }

  Future<void> update(
    AppUiPreferences value,
  ) async {
    _value = value;
    notifyListeners();
    await _repository.save(value);
  }

  Future<void> setTheme(
    AppThemePreference theme,
  ) {
    return update(
      _value.copyWith(theme: theme),
    );
  }

  Future<void> setTextSize(
    AppTextSize size,
  ) {
    return update(
      _value.copyWith(textSize: size),
    );
  }

  Future<void> setHaptics(
    bool enabled,
  ) {
    return update(
      _value.copyWith(
        hapticsEnabled: enabled,
      ),
    );
  }

  Future<void> setButtonSounds(
    bool enabled,
  ) {
    return update(
      _value.copyWith(
        buttonSoundsEnabled: enabled,
      ),
    );
  }

  Future<void> setHighContrast(
    bool enabled,
  ) {
    return update(
      _value.copyWith(
        highContrast: enabled,
      ),
    );
  }

  Future<void> completeOnboarding() {
    return update(
      _value.copyWith(
        onboardingCompleted: true,
      ),
    );
  }

  Future<void> resetOnboarding() {
    return update(
      _value.copyWith(
        onboardingCompleted: false,
      ),
    );
  }
}

class AppUiScope extends InheritedNotifier<AppUiController> {
  const AppUiScope({
    super.key,
    required AppUiController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppUiController of(
    BuildContext context,
  ) {
    final AppUiScope? scope =
        context.dependOnInheritedWidgetOfExactType<
            AppUiScope>();

    assert(
      scope != null,
      'AppUiScope not found above this context.',
    );

    return scope!.notifier!;
  }

  static AppUiController? maybeOf(
    BuildContext context,
  ) {
    return context
        .dependOnInheritedWidgetOfExactType<
            AppUiScope>()
        ?.notifier;
  }
}
