import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_experience_mode.dart';

class AppModeRepository {
  static const String _key =
      'student_scientific_calculator_app_mode_v1';

  Future<AppExperienceMode> load() async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    final String? stored = preferences.getString(_key);

    return AppExperienceMode.values.firstWhere(
      (AppExperienceMode mode) =>
          mode.name == stored,
      orElse: () => AppExperienceMode.study,
    );
  }

  Future<void> save(
    AppExperienceMode mode,
  ) async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    await preferences.setString(
      _key,
      mode.name,
    );
  }
}
