import 'package:flutter_test/flutter_test.dart';
import 'package:student_scientific_calculator/features/graphing/graphing_engine.dart';

void main() {
  const GraphingEngine engine = GraphingEngine();

  group('GraphingEngine', () {
    test('detects roots and turning point for x^2 - 4', () {
      final GraphAnalysis analysis = engine.analyze(
        expression: 'x^2 - 4',
        xMin: -5,
        xMax: 5,
        degrees: true,
        samples: 1000,
      );

      final List<double> roots = analysis.roots
          .map((GraphKeyPoint point) => point.point.x)
          .toList();

      expect(
        roots.any((double x) => (x + 2).abs() < 1e-4),
        isTrue,
      );
      expect(
        roots.any((double x) => (x - 2).abs() < 1e-4),
        isTrue,
      );

      expect(
        analysis.turningPoints.any(
          (GraphKeyPoint point) =>
              point.point.x.abs() < 0.03 &&
              (point.point.y + 4).abs() < 0.03,
        ),
        isTrue,
      );
    });

    test('finds y-intercept', () {
      final GraphAnalysis analysis = engine.analyze(
        expression: '2x + 3',
        xMin: -2,
        xMax: 2,
        degrees: true,
      );

      expect(analysis.yIntercepts.length, 1);
      expect(
        analysis.yIntercepts.first.point.y,
        closeTo(3, 1e-10),
      );
    });

    test('evaluates trigonometric functions in degrees', () {
      final double value = engine.evaluate(
        expression: 'sin(x)',
        x: 30,
        degrees: true,
      );

      expect(value, closeTo(0.5, 1e-10));
    });
  });
}
