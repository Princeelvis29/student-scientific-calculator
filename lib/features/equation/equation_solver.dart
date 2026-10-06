import 'dart:math' as math;

enum EquationStatus {
  unique,
  multiple,
  none,
  invalid,
}

class ComplexNumber {
  const ComplexNumber(this.real, [this.imaginary = 0]);

  final double real;
  final double imaginary;

  ComplexNumber operator +(ComplexNumber other) => ComplexNumber(
        real + other.real,
        imaginary + other.imaginary,
      );

  ComplexNumber operator -(ComplexNumber other) => ComplexNumber(
        real - other.real,
        imaginary - other.imaginary,
      );

  ComplexNumber operator *(ComplexNumber other) => ComplexNumber(
        (real * other.real) - (imaginary * other.imaginary),
        (real * other.imaginary) + (imaginary * other.real),
      );

  ComplexNumber operator /(ComplexNumber other) {
    final double denominator =
        (other.real * other.real) +
            (other.imaginary * other.imaginary);

    if (denominator == 0) {
      throw const FormatException('Complex division by zero');
    }

    return ComplexNumber(
      ((real * other.real) +
              (imaginary * other.imaginary)) /
          denominator,
      ((imaginary * other.real) -
              (real * other.imaginary)) /
          denominator,
    );
  }

  double get magnitude => math.sqrt(
        (real * real) + (imaginary * imaginary),
      );
}

class EquationSolution {
  const EquationSolution({
    required this.status,
    required this.title,
    required this.lines,
    this.values = const <String, ComplexNumber>{},
  });

  final EquationStatus status;
  final String title;
  final List<String> lines;
  final Map<String, ComplexNumber> values;
}

class EquationSolver {
  const EquationSolver();

  static const double _epsilon = 1e-10;

  EquationSolution solveLinear({
    required double a,
    required double b,
    required double c,
  }) {
    if (_nearZero(a)) {
      if (_nearZero(b - c)) {
        return const EquationSolution(
          status: EquationStatus.multiple,
          title: 'Infinitely many solutions',
          lines: <String>[
            'The equation reduces to a true statement.',
          ],
        );
      }

      return const EquationSolution(
        status: EquationStatus.none,
        title: 'No solution',
        lines: <String>[
          'The equation reduces to a contradiction.',
        ],
      );
    }

    final double x = (c - b) / a;

    return EquationSolution(
      status: EquationStatus.unique,
      title: 'Linear solution',
      values: <String, ComplexNumber>{
        'x': ComplexNumber(x),
      },
      lines: <String>[
        '${_format(a)}x + ${_format(b)} = ${_format(c)}',
        'x = ${_format(x)}',
      ],
    );
  }

  EquationSolution solveSimultaneous({
    required List<List<double>> coefficients,
    required List<double> constants,
    required List<String> variableNames,
  }) {
    final int n = coefficients.length;

    if (n == 0 ||
        constants.length != n ||
        variableNames.length != n ||
        coefficients.any((List<double> row) => row.length != n)) {
      return const EquationSolution(
        status: EquationStatus.invalid,
        title: 'Invalid system',
        lines: <String>[
          'The coefficient matrix must be square and match the constants.',
        ],
      );
    }

    final List<List<double>> augmented = List<List<double>>.generate(
      n,
      (int row) => <double>[
        ...coefficients[row],
        constants[row],
      ],
    );

    int pivotRow = 0;
    final List<int> pivotColumns = <int>[];

    for (int column = 0;
        column < n && pivotRow < n;
        column++) {
      int bestRow = pivotRow;
      double bestMagnitude = augmented[pivotRow][column].abs();

      for (int row = pivotRow + 1; row < n; row++) {
        final double magnitude = augmented[row][column].abs();
        if (magnitude > bestMagnitude) {
          bestMagnitude = magnitude;
          bestRow = row;
        }
      }

      if (bestMagnitude < _epsilon) {
        continue;
      }

      final List<double> temporary = augmented[pivotRow];
      augmented[pivotRow] = augmented[bestRow];
      augmented[bestRow] = temporary;

      final double pivot = augmented[pivotRow][column];
      for (int col = column; col <= n; col++) {
        augmented[pivotRow][col] /= pivot;
      }

      for (int row = 0; row < n; row++) {
        if (row == pivotRow) continue;

        final double factor = augmented[row][column];
        if (factor.abs() < _epsilon) continue;

        for (int col = column; col <= n; col++) {
          augmented[row][col] -= factor * augmented[pivotRow][col];
        }
      }

      pivotColumns.add(column);
      pivotRow++;
    }

    for (int row = 0; row < n; row++) {
      bool allZero = true;
      for (int col = 0; col < n; col++) {
        if (augmented[row][col].abs() >= _epsilon) {
          allZero = false;
          break;
        }
      }

      if (allZero && augmented[row][n].abs() >= _epsilon) {
        return const EquationSolution(
          status: EquationStatus.none,
          title: 'No solution',
          lines: <String>[
            'The equations are inconsistent.',
          ],
        );
      }
    }

    if (pivotColumns.length < n) {
      return const EquationSolution(
        status: EquationStatus.multiple,
        title: 'Infinitely many solutions',
        lines: <String>[
          'The equations are dependent and do not determine one unique point.',
        ],
      );
    }

    final Map<String, ComplexNumber> values =
        <String, ComplexNumber>{};
    final List<String> lines = <String>[];

    for (int row = 0; row < n; row++) {
      final int column = pivotColumns[row];
      final double value = augmented[row][n];
      final String variable = variableNames[column];
      values[variable] = ComplexNumber(value);
      lines.add('$variable = ${_format(value)}');
    }

    return EquationSolution(
      status: EquationStatus.unique,
      title: '$n-variable solution',
      values: values,
      lines: lines,
    );
  }

