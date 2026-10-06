import '../calculator/calculator_engine.dart';
import '../equation/equation_solver.dart';
import 'camera_math_cleaner.dart';

enum CameraSolutionKind {
  expression,
  linearEquation,
  quadraticEquation,
  statement,
  unsupported,
}

class CameraMathSolution {
  const CameraMathSolution({
    required this.cleanedInput,
    required this.kind,
    required this.answer,
    required this.steps,
    required this.isSolved,
  });

  final String cleanedInput;
  final CameraSolutionKind kind;
  final String answer;
  final List<String> steps;
  final bool isSolved;
}

class CameraMathSolver {
  const CameraMathSolver();

  static const double _epsilon = 1e-8;

  CameraMathSolution solve(
    String rawInput, {
    bool degrees = true,
  }) {
    final CameraMathCleaner cleaner =
        const CameraMathCleaner();

    final String cleaned =
        cleaner.clean(rawInput);

    if (cleaned.isEmpty) {
      return const CameraMathSolution(
        cleanedInput: '',
        kind: CameraSolutionKind.unsupported,
        answer: 'No math expression detected',
        steps: <String>[
          'Retake the photo with the equation centered, well lit and in focus.',
        ],
        isSolved: false,
      );
    }

    if (!cleaned.contains('=')) {
      return _solveExpression(
        cleaned,
        degrees: degrees,
      );
    }

    return _solveEquation(
      cleaned,
      degrees: degrees,
    );
  }

  CameraMathSolution _solveExpression(
    String cleaned, {
    required bool degrees,
  }) {
    try {
      final CalculatorEngine engine =
          const CalculatorEngine();

      final double value = engine.evaluate(
        cleaned,
        degrees: degrees,
      );

      final String formatted =
          engine.formatNumber(value);

      return CameraMathSolution(
        cleanedInput: cleaned,
        kind: CameraSolutionKind.expression,
        answer: formatted,
        steps: <String>[
          'Recognized expression: $cleaned',
          'Apply brackets, powers/functions, multiplication/division, then addition/subtraction.',
          'Result = $formatted',
        ],
        isSolved: true,
      );
    } catch (_) {
      return CameraMathSolution(
        cleanedInput: cleaned,
        kind: CameraSolutionKind.unsupported,
        answer: 'Could not solve automatically',
        steps: const <String>[
          'Check the recognized expression and correct any OCR mistakes.',
          'This local solver currently handles numeric expressions and one-variable linear/quadratic equations.',
        ],
        isSolved: false,
      );
    }
  }

  CameraMathSolution _solveEquation(
    String cleaned, {
    required bool degrees,
  }) {
    final List<String> sides =
        cleaned.split('=');

    if (sides.length != 2 ||
        sides[0].isEmpty ||
        sides[1].isEmpty) {
      return CameraMathSolution(
        cleanedInput: cleaned,
        kind: CameraSolutionKind.unsupported,
        answer: 'Equation format not recognized',
        steps: const <String>[
          'Use a single equals sign, for example 2x+3=11.',
        ],
        isSolved: false,
      );
    }

    final String left = sides[0];
    final String right = sides[1];

    final bool hasVariable =
        RegExp(r'[xX]').hasMatch(cleaned);

    if (!hasVariable) {
      try {
        final CalculatorEngine engine =
            const CalculatorEngine();

        final double leftValue =
            engine.evaluate(
          left,
          degrees: degrees,
        );

        final double rightValue =
            engine.evaluate(
          right,
          degrees: degrees,
        );

        final bool equal =
            (leftValue - rightValue).abs() <
                _epsilon;

        return CameraMathSolution(
          cleanedInput: cleaned,
          kind: CameraSolutionKind.statement,
          answer: equal ? 'True' : 'False',
          steps: <String>[
            'Left side = ${engine.formatNumber(leftValue)}',
            'Right side = ${engine.formatNumber(rightValue)}',
            equal
                ? 'Both sides are equal.'
                : 'The two sides are not equal.',
          ],
          isSolved: true,
        );
      } catch (_) {
        return _unsupported(cleaned);
      }
    }

    final CalculatorEngine engine =
        const CalculatorEngine();

    final String difference =
        '($left)-($right)';

    try {
      final double f0 = engine.evaluate(
        difference,
        degrees: degrees,
        variables: const <String, double>{
          'X': 0,
        },
      );

      final double f1 = engine.evaluate(
        difference,
        degrees: degrees,
        variables: const <String, double>{
          'X': 1,
        },
      );

      final double f2 = engine.evaluate(
        difference,
        degrees: degrees,
        variables: const <String, double>{
          'X': 2,
        },
      );

      final double secondDifference =
          f2 - (2 * f1) + f0;

      final double a =
          secondDifference / 2;
      final double c = f0;
      final double b = f1 - a - c;

      final double f3 = engine.evaluate(
        difference,
        degrees: degrees,
        variables: const <String, double>{
          'X': 3,
        },
      );

      final double predictedF3 =
          (9 * a) + (3 * b) + c;

      if ((f3 - predictedF3).abs() > 1e-5) {
        return _unsupported(
          cleaned,
          extra:
              'The detected equation appears to be higher than quadratic or non-polynomial.',
        );
      }

      if (a.abs() < _epsilon) {
        return _solveLinear(
          cleaned: cleaned,
          coefficient: b,
          constant: c,
          engine: engine,
        );
      }

      return _solveQuadratic(
        cleaned: cleaned,
        a: a,
        b: b,
        c: c,
        engine: engine,
      );
    } catch (_) {
      return _unsupported(cleaned);
    }
  }

