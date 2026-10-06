import 'dart:math' as math;

class MatrixData {
  MatrixData(List<List<double>> values)
      : values = values
            .map((List<double> row) => List<double>.from(row))
            .toList() {
    if (this.values.isEmpty || this.values.first.isEmpty) {
      throw const FormatException('Matrix cannot be empty.');
    }

    final int width = this.values.first.length;

    for (final List<double> row in this.values) {
      if (row.length != width) {
        throw const FormatException(
          'Every matrix row must have the same number of columns.',
        );
      }

      for (final double value in row) {
        if (value.isNaN || value.isInfinite) {
          throw const FormatException(
            'Matrix entries must be finite numbers.',
          );
        }
      }
    }
  }

  final List<List<double>> values;

  int get rows => values.length;
  int get columns => values.first.length;

  double at(int row, int column) => values[row][column];

  MatrixData copy() => MatrixData(values);

  @override
  bool operator ==(Object other) {
    if (other is! MatrixData ||
        rows != other.rows ||
        columns != other.columns) {
      return false;
    }

    const double epsilon = 1e-10;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if ((at(r, c) - other.at(r, c)).abs() > epsilon) {
          return false;
        }
      }
    }

    return true;
  }

  @override
  int get hashCode => Object.hash(rows, columns);
}

class MatrixEngine {
  const MatrixEngine();

  static const double epsilon = 1e-12;

  MatrixData add(MatrixData a, MatrixData b) {
    _requireSameShape(a, b);

    return MatrixData(
      List<List<double>>.generate(
        a.rows,
        (int r) => List<double>.generate(
          a.columns,
          (int c) => _clean(a.at(r, c) + b.at(r, c)),
        ),
      ),
    );
  }

  MatrixData subtract(MatrixData a, MatrixData b) {
    _requireSameShape(a, b);

    return MatrixData(
      List<List<double>>.generate(
        a.rows,
        (int r) => List<double>.generate(
          a.columns,
          (int c) => _clean(a.at(r, c) - b.at(r, c)),
        ),
      ),
    );
  }

  MatrixData multiply(MatrixData a, MatrixData b) {
    if (a.columns != b.rows) {
      throw FormatException(
        'Cannot multiply ${a.rows}×${a.columns} by '
        '${b.rows}×${b.columns}.',
      );
    }

    return MatrixData(
      List<List<double>>.generate(
        a.rows,
        (int r) => List<double>.generate(
          b.columns,
          (int c) {
            double total = 0;

            for (int k = 0; k < a.columns; k++) {
              total += a.at(r, k) * b.at(k, c);
            }

            return _clean(total);
          },
        ),
      ),
    );
  }

  MatrixData scalarMultiply(
    MatrixData matrix,
    double scalar,
  ) {
    if (scalar.isNaN || scalar.isInfinite) {
      throw const FormatException(
        'Scalar must be a finite number.',
      );
    }

    return MatrixData(
      List<List<double>>.generate(
        matrix.rows,
        (int r) => List<double>.generate(
          matrix.columns,
          (int c) => _clean(matrix.at(r, c) * scalar),
        ),
      ),
    );
  }

  MatrixData transpose(MatrixData matrix) {
    return MatrixData(
      List<List<double>>.generate(
        matrix.columns,
        (int r) => List<double>.generate(
          matrix.rows,
          (int c) => matrix.at(c, r),
        ),
      ),
    );
  }

  MatrixData identity(int size) {
    if (size <= 0) {
      throw const FormatException(
        'Identity matrix size must be positive.',
      );
    }

    return MatrixData(
      List<List<double>>.generate(
        size,
        (int r) => List<double>.generate(
          size,
          (int c) => r == c ? 1 : 0,
        ),
      ),
    );
  }