  EquationSolution solveQuadratic({
    required double a,
    required double b,
    required double c,
  }) {
    if (_nearZero(a)) {
      return solveLinear(
        a: b,
        b: c,
        c: 0,
      );
    }

    final double discriminant = (b * b) - (4 * a * c);
    final List<String> lines = <String>[
      'D = b² - 4ac = ${_format(discriminant)}',
    ];

    if (_nearZero(discriminant)) {
      final double root = -b / (2 * a);
      lines.add('x₁ = x₂ = ${_format(root)}');

      return EquationSolution(
        status: EquationStatus.unique,
        title: 'Repeated root',
        values: <String, ComplexNumber>{
          'x₁': ComplexNumber(root),
          'x₂': ComplexNumber(root),
        },
        lines: lines,
      );
    }

    if (discriminant > 0) {
      final double squareRoot = math.sqrt(discriminant);
      final double x1 = (-b + squareRoot) / (2 * a);
      final double x2 = (-b - squareRoot) / (2 * a);
      lines
        ..add('x₁ = ${_format(x1)}')
        ..add('x₂ = ${_format(x2)}');

      return EquationSolution(
        status: EquationStatus.unique,
        title: 'Two real roots',
        values: <String, ComplexNumber>{
          'x₁': ComplexNumber(x1),
          'x₂': ComplexNumber(x2),
        },
        lines: lines,
      );
    }

    final double real = -b / (2 * a);
    final double imaginary = math.sqrt(-discriminant) / (2 * a.abs());

    final ComplexNumber x1 = ComplexNumber(real, imaginary);
    final ComplexNumber x2 = ComplexNumber(real, -imaginary);

    lines
      ..add('x₁ = ${_formatComplex(x1)}')
      ..add('x₂ = ${_formatComplex(x2)}');

    return EquationSolution(
      status: EquationStatus.unique,
      title: 'Two complex roots',
      values: <String, ComplexNumber>{
        'x₁': x1,
        'x₂': x2,
      },
      lines: lines,
    );
  }

  EquationSolution solvePolynomial(
    List<double> coefficients,
  ) {
    if (coefficients.length < 3) {
      return const EquationSolution(
        status: EquationStatus.invalid,
        title: 'Invalid polynomial',
        lines: <String>[
          'Provide a polynomial of degree 2 or higher.',
        ],
      );
    }

    int firstNonZero = 0;
    while (firstNonZero < coefficients.length &&
        coefficients[firstNonZero].abs() < _epsilon) {
      firstNonZero++;
    }

    if (firstNonZero == coefficients.length) {
      return const EquationSolution(
        status: EquationStatus.multiple,
        title: 'Every number is a root',
        lines: <String>[
          'All polynomial coefficients are zero.',
        ],
      );
    }

    final List<double> trimmed =
        coefficients.sublist(firstNonZero);
    final int degree = trimmed.length - 1;

    if (degree == 0) {
      return const EquationSolution(
        status: EquationStatus.none,
        title: 'No roots',
        lines: <String>[
          'A non-zero constant has no roots.',
        ],
      );
    }

    if (degree == 1) {
      return solveLinear(
        a: trimmed[0],
        b: trimmed[1],
        c: 0,
      );
    }

    if (degree == 2) {
      return solveQuadratic(
        a: trimmed[0],
        b: trimmed[1],
        c: trimmed[2],
      );
    }

    if (degree > 4) {
      return const EquationSolution(
        status: EquationStatus.invalid,
        title: 'Degree not supported yet',
        lines: <String>[
          'This version supports polynomial degrees 2, 3 and 4.',
        ],
      );
    }

    final List<ComplexNumber> roots =
        _durandKerner(trimmed);

    roots.sort((ComplexNumber left, ComplexNumber right) {
      final double realDifference = left.real - right.real;
      if (realDifference.abs() > 1e-8) {
        return realDifference < 0 ? -1 : 1;
      }

      final double imaginaryDifference =
          left.imaginary - right.imaginary;
      if (imaginaryDifference.abs() < 1e-8) return 0;
      return imaginaryDifference < 0 ? -1 : 1;
    });

    final Map<String, ComplexNumber> values =
        <String, ComplexNumber>{};
    final List<String> lines = <String>[];

    for (int index = 0; index < roots.length; index++) {
      final ComplexNumber cleaned = _cleanComplex(roots[index]);
      final String key = 'x${_subscript(index + 1)}';
      values[key] = cleaned;
      lines.add('$key = ${_formatComplex(cleaned)}');
    }

    return EquationSolution(
      status: EquationStatus.unique,
      title: 'Degree $degree roots',
      values: values,
      lines: lines,
    );
  }

