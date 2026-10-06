import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'matrix_engine.dart';

enum MatrixOperation {
  add('A + B', 'Addition'),
  subtract('A − B', 'Subtraction'),
  multiply('A × B', 'Multiplication'),
  scalar('k × A', 'Scalar multiplication'),
  determinant('det(A)', 'Determinant'),
  transpose('Aᵀ', 'Transpose'),
  inverse('A⁻¹', 'Inverse'),
  identity('I', 'Identity matrix'),
  solve('AX = B', 'Solve AX = B');

  const MatrixOperation(
    this.symbol,
    this.label,
  );

  final String symbol;
  final String label;

  bool get usesA =>
      this != MatrixOperation.identity;

  bool get usesB =>
      this == MatrixOperation.add ||
      this == MatrixOperation.subtract ||
      this == MatrixOperation.multiply ||
      this == MatrixOperation.solve;

  bool get usesScalar =>
      this == MatrixOperation.scalar;

  bool get producesScalar =>
      this == MatrixOperation.determinant;
}

class MatrixModeScreen extends StatefulWidget {
  const MatrixModeScreen({super.key});

  @override
  State<MatrixModeScreen> createState() =>
      _MatrixModeScreenState();
}

class _MatrixModeScreenState
    extends State<MatrixModeScreen> {
  final MatrixEngine _engine =
      const MatrixEngine();

  MatrixOperation _operation =
      MatrixOperation.add;
  int _size = 2;

  late List<List<TextEditingController>>
      _matrixAControllers;
  late List<List<TextEditingController>>
      _matrixBControllers;

  final TextEditingController _scalarController =
      TextEditingController(text: '2');

  MatrixData? _matrixResult;
  double? _scalarResult;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _rebuildControllers();
  }

  @override
  void dispose() {
    _disposeMatrixControllers(
      _matrixAControllers,
    );
    _disposeMatrixControllers(
      _matrixBControllers,
    );
    _scalarController.dispose();
    super.dispose();
  }

  void _disposeMatrixControllers(
    List<List<TextEditingController>>
        controllers,
  ) {
    for (final List<TextEditingController> row
        in controllers) {
      for (final TextEditingController controller
          in row) {
        controller.dispose();
      }
    }
  }

  List<List<TextEditingController>>
      _createControllers(int size) {
    return List<List<TextEditingController>>.generate(
      size,
      (int r) =>
          List<TextEditingController>.generate(
        size,
        (int c) => TextEditingController(),
      ),
    );
  }

  void _rebuildControllers() {
    _matrixAControllers =
        _createControllers(_size);
    _matrixBControllers =
        _createControllers(_size);
    _matrixResult = null;
    _scalarResult = null;
    _validationMessage = null;
  }

  void _changeSize(int? size) {
    if (size == null || size == _size) return;

    setState(() {
      _disposeMatrixControllers(
        _matrixAControllers,
      );
      _disposeMatrixControllers(
        _matrixBControllers,
      );
      _size = size;
      _rebuildControllers();
    });
  }

  void _changeOperation(
    MatrixOperation? operation,
  ) {
    if (operation == null) return;

    setState(() {
      _operation = operation;
      _matrixResult = null;
      _scalarResult = null;
      _validationMessage = null;
    });
  }

  MatrixData _readMatrix(
    List<List<TextEditingController>>
        controllers,
    String name,
  ) {
    return MatrixData(
      List<List<double>>.generate(
        _size,
        (int r) => List<double>.generate(
          _size,
          (int c) {
            final String raw =
                controllers[r][c].text.trim();

            if (raw.isEmpty) {
              throw FormatException(
                '$name row ${r + 1}, column ${c + 1}: '
                'enter a value.',
              );
            }

            return _parseNumber(
              raw,
              label:
                  '$name[${r + 1},${c + 1}]',
            );
          },
        ),
      ),
    );
  }

  double _parseNumber(
    String raw, {
    required String label,
  }) {
    final double? direct =
        double.tryParse(raw);

    if (direct != null &&
        direct.isFinite) {
      return direct;
    }

    if (raw.contains('/')) {
      final List<String> parts =
          raw.split('/');

      if (parts.length == 2) {
        final double? numerator =
            double.tryParse(
          parts[0].trim(),
        );
        final double? denominator =
            double.tryParse(
          parts[1].trim(),
        );

        if (numerator != null &&
            denominator != null &&
            denominator != 0) {
          return numerator / denominator;
        }
      }
    }

    throw FormatException(
      '$label: “$raw” is not a valid number. '
      'Decimals and fractions such as 1/2 are supported.',
    );
  }

  void _calculate() {
    FocusScope.of(context).unfocus();

    try {
      MatrixData? matrix;
      double? scalar;

      final MatrixData? a =
          _operation.usesA
              ? _readMatrix(
                  _matrixAControllers,
                  'A',
                )
              : null;

      final MatrixData? b =
          _operation.usesB
              ? _readMatrix(
                  _matrixBControllers,
                  'B',
                )
              : null;

      switch (_operation) {
        case MatrixOperation.add:
          matrix = _engine.add(a!, b!);
          break;

        case MatrixOperation.subtract:
          matrix =
              _engine.subtract(a!, b!);
          break;

        case MatrixOperation.multiply:
          matrix =
              _engine.multiply(a!, b!);
          break;

        case MatrixOperation.scalar:
          final String raw =
              _scalarController.text.trim();

          if (raw.isEmpty) {
            throw const FormatException(
              'Enter a scalar value k.',
            );
          }

          final double k = _parseNumber(
            raw,
            label: 'Scalar k',
          );

          matrix =
              _engine.scalarMultiply(a!, k);
          break;

        case MatrixOperation.determinant:
          scalar =
              _engine.determinant(a!);
          break;

        case MatrixOperation.transpose:
          matrix =
              _engine.transpose(a!);
          break;

        case MatrixOperation.inverse:
          matrix = _engine.inverse(a!);
          break;

        case MatrixOperation.identity:
          matrix =
              _engine.identity(_size);
          break;

        case MatrixOperation.solve:
          matrix =
              _engine.solve(a!, b!);
          break;
      }

      setState(() {
        _matrixResult = matrix;
        _scalarResult = scalar;
        _validationMessage = null;
      });
    } on FormatException catch (error) {
      setState(() {
        _matrixResult = null;
        _scalarResult = null;
        _validationMessage =
            error.message.toString();
      });
    }
  }

  void _clear() {
    setState(() {
      for (final List<TextEditingController> row
          in _matrixAControllers) {
        for (final TextEditingController controller
            in row) {
          controller.clear();
        }
      }

      for (final List<TextEditingController> row
          in _matrixBControllers) {
        for (final TextEditingController controller
            in row) {
          controller.clear();
        }
      }

      _scalarController.text = '2';
      _matrixResult = null;
      _scalarResult = null;
      _validationMessage = null;
    });
  }

  void _loadExample() {
    setState(() {
      _clearControllerValues();

      if (_size == 2) {
        _setControllerMatrix(
          _matrixAControllers,
          const <List<double>>[
            <double>[1, 2],
            <double>[3, 4],
          ],
        );

        _setControllerMatrix(
          _matrixBControllers,
          const <List<double>>[
            <double>[5, 6],
            <double>[7, 8],
          ],
        );
      } else {
        _setControllerMatrix(
          _matrixAControllers,
          const <List<double>>[
            <double>[2, 1, 0],
            <double>[1, 2, 1],
            <double>[0, 1, 2],
          ],
        );

        _setControllerMatrix(
          _matrixBControllers,
          const <List<double>>[
            <double>[1, 0, 0],
            <double>[0, 1, 0],
            <double>[0, 0, 1],
          ],
        );
      }

      _scalarController.text = '2';
      _matrixResult = null;
      _scalarResult = null;
      _validationMessage = null;
    });
  }

  void _clearControllerValues() {
    for (final List<TextEditingController> row
        in _matrixAControllers) {
      for (final TextEditingController controller
          in row) {
        controller.clear();
      }
    }

    for (final List<TextEditingController> row
        in _matrixBControllers) {
      for (final TextEditingController controller
          in row) {
        controller.clear();
      }
    }
  }

  void _setControllerMatrix(
    List<List<TextEditingController>>
        controllers,
    List<List<double>> values,
  ) {
    for (int r = 0; r < _size; r++) {
      for (int c = 0; c < _size; c++) {
        controllers[r][c].text =
            _format(values[r][c]);
      }
    }
  }

  void _useResultAsA() {
    final MatrixData? result =
        _matrixResult;

    if (result == null ||
        result.rows != _size ||
        result.columns != _size) {
      return;
    }

    setState(() {
      _setControllerMatrix(
        _matrixAControllers,
        result.values,
      );
      _matrixResult = null;
      _scalarResult = null;
      _validationMessage = null;
    });
  }

  void _useResultAsB() {
    final MatrixData? result =
        _matrixResult;

    if (result == null ||
        result.rows != _size ||
        result.columns != _size) {
      return;
    }

    setState(() {
      _setControllerMatrix(
        _matrixBControllers,
        result.values,
      );
      _matrixResult = null;
      _scalarResult = null;
      _validationMessage = null;
    });
  }

  String _format(double value) {
    if (value == 0) return '0';

    final double rounded =
        value.roundToDouble();

    if ((value - rounded).abs() < 1e-12 &&
        value.abs() < 1e15) {
      return rounded.toInt().toString();
    }

    String text =
        value.toStringAsPrecision(10);

    if (!text.contains('e') &&
        !text.contains('E')) {
      text = text.replaceFirst(
        RegExp(r'\.?0+$'),
        '',
      );
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MATRIX Mode'),
        backgroundColor:
            AppTheme.background,
        surfaceTintColor:
            AppTheme.background,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 980,
            ),
            child: ListView(
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                28,
              ),
              children: <Widget>[
                _buildSettingsCard(),
                const SizedBox(height: 16),
                if (_operation.usesA)
                  _buildMatrixCard(
                    title: 'Matrix A',
                    controllers:
                        _matrixAControllers,
                  ),
                if (_operation.usesB) ...<
                    Widget>[
                  const SizedBox(height: 14),
                  _buildMatrixCard(
                    title: 'Matrix B',
                    controllers:
                        _matrixBControllers,
                  ),
                ],
                if (_operation.usesScalar) ...<
                    Widget>[
                  const SizedBox(height: 14),
                  _buildScalarCard(),
                ],
                const SizedBox(height: 14),
                _buildActions(),
                if (_validationMessage != null) ...<
                    Widget>[
                  const SizedBox(height: 14),
                  _buildValidationMessage(),
                ],
                if (_matrixResult != null ||
                    _scalarResult != null) ...<
                    Widget>[
                  const SizedBox(height: 18),
                  _buildResultCard(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.display,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF334155),
        ),
      ),
      child: Column(
        children: <Widget>[
          DropdownButtonFormField<
              MatrixOperation>(
            value: _operation,
            decoration:
                const InputDecoration(
              labelText: 'Operation',
              border:
                  OutlineInputBorder(),
            ),
            items: MatrixOperation.values
                .map(
                  (MatrixOperation operation) =>
                      DropdownMenuItem<
                          MatrixOperation>(
                    value: operation,
                    child: Text(
                      '${operation.symbol} — '
                      '${operation.label}',
                    ),
                  ),
                )
                .toList(),
            onChanged: _changeOperation,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _size,
            decoration:
                const InputDecoration(
              labelText: 'Matrix size',
              border:
                  OutlineInputBorder(),
            ),
            items: const <DropdownMenuItem<int>>[
              DropdownMenuItem<int>(
                value: 2,
                child: Text('2 × 2'),
              ),
              DropdownMenuItem<int>(
                value: 3,
                child: Text('3 × 3'),
              ),
            ],
            onChanged: _changeSize,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _operation ==
                      MatrixOperation.solve
                  ? 'Solves the matrix equation AX = B.'
                  : _operation ==
                          MatrixOperation.identity
                      ? 'Creates the identity matrix for the selected size.'
                      : 'Matrix A and B act as working memory while this screen is open.',
              style: const TextStyle(
                color:
                    AppTheme.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixCard({
    required String title,
    required List<
            List<TextEditingController>>
        controllers,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.display,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF334155),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _MatrixInputGrid(
            controllers: controllers,
          ),
        ],
      ),
    );
  }

  Widget _buildScalarCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.display,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF334155),
        ),
      ),
      child: TextField(
        controller: _scalarController,
        keyboardType:
            const TextInputType.numberWithOptions(
          signed: true,
          decimal: true,
        ),
        decoration:
            const InputDecoration(
          labelText: 'Scalar k',
          hintText: '2',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: <Widget>[
        FilledButton.icon(
          onPressed: _calculate,
          icon: const Icon(
            Icons.calculate_outlined,
          ),
          label:
              const Text('Calculate'),
          style: FilledButton.styleFrom(
            backgroundColor:
                const Color(0xFFF6B45F),
            foregroundColor:
                const Color(0xFF2B1A04),
          ),
        ),
        OutlinedButton.icon(
          onPressed: _loadExample,
          icon: const Icon(
            Icons.science_outlined,
          ),
          label:
              const Text('Load example'),
        ),
        OutlinedButton.icon(
          onPressed: _clear,
          icon:
              const Icon(Icons.refresh),
          label: const Text('Clear'),
        ),
      ],
    );
  }

  Widget _buildValidationMessage() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF7F1D1D)
            .withOpacity(0.22),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFB91C1C),
        ),
      ),
      child: Text(
        _validationMessage!,
        style: const TextStyle(
          color: Color(0xFFFECACA),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.display,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF334155),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            _operation.producesScalar
                ? 'Result'
                : 'Result matrix',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          if (_scalarResult != null)
            Container(
              padding:
                  const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    AppTheme.numberKey,
                borderRadius:
                    BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(
                    0xFF334155,
                  ),
                ),
              ),
              child: Text(
                _format(_scalarResult!),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          if (_matrixResult != null) ...<
              Widget>[
            _MatrixResultGrid(
              matrix: _matrixResult!,
              format: _format,
            ),
            if (_matrixResult!.rows ==
                    _size &&
                _matrixResult!.columns ==
                    _size) ...<Widget>[
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed:
                        _useResultAsA,
                    icon: const Icon(
                      Icons.save_alt,
                    ),
                    label: const Text(
                      'Use result as A',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed:
                        _useResultAsB,
                    icon: const Icon(
                      Icons.save_alt,
                    ),
                    label: const Text(
                      'Use result as B',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _MatrixInputGrid extends StatelessWidget {
  const _MatrixInputGrid({
    required this.controllers,
  });

  final List<List<TextEditingController>>
      controllers;

  @override
  Widget build(BuildContext context) {
    final int size = controllers.length;

    return Column(
      children: List<Widget>.generate(
        size,
        (int r) => Padding(
          padding:
              const EdgeInsets.only(
            bottom: 8,
          ),
          child: Row(
            children:
                List<Widget>.generate(
              size,
              (int c) => Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  child: TextField(
                    controller:
                        controllers[r][c],
                    textAlign:
                        TextAlign.center,
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      signed: true,
                      decimal: true,
                    ),
                    decoration:
                        InputDecoration(
                      hintText:
                          'a${r + 1}${c + 1}',
                      isDense: true,
                      border:
                          const OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MatrixResultGrid extends StatelessWidget {
  const _MatrixResultGrid({
    required this.matrix,
    required this.format,
  });

  final MatrixData matrix;
  final String Function(double) format;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppTheme.numberKey,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF334155),
        ),
      ),
      child: Column(
        children: List<Widget>.generate(
          matrix.rows,
          (int r) => Padding(
            padding:
                const EdgeInsets.symmetric(
              vertical: 5,
            ),
            child: Row(
              children:
                  List<Widget>.generate(
                matrix.columns,
                (int c) => Expanded(
                  child: Text(
                    format(matrix.at(r, c)),
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
