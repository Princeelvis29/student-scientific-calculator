import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_scientific_calculator/core/settings/app_ui_preferences.dart';
import 'package:student_scientific_calculator/core/settings/app_ui_preferences_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(
      <String, Object>{},
    );
  });

  test('UI preferences have sensible defaults', () async {
    final AppUiPreferencesRepository repository =
        AppUiPreferencesRepository();

    final AppUiPreferences value =
        await repository.load();

    expect(
      value.theme,
      AppThemePreference.system,
    );
    expect(
      value.textSize,
      AppTextSize.standard,
    );
    expect(value.hapticsEnabled, isTrue);
    expect(value.buttonSoundsEnabled, isFalse);
    expect(value.onboardingCompleted, isFalse);
  });

  test('UI preferences persist', () async {
    final AppUiPreferencesRepository repository =
        AppUiPreferencesRepository();

    await repository.save(
      const AppUiPreferences(
        theme: AppThemePreference.light,
        textSize: AppTextSize.large,
        hapticsEnabled: false,
        buttonSoundsEnabled: true,
        highContrast: true,
        onboardingCompleted: true,
      ),
    );

    final AppUiPreferences value =
        await repository.load();

    expect(
      value.theme,
      AppThemePreference.light,
    );
    expect(
      value.textSize,
      AppTextSize.large,
    );
    expect(value.hapticsEnabled, isFalse);
    expect(value.buttonSoundsEnabled, isTrue);
    expect(value.highContrast, isTrue);
    expect(value.onboardingCompleted, isTrue);
  });
}
