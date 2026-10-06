import 'package:flutter_test/flutter_test.dart';
import 'package:student_scientific_calculator/features/statistics/statistics_engine.dart';

void main() {
  const StatisticsEngine engine = StatisticsEngine();

  group('1-variable statistics', () {
    test('supports frequencies and core summary measures', () {
      final OneVariableStatistics result = engine.oneVariable(
        const <FrequencyValue>[
          FrequencyValue(value: 1, frequency: 1),
          FrequencyValue(value: 2, frequency: 2),
          FrequencyValue(value: 3, frequency: 1),
        ],
      );

      expect(result.count, 4);
      expect(result.sum, closeTo(8, 1e-12));
      expect(result.sumSquares, closeTo(18, 1e-12));
      expect(result.mean, closeTo(2, 1e-12));
      expect(result.median, closeTo(2, 1e-12));
      expect(result.modes, <double>[2]);
      expect(result.minimum, 1);
      expect(result.maximum, 3);
      expect(
        result.populationVariance,
        closeTo(0.5, 1e-12),
      );
      expect(
        result.sampleVariance!,
        closeTo(2 / 3, 1e-12),
      );
      expect(
        result.populationStdDev,
        closeTo(0.7071067811865476, 1e-12),
      );
      expect(
        result.sampleStdDev!,
        closeTo(0.816496580927726, 1e-12),
      );
    });

    test('reports no unique mode when all values occur equally', () {
      final OneVariableStatistics result = engine.oneVariable(
        const <FrequencyValue>[
          FrequencyValue(value: 1),
          FrequencyValue(value: 2),
          FrequencyValue(value: 3),
        ],
      );

      expect(result.modes, isEmpty);
    });
  });

  group('2-variable statistics', () {
    test('calculates perfect positive correlation and regression', () {
      final TwoVariableStatistics result = engine.twoVariable(
        const <FrequencyPair>[
          FrequencyPair(x: 1, y: 2),
          FrequencyPair(x: 2, y: 4),
          FrequencyPair(x: 3, y: 6),
          FrequencyPair(x: 4, y: 8),
        ],
      );

      expect(result.count, 4);
      expect(result.sumX, closeTo(10, 1e-12));
      expect(result.sumY, closeTo(20, 1e-12));
      expect(result.sumXY, closeTo(60, 1e-12));
      expect(result.meanX, closeTo(2.5, 1e-12));
      expect(result.meanY, closeTo(5, 1e-12));
      expect(result.correlation!, closeTo(1, 1e-12));
      expect(result.regressionSlope!, closeTo(2, 1e-12));
      expect(result.regressionIntercept!, closeTo(0, 1e-12));
    });

    test('honours frequency weights', () {
      final TwoVariableStatistics result = engine.twoVariable(
        const <FrequencyPair>[
          FrequencyPair(x: 1, y: 2, frequency: 2),
          FrequencyPair(x: 2, y: 4, frequency: 1),
        ],
      );

      expect(result.count, 3);
      expect(result.sumX, closeTo(4, 1e-12));
      expect(result.sumY, closeTo(8, 1e-12));
      expect(result.correlation!, closeTo(1, 1e-12));
      expect(result.regressionSlope!, closeTo(2, 1e-12));
      expect(result.regressionIntercept!, closeTo(0, 1e-12));
    });

    test('returns undefined correlation when x has zero variance', () {
      final TwoVariableStatistics result = engine.twoVariable(
        const <FrequencyPair>[
          FrequencyPair(x: 2, y: 1),
          FrequencyPair(x: 2, y: 3),
        ],
      );

      expect(result.correlation, isNull);
      expect(result.regressionSlope, isNull);
      expect(result.regressionIntercept, isNull);
    });
  });
}
