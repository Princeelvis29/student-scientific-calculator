import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'vector_engine.dart';

enum VectorOperation {
  add('A + B', 'Addition'),
  subtract('A − B', 'Subtraction'),
  scalar('kA', 'Scalar multiplication'),
  dot('A · B', 'Dot product'),
  cross('A × B', 'Cross product'),
  magnitude('|A|', 'Magnitude'),
  normalize('Â', 'Normalize A'),
  angle('∠(A,B)', 'Angle between vectors'),
  projection('projᵦ(A)', 'Projection of A onto B');

  const VectorOperation(this.symbol, this.label);

  final String symbol;
  final String label;

  bool get usesB =>
      this == VectorOperation.add ||
      this == VectorOperation.subtract ||
      this == VectorOperation.dot ||
      this == VectorOperation.cross ||
      this == VectorOperation.angle ||
      this == VectorOperation.projection;

  bool get usesScalar =>
      this == VectorOperation.scalar;

  bool get producesScalar =>
      this == VectorOperation.dot ||
      this == VectorOperation.magnitude ||
      this == VectorOperation.angle;
}

class VectorModeScreen extends StatefulWidget {
  const VectorModeScreen({super.key});

  @override
  State<VectorModeScreen> createState() =>
      _VectorModeScreenState();
}

