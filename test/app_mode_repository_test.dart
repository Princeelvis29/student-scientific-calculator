import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_scientific_calculator/models/app_experience_mode.dart';
import 'package:student_scientific_calculator/services/app_mode_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(
      <String, Object>{},
    );
  });

  test('defaults to Study Mode', () async {
    final AppModeRepository repository =
        AppModeRepository();

    expect(
      await repository.load(),
      AppExperienceMode.study,
    );
  });

  test('persists Exam Mode', () async {
    final AppModeRepository repository =
        AppModeRepository();

    await repository.save(
      AppExperienceMode.exam,
    );

    expect(
      await repository.load(),
      AppExperienceMode.exam,
    );
  });
}
