import 'dart:math' as math;

class ComplexNumber {
  const ComplexNumber(
    this.real,
    this.imaginary,
  );

  final double real;
  final double imaginary;

  bool get isFinite =>
      real.isFinite && imaginary.isFinite;
}

class PolarComplex {
  const PolarComplex({
    required this.magnitude,
    required this.angleDegrees,
  });

  final double magnitude;
  final double angleDegrees;
}

class ComplexEngine {
  const ComplexEngine();

  static const double epsilon = 1e-12;

  ComplexNumber add(
    ComplexNumber a,
    ComplexNumber b,
  ) {
    return _cleanComplex(
      ComplexNumber(
        a.real + b.real,
        a.imaginary + b.imaginary,
      ),
    );
  }

  ComplexNumber subtract(
    ComplexNumber a,
    ComplexNumber b,
  ) {
    return _cleanComplex(
      ComplexNumber(
        a.real - b.real,
        a.imaginary - b.imaginary,
      ),
    );
  }

  ComplexNumber multiply(
    ComplexNumber a,
    ComplexNumber b,
  ) {
    return _cleanComplex(
      ComplexNumber(
        (a.real * b.real) -
            (a.imaginary * b.imaginary),
        (a.real * b.imaginary) +
            (a.imaginary * b.real),
      ),
    );
  }

  ComplexNumber divide(
    ComplexNumber a,
    ComplexNumber b,
  ) {
    final double denominator =
        (b.real * b.real) +
        (b.imaginary * b.imaginary);

    if (denominator < epsilon) {
      throw const FormatException(
        'Cannot divide by 0 + 0i.',
      );
    }

    return _cleanComplex(
      ComplexNumber(
        ((a.real * b.real) +
                (a.imaginary * b.imaginary)) /
            denominator,
        ((a.imaginary * b.real) -
                (a.real * b.imaginary)) /
            denominator,
      ),
    );
  }

  ComplexNumber conjugate(ComplexNumber value) {
    return _cleanComplex(
      ComplexNumber(
        value.real,
        -value.imaginary,
      ),
    );
  }

  double magnitude(ComplexNumber value) {
    return _clean(
      math.sqrt(
        (value.real * value.real) +
            (value.imaginary * value.imaginary),
      ),
    );
  }

  double argumentDegrees(ComplexNumber value) {
    if (magnitude(value) < epsilon) {
      throw const FormatException(
        'The argument of 0 + 0i is undefined.',
      );
    }

    return _clean(
      math.atan2(
            value.imaginary,
            value.real,
          ) *
          180 /
          math.pi,
    );
  }

  PolarComplex toPolar(ComplexNumber value) {
    return PolarComplex(
      magnitude: magnitude(value),
      angleDegrees: argumentDegrees(value),
    );
  }

  ComplexNumber fromPolar({
    required double magnitude,
    required double angleDegrees,
  }) {
    if (!magnitude.isFinite ||
        !angleDegrees.isFinite) {
      throw const FormatException(
        'Polar values must be finite numbers.',
      );
    }

    if (magnitude < 0) {
      throw const FormatException(
        'Polar magnitude cannot be negative.',
      );
    }

    final double radians =
        angleDegrees * math.pi / 180;

    return _cleanComplex(
      ComplexNumber(
        magnitude * math.cos(radians),
        magnitude * math.sin(radians),
      ),
    );
  }

  ComplexNumber integerPower(
    ComplexNumber value,
    int exponent,
  ) {
    if (exponent == 0) {
      return const ComplexNumber(1, 0);
    }

    if (exponent < 0) {
      return divide(
        const ComplexNumber(1, 0),
        integerPower(value, -exponent),
      );
    }

    ComplexNumber result =
        const ComplexNumber(1, 0);
    ComplexNumber base = value;
    int power = exponent;

    while (power > 0) {
      if (power.isOdd) {
        result = multiply(result, base);
      }

      base = multiply(base, base);
      power ~/= 2;
    }

    return _cleanComplex(result);
  }

  ComplexNumber _cleanComplex(
    ComplexNumber value,
  ) {
    if (!value.isFinite) {
      throw const FormatException(
        'Complex result is not finite.',
      );
    }

    return ComplexNumber(
      _clean(value.real),
      _clean(value.imaginary),
    );
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
