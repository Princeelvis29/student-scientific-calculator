import 'package:flutter_test/flutter_test.dart';
import 'package:student_scientific_calculator/features/equation/equation_solver.dart';

void main() {
  const EquationSolver solver = EquationSolver();

  test('solves a linear equation', () {
    final EquationSolution solution = solver.solveLinear(
      a: 2,
      b: 3,
      c: 11,
    );

    expect(solution.status, EquationStatus.unique);
    expect(solution.values['x']!.real, closeTo(4, 1e-10));
  });

  test('solves a 2x2 simultaneous system', () {
    final EquationSolution solution = solver.solveSimultaneous(
      coefficients: const <List<double>>[
        <double>[2, 1],
        <double>[1, -1],
      ],
      constants: const <double>[5, 1],
      variableNames: const <String>['x', 'y'],
    );

    expect(solution.status, EquationStatus.unique);
    expect(solution.values['x']!.real, closeTo(2, 1e-10));
    expect(solution.values['y']!.real, closeTo(1, 1e-10));
  });

  test('solves a quadratic equation', () {
    final EquationSolution solution = solver.solveQuadratic(
      a: 1,
      b: -5,
      c: 6,
    );

    expect(solution.status, EquationStatus.unique);
    final List<double> roots = solution.values.values
        .map((ComplexNumber value) => value.real)
        .toList()
      ..sort();

    expect(roots[0], closeTo(2, 1e-10));
    expect(roots[1], closeTo(3, 1e-10));
  });

  test('solves cubic polynomial roots 1, 2, 3', () {
    final EquationSolution solution = solver.solvePolynomial(
      const <double>[1, -6, 11, -6],
    );

    final List<double> roots = solution.values.values
        .where((ComplexNumber value) => value.imaginary.abs() < 1e-7)
        .map((ComplexNumber value) => value.real)
        .toList()
      ..sort();

    expect(roots.length, 3);
    expect(roots[0], closeTo(1, 1e-6));
    expect(roots[1], closeTo(2, 1e-6));
    expect(roots[2], closeTo(3, 1e-6));
  });

  test('solves quartic roots -2, -1, 1, 2', () {
    final EquationSolution solution = solver.solvePolynomial(
      const <double>[1, 0, -5, 0, 4],
    );

    final List<double> roots = solution.values.values
        .where((ComplexNumber value) => value.imaginary.abs() < 1e-7)
        .map((ComplexNumber value) => value.real)
        .toList()
      ..sort();

    expect(roots.length, 4);
    expect(roots[0], closeTo(-2, 1e-6));
    expect(roots[1], closeTo(-1, 1e-6));
    expect(roots[2], closeTo(1, 1e-6));
    expect(roots[3], closeTo(2, 1e-6));
  });
}
