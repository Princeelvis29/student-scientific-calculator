import 'dart:math' as math;

class VectorData {
  VectorData(List<double> components)
      : components = List<double>.from(components) {
    if (this.components.length != 2 &&
        this.components.length != 3) {
      throw const FormatException(
        'Vectors must be 2D or 3D.',
      );
    }

    for (final double value in this.components) {
      if (value.isNaN || value.isInfinite) {
        throw const FormatException(
          'Vector components must be finite numbers.',
        );
      }
    }
  }

  final List<double> components;

  int get dimension => components.length;

  double at(int index) => components[index];

  @override
  bool operator ==(Object other) {
    if (other is! VectorData ||
        dimension != other.dimension) {
      return false;
    }

    const double epsilon = 1e-10;

    for (int i = 0; i < dimension; i++) {
      if ((at(i) - other.at(i)).abs() > epsilon) {
        return false;
      }
    }

    return true;
  }

  @override
  int get hashCode => Object.hashAll(components);
}

class VectorEngine {
  const VectorEngine();

  static const double epsilon = 1e-12;

  VectorData add(VectorData a, VectorData b) {
    _requireSameDimension(a, b);

    return VectorData(
      List<double>.generate(
        a.dimension,
        (int i) => _clean(a.at(i) + b.at(i)),
      ),
    );
  }

  VectorData subtract(VectorData a, VectorData b) {
    _requireSameDimension(a, b);

    return VectorData(
      List<double>.generate(
        a.dimension,
        (int i) => _clean(a.at(i) - b.at(i)),
      ),
    );
  }

  VectorData scalarMultiply(
    VectorData vector,
    double scalar,
  ) {
    if (scalar.isNaN || scalar.isInfinite) {
      throw const FormatException(
        'Scalar must be a finite number.',
      );
    }

    return VectorData(
      vector.components
          .map((double value) => _clean(value * scalar))
          .toList(),
    );
  }

  double dot(VectorData a, VectorData b) {
    _requireSameDimension(a, b);

    double total = 0;

    for (int i = 0; i < a.dimension; i++) {
      total += a.at(i) * b.at(i);
    }

    return _clean(total);
  }

  VectorData cross(VectorData a, VectorData b) {
    _requireSameDimension(a, b);

    if (a.dimension != 3) {
      throw const FormatException(
        'Cross product is defined here for 3D vectors only.',
      );
    }

    return VectorData(
      <double>[
        _clean(
          a.at(1) * b.at(2) -
              a.at(2) * b.at(1),
        ),
        _clean(
          a.at(2) * b.at(0) -
              a.at(0) * b.at(2),
        ),
        _clean(
          a.at(0) * b.at(1) -
              a.at(1) * b.at(0),
        ),
      ],
    );
  }

  double magnitude(VectorData vector) {
    final double squared = vector.components.fold<double>(
      0,
      (double total, double value) =>
          total + (value * value),
    );

    return _clean(math.sqrt(squared));
  }

  VectorData normalize(VectorData vector) {
    final double length = magnitude(vector);

    if (length < epsilon) {
      throw const FormatException(
        'The zero vector cannot be normalized.',
      );
    }

    return scalarMultiply(vector, 1 / length);
  }

  double angleDegrees(VectorData a, VectorData b) {
    _requireSameDimension(a, b);

    final double denominator =
        magnitude(a) * magnitude(b);

    if (denominator < epsilon) {
      throw const FormatException(
        'Angle is undefined for a zero vector.',
      );
    }

    final double cosine =
        (dot(a, b) / denominator)
            .clamp(-1.0, 1.0)
            .toDouble();

    return _clean(
      math.acos(cosine) * 180 / math.pi,
    );
  }

  VectorData projection(
    VectorData a,
    VectorData onto,
  ) {
    _requireSameDimension(a, onto);

    final double denominator = dot(onto, onto);

    if (denominator.abs() < epsilon) {
      throw const FormatException(
        'Cannot project onto the zero vector.',
      );
    }

    final double scale = dot(a, onto) / denominator;

    return scalarMultiply(onto, scale);
  }

  void _requireSameDimension(
    VectorData a,
    VectorData b,
  ) {
    if (a.dimension != b.dimension) {
      throw FormatException(
        'Vector dimensions must match: '
        '${a.dimension}D and ${b.dimension}D.',
      );
    }
  }

  double _clean(double value) {
    if (value.abs() < epsilon) return 0;

    final double rounded = value.roundToDouble();

    if ((value - rounded).abs() < epsilon) {
      return rounded;
    }

    return value;
  }
}
