import 'package:shared_preferences/shared_preferences.dart';

class FormulaFavoritesRepository {
  static const String _key =
      'formula_library_favourites_v1';

  Future<Set<String>> load() async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    return preferences
        .getStringList(_key)
        ?.toSet() ??
        <String>{};
  }

  Future<Set<String>> toggle(String formulaId) async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    final Set<String> ids =
        (preferences.getStringList(_key) ??
                <String>[])
            .toSet();

    if (ids.contains(formulaId)) {
      ids.remove(formulaId);
    } else {
      ids.add(formulaId);
    }

    final List<String> sorted = ids.toList()..sort();

    await preferences.setStringList(
      _key,
      sorted,
    );

    return ids;
  }
}
