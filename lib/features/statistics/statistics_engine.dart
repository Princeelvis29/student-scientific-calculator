import 'dart:math' as math;

class FrequencyValue {
  const FrequencyValue({
    required this.value,
    this.frequency = 1,
  });

  final double value;
  final int frequency;
}

class FrequencyPair {
  const FrequencyPair({
    required this.x,
    required this.y,
    this.frequency = 1,
  });

  final double x;
  final double y;
  final int frequency;
}

class OneVariableStatistics {
  const OneVariableStatistics({
    required this.count,
    required this.sum,
    required this.sumSquares,
    required this.mean,
    required this.median,
    required this.modes,
    required this.minimum,
    required this.maximum,
    required this.populationVariance,
    required this.sampleVariance,
    required this.populationStdDev,
    required this.sampleStdDev,
  });

  final int count;
  final double sum;
  final double sumSquares;
  final double mean;
  final double median;
  final List<double> modes;
  final double minimum;
  final double maximum;
  final double populationVariance;
  final double? sampleVariance;
  final double populationStdDev;
  final double? sampleStdDev;
}

class TwoVariableStatistics {
  const TwoVariableStatistics({
    required this.count,
    required this.sumX,
    required this.sumY,
    required this.sumX2,
    required this.sumY2,
    required this.sumXY,
    required this.meanX,
    required this.meanY,
    required this.populationVarianceX,
    required this.populationVarianceY,
    required this.sampleVarianceX,
    required this.sampleVarianceY,
    required this.populationStdDevX,
    required this.populationStdDevY,
    required this.sampleStdDevX,
    required this.sampleStdDevY,
    required this.correlation,
    required this.regressionSlope,
    required this.regressionIntercept,
  });

  final int count;

  final double sumX;
  final double sumY;
  final double sumX2;
  final double sumY2;
  final double sumXY;

  final double meanX;
  final double meanY;

  final double populationVarianceX;
  final double populationVarianceY;
  final double? sampleVarianceX;
  final double? sampleVarianceY;

  final double populationStdDevX;
  final double populationStdDevY;
  final double? sampleStdDevX;
  final double? sampleStdDevY;

  final double? correlation;
  final double? regressionSlope;
  final double? regressionIntercept;
}

class StatisticsEngine {
  const StatisticsEngine();

  static const double _epsilon = 1e-12;

  OneVariableStatistics oneVariable(
    List<FrequencyValue> entries,
  ) {
    final List<FrequencyValue> clean = _cleanValues(entries);

    if (clean.isEmpty) {
      throw const FormatException(
        'Enter at least one data value.',
      );
    }

    final int count = clean.fold<int>(
      0,
      (int total, FrequencyValue item) =>
          total + item.frequency,
    );

    final double sum = clean.fold<double>(
      0,
      (double total, FrequencyValue item) =>
          total + (item.value * item.frequency),
    );

    final double sumSquares = clean.fold<double>(
      0,
      (double total, FrequencyValue item) =>
          total +
          (item.value * item.value * item.frequency),
    );

    final double mean = sum / count;

    double squaredDeviationSum = 0;

    for (final FrequencyValue item in clean) {
      final double difference = item.value - mean;
      squaredDeviationSum +=
          difference * difference * item.frequency;
    }

    final double populationVariance =
        _zeroSmall(squaredDeviationSum / count);

    final double? sampleVariance = count > 1
        ? _zeroSmall(squaredDeviationSum / (count - 1))
        : null;

    final List<FrequencyValue> grouped =
        _groupValues(clean);

    final double median = _weightedMedian(
      grouped,
      count,
    );

    final int highestFrequency = grouped
        .map((FrequencyValue item) => item.frequency)
        .reduce(math.max);

    final bool everyFrequencySame = grouped.every(
      (FrequencyValue item) =>
          item.frequency == highestFrequency,
    );

    final List<double> modes =
        everyFrequencySame && grouped.length > 1
            ? <double>[]
            : grouped
                .where(
                  (FrequencyValue item) =>
                      item.frequency ==
                      highestFrequency,
                )
                .map(
                  (FrequencyValue item) => item.value,
                )
                .toList();

    return OneVariableStatistics(
      count: count,
      sum: _zeroSmall(sum),
      sumSquares: _zeroSmall(sumSquares),
      mean: _zeroSmall(mean),
      median: _zeroSmall(median),
      modes: modes,
      minimum: grouped.first.value,
      maximum: grouped.last.value,
      populationVariance: populationVariance,
      sampleVariance: sampleVariance,
      populationStdDev:
          _zeroSmall(math.sqrt(populationVariance)),
      sampleStdDev: sampleVariance == null
          ? null
          : _zeroSmall(math.sqrt(sampleVariance)),
    );
  }

