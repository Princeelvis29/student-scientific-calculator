import 'package:flutter_test/flutter_test.dart';
import 'package:student_scientific_calculator/features/camera_solver/camera_math_cleaner.dart';
import 'package:student_scientific_calculator/features/camera_solver/camera_math_solver.dart';

void main() {
  const CameraMathCleaner cleaner =
      CameraMathCleaner();
  const CameraMathSolver solver =
      CameraMathSolver();

  test('cleans OCR multiplication and superscripts', () {
    expect(
      cleaner.clean('6 × 25 × 3'),
      '6*25*3',
    );

    expect(
      cleaner.clean('x² - 5x + 6 = 0'),
      'x^2-5x+6=0',
    );
  });

  test('solves numeric expression', () {
    final CameraMathSolution result =
        solver.solve('6 × 25 × 3');

    expect(result.isSolved, isTrue);
    expect(result.answer, '450');
  });

  test('solves linear equation', () {
    final CameraMathSolution result =
        solver.solve('2x + 3 = 11');

    expect(result.isSolved, isTrue);
    expect(result.answer, 'x = 4');
  });

  test('solves quadratic equation', () {
    final CameraMathSolution result =
        solver.solve('x² - 5x + 6 = 0');

    expect(result.isSolved, isTrue);
    expect(
      result.answer.contains('2') &&
          result.answer.contains('3'),
      isTrue,
    );
  });
}