  double determinant(MatrixData matrix) {
    _requireSquare(matrix);

    final int n = matrix.rows;
    final List<List<double>> working =
        matrix.values
            .map((List<double> row) => List<double>.from(row))
            .toList();

    double det = 1;
    int sign = 1;

    for (int pivotColumn = 0;
        pivotColumn < n;
        pivotColumn++) {
      int pivotRow = pivotColumn;
      double pivotMagnitude =
          working[pivotRow][pivotColumn].abs();

      for (int row = pivotColumn + 1; row < n; row++) {
        final double magnitude =
            working[row][pivotColumn].abs();

        if (magnitude > pivotMagnitude) {
          pivotMagnitude = magnitude;
          pivotRow = row;
        }
      }

      if (pivotMagnitude < epsilon) {
        return 0;
      }

      if (pivotRow != pivotColumn) {
        final List<double> temporary = working[pivotRow];
        working[pivotRow] = working[pivotColumn];
        working[pivotColumn] = temporary;
        sign *= -1;
      }

      final double pivot = working[pivotColumn][pivotColumn];
      det *= pivot;

      for (int row = pivotColumn + 1; row < n; row++) {
        final double factor =
            working[row][pivotColumn] / pivot;

        for (int column = pivotColumn + 1;
            column < n;
            column++) {
          working[row][column] -=
              factor * working[pivotColumn][column];
        }
      }
    }

    return _clean(det * sign);
  }

  MatrixData inverse(MatrixData matrix) {
    _requireSquare(matrix);

    final int n = matrix.rows;
    final List<List<double>> augmented =
        List<List<double>>.generate(
      n,
      (int r) => <double>[
        ...matrix.values[r],
        ...List<double>.generate(
          n,
          (int c) => r == c ? 1 : 0,
        ),
      ],
    );

    for (int pivotColumn = 0;
        pivotColumn < n;
        pivotColumn++) {
      int pivotRow = pivotColumn;
      double pivotMagnitude =
          augmented[pivotRow][pivotColumn].abs();

      for (int row = pivotColumn + 1; row < n; row++) {
        final double magnitude =
            augmented[row][pivotColumn].abs();

        if (magnitude > pivotMagnitude) {
          pivotMagnitude = magnitude;
          pivotRow = row;
        }
      }

      if (pivotMagnitude < epsilon) {
        throw const FormatException(
          'Matrix is singular and has no inverse.',
        );
      }

      if (pivotRow != pivotColumn) {
        final List<double> temporary = augmented[pivotRow];
        augmented[pivotRow] = augmented[pivotColumn];
        augmented[pivotColumn] = temporary;
      }

      final double pivot = augmented[pivotColumn][pivotColumn];

      for (int column = 0; column < 2 * n; column++) {
        augmented[pivotColumn][column] /= pivot;
      }

      for (int row = 0; row < n; row++) {
        if (row == pivotColumn) continue;

        final double factor = augmented[row][pivotColumn];

        for (int column = 0; column < 2 * n; column++) {
          augmented[row][column] -=
              factor * augmented[pivotColumn][column];
        }
      }
    }

    return MatrixData(
      List<List<double>>.generate(
        n,
        (int r) => List<double>.generate(
          n,
          (int c) => _clean(augmented[r][n + c]),
        ),
      ),
    );
  }

  MatrixData solve(MatrixData a, MatrixData b) {
    _requireSquare(a);

    if (a.rows != b.rows) {
      throw FormatException(
        'A has ${a.rows} rows but B has ${b.rows}. '
        'AX = B requires the same number of rows.',
      );
    }

    return multiply(inverse(a), b);
  }

  void _requireSquare(MatrixData matrix) {
    if (matrix.rows != matrix.columns) {
      throw FormatException(
        'This operation requires a square matrix, but received '
        '${matrix.rows}×${matrix.columns}.',
      );
    }
  }

  void _requireSameShape(
    MatrixData a,
    MatrixData b,
  ) {
    if (a.rows != b.rows || a.columns != b.columns) {
      throw FormatException(
        'Matrices must have the same dimensions. '
        'A is ${a.rows}×${a.columns}; '
        'B is ${b.rows}×${b.columns}.',
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
