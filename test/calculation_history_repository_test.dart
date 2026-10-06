import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_scientific_calculator/features/history/calculation_history_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CalculationHistoryRepository', () {
    late CalculationHistoryRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues(
        <String, Object>{},
      );

      repository =
          CalculationHistoryRepository(
        maxRecentItems: 10,
      );
    });

    test('adds and reloads calculations', () async {
      await repository.add(
        expression: '2+3',
        result: '5',
      );

      final items = await repository.load();

      expect(items.length, 1);
      expect(items.first.expression, '2+3');
      expect(items.first.result, '5');
      expect(items.first.mode, 'COMP');
    });

    test('repeating calculation refreshes instead of duplicating', () async {
      await repository.add(
        expression: '2+3',
        result: '5',
      );

      await repository.add(
        expression: '2+3',
        result: '5',
      );

      final items = await repository.load();

      expect(items.length, 1);
    });

    test('favourite survives clear non-favourites', () async {
      final first = await repository.add(
        expression: '2+3',
        result: '5',
      );

      await repository.add(
        expression: '9*9',
        result: '81',
      );

      await repository.toggleFavorite(first.id);
      await repository.clearNonFavorites();

      final items = await repository.load();

      expect(items.length, 1);
      expect(items.first.id, first.id);
      expect(items.first.isFavorite, isTrue);
    });

    test('delete removes a single item', () async {
      final first = await repository.add(
        expression: '1+1',
        result: '2',
      );

      await repository.add(
        expression: '2+2',
        result: '4',
      );

      await repository.delete(first.id);

      final items = await repository.load();

      expect(items.length, 1);
      expect(items.first.expression, '2+2');
    });

    test('clear all deletes everything', () async {
      await repository.add(
        expression: '3+3',
        result: '6',
      );

      await repository.clearAll();

      expect(await repository.load(), isEmpty);
    });
  });
}