  TwoVariableStatistics twoVariable(
    List<FrequencyPair> entries,
  ) {
    final List<FrequencyPair> clean = _cleanPairs(entries);

    if (clean.isEmpty) {
      throw const FormatException(
        'Enter at least one x/y data pair.',
      );
    }

    final int count = clean.fold<int>(
      0,
      (int total, FrequencyPair item) =>
          total + item.frequency,
    );

    final double sumX = clean.fold<double>(
      0,
      (double total, FrequencyPair item) =>
          total + (item.x * item.frequency),
    );

    final double sumY = clean.fold<double>(
      0,
      (double total, FrequencyPair item) =>
          total + (item.y * item.frequency),
    );

    final double sumX2 = clean.fold<double>(
      0,
      (double total, FrequencyPair item) =>
          total +
          (item.x * item.x * item.frequency),
    );

    final double sumY2 = clean.fold<double>(
      0,
      (double total, FrequencyPair item) =>
          total +
          (item.y * item.y * item.frequency),
    );

    final double sumXY = clean.fold<double>(
      0,
      (double total, FrequencyPair item) =>
          total +
          (item.x * item.y * item.frequency),
    );

    final double meanX = sumX / count;
    final double meanY = sumY / count;

    double sxx = sumX2 - ((sumX * sumX) / count);
    double syy = sumY2 - ((sumY * sumY) / count);
    double sxy = sumXY - ((sumX * sumY) / count);

    sxx = _zeroSmall(sxx);
    syy = _zeroSmall(syy);
    sxy = _zeroSmall(sxy);

    // Guard against tiny negative values caused by floating-point rounding.
    if (sxx < 0 && sxx.abs() < _epsilon) sxx = 0;
    if (syy < 0 && syy.abs() < _epsilon) syy = 0;

    final double populationVarianceX =
        _zeroSmall(sxx / count);
    final double populationVarianceY =
        _zeroSmall(syy / count);

    final double? sampleVarianceX = count > 1
        ? _zeroSmall(sxx / (count - 1))
        : null;
    final double? sampleVarianceY = count > 1
        ? _zeroSmall(syy / (count - 1))
        : null;

    double? correlation;
    double? slope;
    double? intercept;

    if (sxx > _epsilon) {
      slope = sxy / sxx;
      intercept = meanY - (slope * meanX);
    }

    if (sxx > _epsilon && syy > _epsilon) {
      correlation =
          sxy / math.sqrt(sxx * syy);
      correlation =
          correlation.clamp(-1.0, 1.0).toDouble();
    }

    return TwoVariableStatistics(
      count: count,
      sumX: _zeroSmall(sumX),
      sumY: _zeroSmall(sumY),
      sumX2: _zeroSmall(sumX2),
      sumY2: _zeroSmall(sumY2),
      sumXY: _zeroSmall(sumXY),
      meanX: _zeroSmall(meanX),
      meanY: _zeroSmall(meanY),
      populationVarianceX: populationVarianceX,
      populationVarianceY: populationVarianceY,
      sampleVarianceX: sampleVarianceX,
      sampleVarianceY: sampleVarianceY,
      populationStdDevX:
          _zeroSmall(math.sqrt(populationVarianceX)),
      populationStdDevY:
          _zeroSmall(math.sqrt(populationVarianceY)),
      sampleStdDevX: sampleVarianceX == null
          ? null
          : _zeroSmall(math.sqrt(sampleVarianceX)),
      sampleStdDevY: sampleVarianceY == null
          ? null
          : _zeroSmall(math.sqrt(sampleVarianceY)),
      correlation: correlation == null
          ? null
          : _zeroSmall(correlation),
      regressionSlope:
          slope == null ? null : _zeroSmall(slope),
      regressionIntercept:
          intercept == null ? null : _zeroSmall(intercept),
    );
  }

  List<FrequencyValue> _cleanValues(
    List<FrequencyValue> entries,
  ) {
    final List<FrequencyValue> clean =
        <FrequencyValue>[];

    for (final FrequencyValue item in entries) {
      _validateFrequency(item.frequency);
      _validateFinite(item.value);

      clean.add(item);
    }

    return clean;
  }

  List<FrequencyPair> _cleanPairs(
    List<FrequencyPair> entries,
  ) {
    final List<FrequencyPair> clean =
        <FrequencyPair>[];

    for (final FrequencyPair item in entries) {
      _validateFrequency(item.frequency);
      _validateFinite(item.x);
      _validateFinite(item.y);

      clean.add(item);
    }

    return clean;
  }

  List<FrequencyValue> _groupValues(
    List<FrequencyValue> entries,
  ) {
    final Map<double, int> grouped =
        <double, int>{};

    for (final FrequencyValue item in entries) {
      grouped.update(
        item.value,
        (int current) =>
            current + item.frequency,
        ifAbsent: () => item.frequency,
      );
    }

    final List<FrequencyValue> result =
        grouped.entries
            .map(
              (MapEntry<double, int> entry) =>
                  FrequencyValue(
                value: entry.key,
                frequency: entry.value,
              ),
            )
            .toList()
          ..sort(
            (
              FrequencyValue a,
              FrequencyValue b,
            ) =>
                a.value.compareTo(b.value),
          );

    return result;
  }

  double _weightedMedian(
    List<FrequencyValue> sorted,
    int count,
  ) {
    final int leftIndex = (count - 1) ~/ 2;
    final int rightIndex = count ~/ 2;

    final double left =
        _valueAtWeightedIndex(sorted, leftIndex);
    final double right =
        _valueAtWeightedIndex(sorted, rightIndex);

    return (left + right) / 2;
  }

  double _valueAtWeightedIndex(
    List<FrequencyValue> sorted,
    int target,
  ) {
    int cumulative = 0;

    for (final FrequencyValue item in sorted) {
      cumulative += item.frequency;

      if (target < cumulative) {
        return item.value;
      }
    }

    return sorted.last.value;
  }

  void _validateFrequency(int frequency) {
    if (frequency <= 0) {
      throw const FormatException(
        'Frequency must be a positive whole number.',
      );
    }
  }

  void _validateFinite(double value) {
    if (value.isNaN || value.isInfinite) {
      throw const FormatException(
        'Statistics values must be finite numbers.',
      );
    }
  }

  double _zeroSmall(double value) {
    return value.abs() < _epsilon ? 0 : value;
  }
}
