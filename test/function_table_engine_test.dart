import 'package:flutter_test/flutter_test.dart';
import 'package:student_scientific_calculator/features/table/function_table_engine.dart';

void main() {
  const FunctionTableEngine engine =
      FunctionTableEngine();

  test('generates x squared table', () {
    final FunctionTableResult result =
        engine.generate(
      functionF: 'x^2',
      start: -2,
      end: 2,
      step: 1,
    );

    expect(result.rows.length, 5);
    expect(result.rows[0].x, -2);
    expect(result.rows[0].fx, 4);
    expect(result.rows[2].x, 0);
    expect(result.rows[2].fx, 0);
    expect(result.rows[4].fx, 4);
  });

  test('supports optional g(x)', () {
    final FunctionTableResult result =
        engine.generate(
      functionF: 'x',
      functionG: '2x + 1',
      start: 0,
      end: 2,
      step: 1,
    );

    expect(result.rows[0].gx, closeTo(1, 1e-12));
    expect(result.rows[2].gx, closeTo(5, 1e-12));
  });

  test('rejects zero step', () {
    expect(
      () => engine.generate(
        functionF: 'x',
        start: 0,
        end: 2,
        step: 0,
      ),
      throwsFormatException,
    );
  });
}
