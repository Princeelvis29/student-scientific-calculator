import '../calculator/calculator_engine.dart';

class GraphPoint {
  const GraphPoint(this.x, this.y);

  final double x;
  final double y;
}

enum GraphKeyPointType {
  root,
  yIntercept,
  turningPoint,
}

class GraphKeyPoint {
  const GraphKeyPoint({
    required this.type,
    required this.point,
    required this.label,
  });

  final GraphKeyPointType type;
  final GraphPoint point;
  final String label;
}

class GraphAnalysis {
  const GraphAnalysis({
    required this.points,
    required this.keyPoints,
  });

  final List<GraphPoint?> points;
  final List<GraphKeyPoint> keyPoints;

  List<GraphKeyPoint> get roots => keyPoints
      .where(
        (GraphKeyPoint point) =>
            point.type == GraphKeyPointType.root,
      )
      .toList();

  List<GraphKeyPoint> get yIntercepts => keyPoints
      .where(
        (GraphKeyPoint point) =>
            point.type == GraphKeyPointType.yIntercept,
      )
      .toList();

  List<GraphKeyPoint> get turningPoints => keyPoints
      .where(
        (GraphKeyPoint point) =>
            point.type ==
            GraphKeyPointType.turningPoint,
      )
      .toList();
}

class GraphingEngine {
  const GraphingEngine();

  static const double _epsilon = 1e-9;

  GraphAnalysis analyze({
    required String expression,
    required double xMin,
    required double xMax,
    required bool degrees,
    int samples = 600,
  }) {
    if (expression.trim().isEmpty) {
      throw const FormatException(
        'Enter a function before graphing.',
      );
    }

    if (!xMin.isFinite ||
        !xMax.isFinite ||
        xMin >= xMax) {
      throw const FormatException(
        'Graph range must satisfy xMin < xMax.',
      );
    }

    if (samples < 50) samples = 50;

    final CalculatorEngine calculator =
        const CalculatorEngine();

    final double step = (xMax - xMin) / samples;

    final List<GraphPoint?> sampled =
        <GraphPoint?>[];

    for (int i = 0; i <= samples; i++) {
      final double x = xMin + (step * i);

      try {
        final double y = calculator.evaluate(
          expression,
          degrees: degrees,
          variables: <String, double>{'X': x},
        );

        sampled.add(
          y.isFinite ? GraphPoint(x, y) : null,
        );
      } catch (_) {
        sampled.add(null);
      }
    }

    final List<GraphKeyPoint> keyPoints =
        <GraphKeyPoint>[
      ..._findRoots(
        expression: expression,
        sampled: sampled,
        degrees: degrees,
      ),
      ..._findYIntercept(
        expression: expression,
        xMin: xMin,
        xMax: xMax,
        degrees: degrees,
      ),
      ..._findTurningPoints(sampled),
    ];

    return GraphAnalysis(
      points: sampled,
      keyPoints: _dedupeKeyPoints(keyPoints),
    );
  }

  double evaluate({
    required String expression,
    required double x,
    required bool degrees,
  }) {
    final CalculatorEngine calculator =
        const CalculatorEngine();

    return calculator.evaluate(
      expression,
      degrees: degrees,
      variables: <String, double>{'X': x},
    );
  }

  List<GraphKeyPoint> _findRoots({
    required String expression,
    required List<GraphPoint?> sampled,
    required bool degrees,
  }) {
    final List<GraphKeyPoint> roots =
        <GraphKeyPoint>[];

    for (int i = 0; i < sampled.length - 1; i++) {
      final GraphPoint? left = sampled[i];
      final GraphPoint? right = sampled[i + 1];

      if (left == null || right == null) {
        continue;
      }

      if (left.y.abs() < 1e-7) {
        roots.add(
          GraphKeyPoint(
            type: GraphKeyPointType.root,
            point: GraphPoint(left.x, 0),
            label: 'Root',
          ),
        );
        continue;
      }

      if (left.y.sign == right.y.sign) {
        continue;
      }

      final GraphPoint? refined = _refineRoot(
        expression: expression,
        leftX: left.x,
        rightX: right.x,
        degrees: degrees,
      );

      if (refined != null) {
        roots.add(
          GraphKeyPoint(
            type: GraphKeyPointType.root,
            point: refined,
            label: 'Root',
          ),
        );
      }
    }

    final GraphPoint? last =
        sampled.isEmpty ? null : sampled.last;

    if (last != null && last.y.abs() < 1e-7) {
      roots.add(
        GraphKeyPoint(
          type: GraphKeyPointType.root,
          point: GraphPoint(last.x, 0),
          label: 'Root',
        ),
      );
    }

    return roots;
  }

