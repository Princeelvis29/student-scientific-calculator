import 'package:flutter_test/flutter_test.dart';
import 'package:student_scientific_calculator/features/matrix/matrix_engine.dart';

void main() {
  const MatrixEngine engine = MatrixEngine();

  MatrixData matrix2(
    double a,
    double b,
    double c,
    double d,
  ) {
    return MatrixData(
      <List<double>>[
        <double>[a, b],
        <double>[c, d],
      ],
    );
  }

  group('basic matrix operations', () {
    test('addition and subtraction', () {
      final MatrixData a =
          matrix2(1, 2, 3, 4);
      final MatrixData b =
          matrix2(5, 6, 7, 8);

      expect(
        engine.add(a, b),
        matrix2(6, 8, 10, 12),
      );
      expect(
        engine.subtract(b, a),
        matrix2(4, 4, 4, 4),
      );
    });

    test('matrix multiplication', () {
      final MatrixData a =
          matrix2(1, 2, 3, 4);
      final MatrixData b =
          matrix2(5, 6, 7, 8);

      expect(
        engine.multiply(a, b),
        matrix2(19, 22, 43, 50),
      );
    });

    test('scalar multiplication', () {
      expect(
        engine.scalarMultiply(
          matrix2(1, 2, 3, 4),
          2,
        ),
        matrix2(2, 4, 6, 8),
      );
    });

    test('transpose', () {
      expect(
        engine.transpose(
          matrix2(1, 2, 3, 4),
        ),
        matrix2(1, 3, 2, 4),
      );
    });
  });

  group('determinant and inverse', () {
    test('2x2 determinant', () {
      expect(
        engine.determinant(
          matrix2(1, 2, 3, 4),
        ),
        closeTo(-2, 1e-12),
      );
    });

    test('3x3 determinant', () {
      final MatrixData a = MatrixData(
        const <List<double>>[
          <double>[1, 2, 3],
          <double>[0, 1, 4],
          <double>[5, 6, 0],
        ],
      );

      expect(
        engine.determinant(a),
        closeTo(1, 1e-12),
      );
    });

    test('inverse', () {
      final MatrixData inverse =
          engine.inverse(
        matrix2(4, 7, 2, 6),
      );

      expect(
        inverse.at(0, 0),
        closeTo(0.6, 1e-12),
      );
      expect(
        inverse.at(0, 1),
        closeTo(-0.7, 1e-12),
      );
      expect(
        inverse.at(1, 0),
        closeTo(-0.2, 1e-12),
      );
      expect(
        inverse.at(1, 1),
        closeTo(0.4, 1e-12),
      );
    });

    test('singular matrix has no inverse', () {
      expect(
        () => engine.inverse(
          matrix2(1, 2, 2, 4),
        ),
        throwsFormatException,
      );
    });
  });

  group('identity and AX=B', () {
    test('identity 3x3', () {
      final MatrixData identity =
          engine.identity(3);

      expect(
        identity,
        MatrixData(
          const <List<double>>[
            <double>[1, 0, 0],
            <double>[0, 1, 0],
            <double>[0, 0, 1],
          ],
        ),
      );
    });

    test('solves AX=B', () {
      final MatrixData a =
          matrix2(2, 1, 1, 3);
      final MatrixData b =
          matrix2(5, 1, 7, 0);

      final MatrixData x =
          engine.solve(a, b);

      final MatrixData reconstructed =
          engine.multiply(a, x);

      for (int r = 0; r < 2; r++) {
        for (int c = 0; c < 2; c++) {
          expect(
            reconstructed.at(r, c),
            closeTo(b.at(r, c), 1e-10),
          );
        }
      }
    });
  });
}
