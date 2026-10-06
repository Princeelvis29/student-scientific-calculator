import 'package:flutter_test/flutter_test.dart';
import 'package:student_scientific_calculator/features/complex/complex_engine.dart';

void main() {
  const ComplexEngine engine = ComplexEngine();

  group('complex arithmetic', () {
    test('addition and multiplication', () {
      const ComplexNumber a = ComplexNumber(3, 4);
      const ComplexNumber b = ComplexNumber(1, -2);

      final ComplexNumber sum = engine.add(a, b);
      expect(sum.real, closeTo(4, 1e-12));
      expect(sum.imaginary, closeTo(2, 1e-12));

      final ComplexNumber product =
          engine.multiply(a, b);
      expect(product.real, closeTo(11, 1e-12));
      expect(product.imaginary, closeTo(-2, 1e-12));
    });

    test('division', () {
      const ComplexNumber a = ComplexNumber(3, 4);
      const ComplexNumber b = ComplexNumber(1, -2);

      final ComplexNumber result =
          engine.divide(a, b);

      expect(result.real, closeTo(-1, 1e-12));
      expect(result.imaginary, closeTo(2, 1e-12));
    });

    test('magnitude and argument', () {
      const ComplexNumber value =
          ComplexNumber(3, 4);

      expect(
        engine.magnitude(value),
        closeTo(5, 1e-12),
      );

      expect(
        engine.argumentDegrees(value),
        closeTo(53.1301023542, 1e-10),
      );
    });

    test('polar conversion round trip', () {
      const ComplexNumber value =
          ComplexNumber(1, 1);

      final PolarComplex polar =
          engine.toPolar(value);

      final ComplexNumber restored =
          engine.fromPolar(
        magnitude: polar.magnitude,
        angleDegrees: polar.angleDegrees,
      );

      expect(restored.real, closeTo(1, 1e-10));
      expect(restored.imaginary, closeTo(1, 1e-10));
    });

    test('integer power', () {
      final ComplexNumber result =
          engine.integerPower(
        const ComplexNumber(1, 1),
        2,
      );

      expect(result.real, closeTo(0, 1e-12));
      expect(result.imaginary, closeTo(2, 1e-12));
    });
  });
}