  GraphPoint? _refineRoot({
    required String expression,
    required double leftX,
    required double rightX,
    required bool degrees,
  }) {
    double a = leftX;
    double b = rightX;

    double fa;

    try {
      fa = evaluate(
        expression: expression,
        x: a,
        degrees: degrees,
      );
    } catch (_) {
      return null;
    }

    for (int i = 0; i < 45; i++) {
      final double midpoint = (a + b) / 2;

      double fm;

      try {
        fm = evaluate(
          expression: expression,
          x: midpoint,
          degrees: degrees,
        );
      } catch (_) {
        return null;
      }

      if (fm.abs() < _epsilon) {
        return GraphPoint(midpoint, 0);
      }

      if (fa.sign == fm.sign) {
        a = midpoint;
        fa = fm;
      } else {
        b = midpoint;
      }
    }

    return GraphPoint((a + b) / 2, 0);
  }

  List<GraphKeyPoint> _findYIntercept({
    required String expression,
    required double xMin,
    required double xMax,
    required bool degrees,
  }) {
    if (xMin > 0 || xMax < 0) {
      return <GraphKeyPoint>[];
    }

    try {
      final double y = evaluate(
        expression: expression,
        x: 0,
        degrees: degrees,
      );

      if (!y.isFinite) {
        return <GraphKeyPoint>[];
      }

      return <GraphKeyPoint>[
        GraphKeyPoint(
          type: GraphKeyPointType.yIntercept,
          point: GraphPoint(0, y),
          label: 'y-intercept',
        ),
      ];
    } catch (_) {
      return <GraphKeyPoint>[];
    }
  }

  List<GraphKeyPoint> _findTurningPoints(
    List<GraphPoint?> sampled,
  ) {
    final List<GraphKeyPoint> results =
        <GraphKeyPoint>[];

    for (int i = 1; i < sampled.length - 1; i++) {
      final GraphPoint? previous = sampled[i - 1];
      final GraphPoint? current = sampled[i];
      final GraphPoint? next = sampled[i + 1];

      if (previous == null ||
          current == null ||
          next == null) {
        continue;
      }

      final double leftSlope =
          current.y - previous.y;
      final double rightSlope =
          next.y - current.y;

      final bool maximum =
          leftSlope > 0 && rightSlope < 0;
      final bool minimum =
          leftSlope < 0 && rightSlope > 0;

      if (!maximum && !minimum) {
        continue;
      }

      final GraphPoint refined =
          _quadraticTurningPoint(
        previous,
        current,
        next,
      );

      results.add(
        GraphKeyPoint(
          type: GraphKeyPointType.turningPoint,
          point: refined,
          label: maximum
              ? 'Local maximum'
              : 'Local minimum',
        ),
      );
    }

    return results;
  }

  GraphPoint _quadraticTurningPoint(
    GraphPoint p1,
    GraphPoint p2,
    GraphPoint p3,
  ) {
    final double h = p2.x - p1.x;

    if (h.abs() < _epsilon) return p2;

    final double denominator =
        p1.y - (2 * p2.y) + p3.y;

    if (denominator.abs() < _epsilon) {
      return p2;
    }

    final double offset =
        0.5 * (p1.y - p3.y) / denominator;

    if (offset.abs() > 1.5) {
      return p2;
    }

    final double x = p2.x + (offset * h);

    // Parabolic interpolation of y around p2.
    final double y =
        p2.y -
        0.25 *
            (p1.y - p3.y) *
            offset;

    return GraphPoint(x, y);
  }

  List<GraphKeyPoint> _dedupeKeyPoints(
    List<GraphKeyPoint> points,
  ) {
    final List<GraphKeyPoint> result =
        <GraphKeyPoint>[];

    for (final GraphKeyPoint candidate in points) {
      final bool duplicate = result.any(
        (GraphKeyPoint existing) =>
            existing.type == candidate.type &&
            (existing.point.x - candidate.point.x)
                    .abs() <
                1e-4 &&
            (existing.point.y - candidate.point.y)
                    .abs() <
                1e-4,
      );

      if (!duplicate) {
        result.add(candidate);
      }
    }

    result.sort(
      (
        GraphKeyPoint a,
        GraphKeyPoint b,
      ) =>
          a.point.x.compareTo(b.point.x),
    );

    return result;
  }
}
