import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_scientific_calculator/features/formula_library/formula_catalog.dart';
import 'package:student_scientific_calculator/features/formula_library/formula_entry.dart';
import 'package:student_scientific_calculator/features/formula_library/formula_favorites_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FormulaCatalog', () {
    test('contains all three subjects', () {
      for (final FormulaSubject subject
          in FormulaSubject.values) {
        expect(
          FormulaCatalog.entries.any(
            (entry) =>
                entry.subject == subject,
          ),
          isTrue,
        );
      }
    });

    test('formula IDs are unique', () {
      final ids = FormulaCatalog.entries
          .map((entry) => entry.id)
          .toList();

      expect(ids.toSet().length, ids.length);
    });

    test('mathematics topics are available', () {
      final topics = FormulaCatalog.topicsFor(
        FormulaSubject.mathematics,
      );

      expect(topics, contains('Algebra'));
      expect(topics, contains('Trigonometry'));
    });
  });

  group('FormulaFavoritesRepository', () {
    late FormulaFavoritesRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues(
        <String, Object>{},
      );
      repository =
          FormulaFavoritesRepository();
    });

    test('toggles a favourite on and off', () async {
      final first =
          await repository.toggle(
        'math_quadratic_formula',
      );

      expect(
        first,
        contains('math_quadratic_formula'),
      );

      final second =
          await repository.toggle(
        'math_quadratic_formula',
      );

      expect(
        second,
        isNot(
          contains('math_quadratic_formula'),
        ),
      );
    });

    test('persists multiple favourites', () async {
      await repository.toggle(
        'math_quadratic_formula',
      );
      await repository.toggle(
        'physics_ohm',
      );

      final loaded = await repository.load();

      expect(
        loaded,
        containsAll(
          <String>[
            'math_quadratic_formula',
            'physics_ohm',
          ],
        ),
      );
    });
  });
}