class _VectorModeScreenState
    extends State<VectorModeScreen> {
  final VectorEngine _engine = const VectorEngine();

  int _dimension = 2;
  VectorOperation _operation = VectorOperation.add;

  late List<TextEditingController> _aControllers;
  late List<TextEditingController> _bControllers;

  final TextEditingController _scalarController =
      TextEditingController(text: '2');

  VectorData? _vectorResult;
  double? _scalarResult;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _rebuildControllers();
  }

  @override
  void dispose() {
    _disposeVectorControllers(_aControllers);
    _disposeVectorControllers(_bControllers);
    _scalarController.dispose();
    super.dispose();
  }

  void _disposeVectorControllers(
    List<TextEditingController> controllers,
  ) {
    for (final TextEditingController controller
        in controllers) {
      controller.dispose();
    }
  }

  void _rebuildControllers() {
    _aControllers =
        List<TextEditingController>.generate(
      _dimension,
      (int index) => TextEditingController(),
    );
    _bControllers =
        List<TextEditingController>.generate(
      _dimension,
      (int index) => TextEditingController(),
    );

    _vectorResult = null;
    _scalarResult = null;
    _validationMessage = null;
  }

  void _changeDimension(int? dimension) {
    if (dimension == null ||
        dimension == _dimension) {
      return;
    }

    setState(() {
      _disposeVectorControllers(_aControllers);
      _disposeVectorControllers(_bControllers);
      _dimension = dimension;
      _rebuildControllers();

      if (_dimension == 2 &&
          _operation == VectorOperation.cross) {
        _operation = VectorOperation.add;
      }
    });
  }

  void _changeOperation(
    VectorOperation? operation,
  ) {
    if (operation == null) return;

    if (_dimension == 2 &&
        operation == VectorOperation.cross) {
      setState(() {
        _validationMessage =
            'Cross product requires 3D vectors.';
      });
      return;
    }

    setState(() {
      _operation = operation;
      _vectorResult = null;
      _scalarResult = null;
      _validationMessage = null;
    });
  }

  VectorData _readVector(
    List<TextEditingController> controllers,
    String name,
  ) {
    return VectorData(
      List<double>.generate(
        _dimension,
        (int index) {
          final String raw =
              controllers[index].text.trim();

          if (raw.isEmpty) {
            throw FormatException(
              '$name component ${index + 1}: enter a value.',
            );
          }

          return _parseNumber(
            raw,
            label: '$name[${index + 1}]',
          );
        },
      ),
    );
  }

  double _parseNumber(
    String raw, {
    required String label,
  }) {
    final double? direct = double.tryParse(raw);

    if (direct != null && direct.isFinite) {
      return direct;
    }

    if (raw.contains('/')) {
      final List<String> parts = raw.split('/');

      if (parts.length == 2) {
        final double? numerator =
            double.tryParse(parts[0].trim());
        final double? denominator =
            double.tryParse(parts[1].trim());

        if (numerator != null &&
            denominator != null &&
            denominator != 0) {
          return numerator / denominator;
        }
      }
    }

    throw FormatException(
      '$label: “$raw” is not a valid number.',
    );
  }

  void _calculate() {
    FocusScope.of(context).unfocus();

    try {
      final VectorData a =
          _readVector(_aControllers, 'A');
      final VectorData? b = _operation.usesB
          ? _readVector(_bControllers, 'B')
          : null;

      VectorData? vector;
      double? scalar;

      switch (_operation) {
        case VectorOperation.add:
          vector = _engine.add(a, b!);
          break;
        case VectorOperation.subtract:
          vector = _engine.subtract(a, b!);
          break;
        case VectorOperation.scalar:
          final String raw =
              _scalarController.text.trim();

          if (raw.isEmpty) {
            throw const FormatException(
              'Enter scalar k.',
            );
          }

          vector = _engine.scalarMultiply(
            a,
            _parseNumber(
              raw,
              label: 'Scalar k',
            ),
          );
          break;
        case VectorOperation.dot:
          scalar = _engine.dot(a, b!);
          break;
        case VectorOperation.cross:
          vector = _engine.cross(a, b!);
          break;
        case VectorOperation.magnitude:
          scalar = _engine.magnitude(a);
          break;
        case VectorOperation.normalize:
          vector = _engine.normalize(a);
          break;
        case VectorOperation.angle:
          scalar = _engine.angleDegrees(a, b!);
          break;
        case VectorOperation.projection:
          vector = _engine.projection(a, b!);
          break;
      }

      setState(() {
        _vectorResult = vector;
        _scalarResult = scalar;
        _validationMessage = null;
      });
    } on FormatException catch (error) {
      setState(() {
        _vectorResult = null;
        _scalarResult = null;
        _validationMessage =
            error.message.toString();
      });
    }
  }

  void _loadExample() {
    setState(() {
      final List<double> a = _dimension == 2
          ? <double>[3, 4]
          : <double>[1, 2, 3];

      final List<double> b = _dimension == 2
          ? <double>[1, 2]
          : <double>[4, 5, 6];

      for (int i = 0; i < _dimension; i++) {
        _aControllers[i].text = _format(a[i]);
        _bControllers[i].text = _format(b[i]);
      }

      _scalarController.text = '2';
      _vectorResult = null;
      _scalarResult = null;
      _validationMessage = null;
    });
  }

  void _clear() {
    setState(() {
      for (final TextEditingController controller
          in _aControllers) {
        controller.clear();
      }

      for (final TextEditingController controller
          in _bControllers) {
        controller.clear();
      }

      _scalarController.text = '2';
      _vectorResult = null;
      _scalarResult = null;
      _validationMessage = null;
    });
  }

  void _useResultAsA() {
    final VectorData? result = _vectorResult;

    if (result == null ||
        result.dimension != _dimension) {
      return;
    }

    setState(() {
      for (int i = 0; i < _dimension; i++) {
        _aControllers[i].text =
            _format(result.at(i));
      }

      _vectorResult = null;
      _scalarResult = null;
      _validationMessage = null;
    });
  }

  void _useResultAsB() {
    final VectorData? result = _vectorResult;

    if (result == null ||
        result.dimension != _dimension) {
      return;
    }

    setState(() {
      for (int i = 0; i < _dimension; i++) {
        _bControllers[i].text =
            _format(result.at(i));
      }

      _vectorResult = null;
      _scalarResult = null;
      _validationMessage = null;
    });
  }

  String _format(double value) {
    if (value == 0) return '0';

    final double rounded = value.roundToDouble();

    if ((value - rounded).abs() < 1e-12 &&
        value.abs() < 1e15) {
      return rounded.toInt().toString();
    }

    String text = value.toStringAsPrecision(10);

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
    final List<VectorOperation> operations =
        VectorOperation.values
            .where(
              (VectorOperation operation) =>
                  _dimension == 3 ||
                  operation != VectorOperation.cross,
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('VECTOR Mode'),
        backgroundColor: AppTheme.background,
        surfaceTintColor: AppTheme.background,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                28,
              ),
              children: <Widget>[
                _buildSettingsCard(operations),
                const SizedBox(height: 16),
                _buildVectorCard(
                  title: 'Vector A',
                  controllers: _aControllers,
                ),
                if (_operation.usesB) ...<Widget>[
                  const SizedBox(height: 14),
                  _buildVectorCard(
                    title: 'Vector B',
                    controllers: _bControllers,
                  ),
                ],
                if (_operation.usesScalar) ...<Widget>[
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
                if (_vectorResult != null ||
                    _scalarResult != null) ...<Widget>[
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

  Widget _buildSettingsCard(
    List<VectorOperation> operations,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.display,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF334155),
        ),
      ),
      child: Column(
        children: <Widget>[
          DropdownButtonFormField<int>(
            value: _dimension,
            decoration: const InputDecoration(
              labelText: 'Vector dimension',
              border: OutlineInputBorder(),
            ),
            items: const <DropdownMenuItem<int>>[
              DropdownMenuItem<int>(
                value: 2,
                child: Text('2D'),
              ),
              DropdownMenuItem<int>(
                value: 3,
                child: Text('3D'),
              ),
            ],
            onChanged: _changeDimension,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<VectorOperation>(
            value: _operation,
            decoration: const InputDecoration(
              labelText: 'Operation',
              border: OutlineInputBorder(),
            ),
            items: operations
                .map(
                  (VectorOperation operation) =>
                      DropdownMenuItem<
                          VectorOperation>(
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
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Angle results are shown in degrees. '
              'Cross product is available in 3D.',
              style: TextStyle(
                color: AppTheme.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVectorCard({
    required String title,
    required List<TextEditingController>
        controllers,
  }) {
    const List<String> labels =
        <String>['x', 'y', 'z'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.display,
        borderRadius: BorderRadius.circular(18),
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
          Row(
            children: List<Widget>.generate(
              _dimension,
              (int index) => Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  child: TextField(
                    controller: controllers[index],
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      signed: true,
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: labels[index],
                      border:
                          const OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ),
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
        borderRadius: BorderRadius.circular(18),
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
        decoration: const InputDecoration(
          labelText: 'Scalar k',
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
          icon: const Icon(Icons.calculate_outlined),
          label: const Text('Calculate'),
          style: FilledButton.styleFrom(
            backgroundColor:
                const Color(0xFFF6B45F),
            foregroundColor:
                const Color(0xFF2B1A04),
          ),
        ),
        OutlinedButton.icon(
          onPressed: _loadExample,
          icon: const Icon(Icons.science_outlined),
          label: const Text('Load example'),
        ),
        OutlinedButton.icon(
          onPressed: _clear,
          icon: const Icon(Icons.refresh),
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
        borderRadius: BorderRadius.circular(14),
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF334155),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Result',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          if (_scalarResult != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.numberKey,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF334155),
                ),
              ),
              child: Text(
                _operation == VectorOperation.angle
                    ? '${_format(_scalarResult!)}°'
                    : _format(_scalarResult!),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          if (_vectorResult != null) ...<Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.numberKey,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF334155),
                ),
              ),
              child: Text(
                '⟨${_vectorResult!.components.map(_format).join(', ')}⟩',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: _useResultAsA,
                  icon: const Icon(Icons.save_alt),
                  label: const Text('Use result as A'),
                ),
                OutlinedButton.icon(
                  onPressed: _useResultAsB,
                  icon: const Icon(Icons.save_alt),
                  label: const Text('Use result as B'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