  CameraMathSolution _solveLinear({
    required String cleaned,
    required double coefficient,
    required double constant,
    required CalculatorEngine engine,
  }) {
    if (coefficient.abs() < _epsilon) {
      final bool identity =
          constant.abs() < _epsilon;

      return CameraMathSolution(
        cleanedInput: cleaned,
        kind: CameraSolutionKind.linearEquation,
        answer: identity
            ? 'Infinitely many solutions'
            : 'No solution',
        steps: <String>[
          'Move everything to one side.',
          'The x coefficient becomes 0.',
          identity
              ? 'The equation reduces to 0 = 0.'
              : 'The equation reduces to ${engine.formatNumber(constant)} = 0.',
        ],
        isSolved: true,
      );
    }

    final double x =
        -constant / coefficient;

    final String coefficientText =
        engine.formatNumber(coefficient);
    final String constantText =
        engine.formatNumber(constant);
    final String answer =
        engine.formatNumber(x);

    return CameraMathSolution(
      cleanedInput: cleaned,
      kind: CameraSolutionKind.linearEquation,
      answer: 'x = $answer',
      steps: <String>[
        'Recognized equation: $cleaned',
        'Move all terms to one side.',
        'Equivalent linear form: ${coefficientText}x ${constant >= 0 ? '+' : '−'} ${engine.formatNumber(constant.abs())} = 0',
        '${coefficientText}x = ${engine.formatNumber(-constant)}',
        'x = ${engine.formatNumber(-constant)} ÷ $coefficientText',
        'x = $answer',
      ],
      isSolved: true,
    );
  }

  CameraMathSolution _solveQuadratic({
    required String cleaned,
    required double a,
    required double b,
    required double c,
    required CalculatorEngine engine,
  }) {
    final EquationSolver solver =
        const EquationSolver();

    final EquationSolution result =
        solver.solveQuadratic(
      a: a,
      b: b,
      c: c,
    );

    final String aText =
        engine.formatNumber(a);
    final String bText =
        engine.formatNumber(b);
    final String cText =
        engine.formatNumber(c);

    final List<String> steps = <String>[
      'Recognized equation: $cleaned',
      'Move all terms to one side.',
      'Standard form coefficients: a=$aText, b=$bText, c=$cText',
      'Use x = (−b ± √(b² − 4ac)) / 2a.',
      ...result.lines,
    ];

    final String answer = result.lines
        .where(
          (String line) =>
              line.startsWith('x'),
        )
        .join('   ');

    return CameraMathSolution(
      cleanedInput: cleaned,
      kind: CameraSolutionKind.quadraticEquation,
      answer: answer.isEmpty
          ? result.title
          : answer,
      steps: steps,
      isSolved:
          result.status != EquationStatus.invalid,
    );
  }

  CameraMathSolution _unsupported(
    String cleaned, {
    String? extra,
  }) {
    return CameraMathSolution(
      cleanedInput: cleaned,
      kind: CameraSolutionKind.unsupported,
      answer: 'Could not solve automatically',
      steps: <String>[
        'Recognized: $cleaned',
        if (extra != null) extra,
        'Correct OCR mistakes manually and try again.',
        'Current local camera solver supports numeric expressions plus one-variable linear and quadratic equations.',
      ],
      isSolved: false,
    );
  }
}
