import '../calculator/calculator_engine.dart';

class FunctionTableRow {
  const FunctionTableRow({
    required this.x,
    required this.fx,
    this.gx,
  });

  final double x;
  final double fx;
  final double? gx;
}

class FunctionTableResult {
  const FunctionTableResult({
    required this.rows,
  });

  final List<FunctionTableRow> rows;
}

class FunctionTableEngine {
  const FunctionTableEngine({
    this.maxRows = 201,
  });

  final int maxRows;

  FunctionTableResult generate({
    required String functionF,
    String? functionG,
    required double start,
    required double end,
    required double step,
    bool degrees = true,
  }) {
    if (functionF.trim().isEmpty) {
      throw const FormatException(
        'Enter f(x).',
      );
    }

    if (!start.isFinite ||
        !end.isFinite ||
        !step.isFinite) {
      throw const FormatException(
        'Start, end and step must be finite numbers.',
      );
    }

    if (step == 0) {
      throw const FormatException(
        'Step cannot be zero.',
      );
    }

    if (start < end && step < 0) {
      throw const FormatException(
        'Use a positive step when start < end.',
      );
    }

    if (start > end && step > 0) {
      throw const FormatException(
        'Use a negative step when start > end.',
      );
    }

    final CalculatorEngine calculator =
        const CalculatorEngine();

    final List<FunctionTableRow> rows =
        <FunctionTableRow>[];

    const double epsilon = 1e-12;

    bool inRange(double x) {
      if (step > 0) {
        return x <= end + epsilon;
      }
      return x >= end - epsilon;
    }

    for (int index = 0;
        index < maxRows;
        index++) {
      final double x = start + (step * index);

      if (!inRange(x)) {
        break;
      }

      final Map<String, double> variables =
          <String, double>{
        'X': x,
      };

      final double fx = calculator.evaluate(
        functionF,
        degrees: degrees,
        variables: variables,
      );

      final String? cleanG = functionG?.trim();

      final double? gx =
          cleanG == null || cleanG.isEmpty
              ? null
              : calculator.evaluate(
                  cleanG,
                  degrees: degrees,
                  variables: variables,
                );

      rows.add(
        FunctionTableRow(
          x: _clean(x),
          fx: _clean(fx),
          gx: gx == null ? null : _clean(gx),
        ),
      );
    }

    if (rows.isEmpty) {
      throw const FormatException(
        'The selected range produced no rows.',
      );
    }

    final double nextX =
        start + (step * rows.length);

    if (inRange(nextX)) {
      throw FormatException(
        'This range would create more than $maxRows rows. '
        'Increase the step size or reduce the range.',
      );
    }

    return FunctionTableResult(rows: rows);
  }

  double _clean(double value) {
    if (value.abs() < 1e-12) return 0;

    final double rounded = value.roundToDouble();

    if ((value - rounded).abs() < 1e-12) {
      return rounded;
    }

    return value;
  }
}