  List<ComplexNumber> _durandKerner(
    List<double> coefficients,
  ) {
    final int degree = coefficients.length - 1;
    final double leading = coefficients.first;
    final List<double> normalized = coefficients
        .map((double value) => value / leading)
        .toList();

    double radius = 1;
    for (int index = 1; index < normalized.length; index++) {
      radius = math.max(radius, 1 + normalized[index].abs());
    }

    List<ComplexNumber> roots =
        List<ComplexNumber>.generate(
      degree,
      (int index) {
        final double angle =
            ((2 * math.pi * index) / degree) + 0.37;
        return ComplexNumber(
          radius * math.cos(angle),
          radius * math.sin(angle),
        );
      },
    );

    const int maxIterations = 2000;
    const double tolerance = 1e-12;

    for (int iteration = 0;
        iteration < maxIterations;
        iteration++) {
      final List<ComplexNumber> next =
          List<ComplexNumber>.from(roots);
      double largestChange = 0;

      for (int i = 0; i < degree; i++) {
        final ComplexNumber root = roots[i];
        final ComplexNumber numerator =
            _evaluatePolynomial(normalized, root);

        ComplexNumber denominator =
            const ComplexNumber(1);

        for (int j = 0; j < degree; j++) {
          if (i == j) continue;
          denominator = denominator * (root - roots[j]);
        }

        if (denominator.magnitude < 1e-18) {
          denominator = denominator +
              const ComplexNumber(1e-12, 1e-12);
        }

        final ComplexNumber updated =
            root - (numerator / denominator);
        final double change = (updated - root).magnitude;
        largestChange = math.max(largestChange, change);
        next[i] = updated;
      }

      roots = next;

      if (largestChange < tolerance) {
        break;
      }
    }

    return roots;
  }

  ComplexNumber _evaluatePolynomial(
    List<double> coefficients,
    ComplexNumber x,
  ) {
    ComplexNumber result = ComplexNumber(coefficients.first);

    for (int index = 1; index < coefficients.length; index++) {
      result = (result * x) + ComplexNumber(coefficients[index]);
    }

    return result;
  }

  ComplexNumber _cleanComplex(ComplexNumber value) {
    final double real =
        value.real.abs() < 1e-9 ? 0 : value.real;
    final double imaginary = value.imaginary.abs() < 1e-9
        ? 0
        : value.imaginary;

    return ComplexNumber(real, imaginary);
  }

  bool _nearZero(double value) => value.abs() < _epsilon;

  String _formatComplex(ComplexNumber value) {
    final ComplexNumber cleaned = _cleanComplex(value);

    if (_nearZero(cleaned.imaginary)) {
      return _format(cleaned.real);
    }

    if (_nearZero(cleaned.real)) {
      if ((cleaned.imaginary - 1).abs() < _epsilon) return 'i';
      if ((cleaned.imaginary + 1).abs() < _epsilon) return '-i';
      return '${_format(cleaned.imaginary)}i';
    }

    final String sign = cleaned.imaginary >= 0 ? '+' : '−';
    final double magnitude = cleaned.imaginary.abs();
    final String imaginaryPart =
        (magnitude - 1).abs() < _epsilon ? 'i' : '${_format(magnitude)}i';

    return '${_format(cleaned.real)} $sign $imaginaryPart';
  }

  String _format(double value) {
    final double cleaned = value.abs() < 1e-12 ? 0 : value;
    final double rounded = cleaned.roundToDouble();

    if ((cleaned - rounded).abs() < 1e-10 && cleaned.abs() < 1e15) {
      return rounded.toInt().toString();
    }

    String text = cleaned.toStringAsPrecision(10);
    if (!text.contains('e') && !text.contains('E')) {
      text = text.replaceFirst(RegExp(r'\.?0+$'), '');
    }
    return text;
  }

  String _subscript(int value) {
    const List<String> digits = <String>[
      '₀',
      '₁',
      '₂',
      '₃',
      '₄',
      '₅',
      '₆',
      '₇',
      '₈',
      '₉',
    ];

    return value
        .toString()
        .split('')
        .map((String digit) => digits[int.parse(digit)])
        .join();
  }
}
