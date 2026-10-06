import 'package:flutter_test/flutter_test.dart';
import 'package:student_scientific_calculator/features/vector/vector_engine.dart';

void main() {
  const VectorEngine engine = VectorEngine();

  group('vector operations', () {
    test('2D add/subtract and magnitude', () {
      final VectorData a = VectorData(<double>[3, 4]);
      final VectorData b = VectorData(<double>[1, 2]);

      expect(
        engine.add(a, b),
        VectorData(<double>[4, 6]),
      );
      expect(
        engine.subtract(a, b),
        VectorData(<double>[2, 2]),
      );
      expect(
        engine.magnitude(a),
        closeTo(5, 1e-12),
      );
    });

    test('dot and angle', () {
      final VectorData x = VectorData(<double>[1, 0]);
      final VectorData y = VectorData(<double>[0, 1]);

      expect(engine.dot(x, y), closeTo(0, 1e-12));
      expect(
        engine.angleDegrees(x, y),
        closeTo(90, 1e-12),
      );
    });

    test('normalize', () {
      final VectorData result =
          engine.normalize(
        VectorData(<double>[3, 4]),
      );

      expect(result.at(0), closeTo(0.6, 1e-12));
      expect(result.at(1), closeTo(0.8, 1e-12));
    });

    test('3D cross product', () {
      final VectorData result = engine.cross(
        VectorData(<double>[1, 0, 0]),
        VectorData(<double>[0, 1, 0]),
      );

      expect(
        result,
        VectorData(<double>[0, 0, 1]),
      );
    });

    test('projection', () {
      final VectorData result =
          engine.projection(
        VectorData(<double>[3, 4]),
        VectorData(<double>[1, 0]),
      );

      expect(
        result,
        VectorData(<double>[3, 0]),
      );
    });
  });
}
