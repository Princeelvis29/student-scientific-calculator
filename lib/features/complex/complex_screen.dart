import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'complex_engine.dart';

enum ComplexOperation {
  add('A + B', 'Addition'),
  subtract('A − B', 'Subtraction'),
  multiply('A × B', 'Multiplication'),
  divide('A ÷ B', 'Division'),
  conjugate('conj(A)', 'Conjugate'),
  magnitude('|A|', 'Magnitude'),
  argument('arg(A)', 'Argument'),
  polar('r∠θ', 'Convert A to polar'),
  power('Aⁿ', 'Integer power'),
  fromPolar('r∠θ → a+bi', 'Polar to rectangular');

  const ComplexOperation(
    this.symbol,
    this.label,
  );

  final String symbol;
  final String label;

  bool get usesB =>
      this == ComplexOperation.add ||
      this == ComplexOperation.subtract ||
      this == ComplexOperation.multiply ||
      this == ComplexOperation.divide;

  bool get usesA =>
      this != ComplexOperation.fromPolar;

  bool get usesExponent =>
      this == ComplexOperation.power;

  bool get usesPolarInput =>
      this == ComplexOperation.fromPolar;

  bool get producesScalar =>
      this == ComplexOperation.magnitude ||
      this == ComplexOperation.argument;

  bool get producesPolar =>
      this == ComplexOperation.polar;
}

class ComplexModeScreen extends StatefulWidget {
  const ComplexModeScreen({super.key});

  @override
  State<ComplexModeScreen> createState() =>
      _ComplexModeScreenState();
}

class _ComplexModeScreenState
    extends State<ComplexModeScreen> {
  final ComplexEngine _engine = const ComplexEngine();

  ComplexOperation _operation =
      ComplexOperation.add;

  final TextEditingController _aReal =
      TextEditingController();
  final TextEditingController _aImag =
      TextEditingController();

  final TextEditingController _bReal =
      TextEditingController();
  final TextEditingController _bImag =
      TextEditingController();

  final TextEditingController _exponent =
      TextEditingController(text: '2');

  final TextEditingController _polarMagnitude =
      TextEditingController(text: '2');
  final TextEditingController _polarAngle =
      TextEditingController(text: '30');

  ComplexNumber? _complexResult;
  double? _scalarResult;
  PolarComplex? _polarResult;
  String? _validationMessage;

  @override
  void dispose() {
    _aReal.dispose();
    _aImag.dispose();
    _bReal.dispose();
    _bImag.dispose();
    _exponent.dispose();
    _polarMagnitude.dispose();
    _polarAngle.dispose();
    super.dispose();
  }

  void _changeOperation(
    ComplexOperation? operation,
  ) {
    if (operation == null) return;

    setState(() {
      _operation = operation;
      _clearResult();
    });
  }

  void _clearResult() {
    _complexResult = null;
    _scalarResult = null;
    _polarResult = null;
    _validationMessage = null;
  }

  double _parseNumber(
    String raw, {
    required String label,
  }) {
    final double? direct =
        double.tryParse(raw.trim());

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

  ComplexNumber _readComplex({
    required TextEditingController real,
    required TextEditingController imaginary,
    required String name,
  }) {
    if (real.text.trim().isEmpty ||
        imaginary.text.trim().isEmpty) {
      throw FormatException(
        'Enter both real and imaginary parts for $name.',
      );
    }

    return ComplexNumber(
      _parseNumber(
        real.text,
        label: '$name real part',
      ),
      _parseNumber(
        imaginary.text,
        label: '$name imaginary part',
      ),
    );
  }

  void _calculate() {
    FocusScope.of(context).unfocus();

    try {
      final ComplexNumber? a = _operation.usesA
          ? _readComplex(
              real: _aReal,
              imaginary: _aImag,
              name: 'A',
            )
          : null;

      final ComplexNumber? b = _operation.usesB
          ? _readComplex(
              real: _bReal,
              imaginary: _bImag,
              name: 'B',
            )
          : null;

      ComplexNumber? complex;
      double? scalar;
      PolarComplex? polar;

      switch (_operation) {
        case ComplexOperation.add:
          complex = _engine.add(a!, b!);
          break;
        case ComplexOperation.subtract:
          complex = _engine.subtract(a!, b!);
          break;
        case ComplexOperation.multiply:
          complex = _engine.multiply(a!, b!);
          break;
        case ComplexOperation.divide:
          complex = _engine.divide(a!, b!);
          break;
        case ComplexOperation.conjugate:
          complex = _engine.conjugate(a!);
          break;
        case ComplexOperation.magnitude:
          scalar = _engine.magnitude(a!);
          break;
        case ComplexOperation.argument:
          scalar = _engine.argumentDegrees(a!);
          break;
        case ComplexOperation.polar:
          polar = _engine.toPolar(a!);
          break;
        case ComplexOperation.power:
          final int? exponent =
              int.tryParse(_exponent.text.trim());

          if (exponent == null) {
            throw const FormatException(
              'Exponent n must be a whole number.',
            );
          }

          complex =
              _engine.integerPower(a!, exponent);
          break;
        case ComplexOperation.fromPolar:
          complex = _engine.fromPolar(
            magnitude: _parseNumber(
              _polarMagnitude.text,
              label: 'Magnitude r',
            ),
            angleDegrees: _parseNumber(
              _polarAngle.text,
              label: 'Angle θ',
            ),
          );
          break;
      }

      setState(() {
        _complexResult = complex;
        _scalarResult = scalar;
        _polarResult = polar;
        _validationMessage = null;
      });
    } on FormatException catch (error) {
      setState(() {
        _clearResult();
        _validationMessage =
            error.message.toString();
      });
    }
  }

  void _loadExample() {
    setState(() {
      _aReal.text = '3';
      _aImag.text = '4';
      _bReal.text = '1';
      _bImag.text = '-2';
      _exponent.text = '2';
      _polarMagnitude.text = '2';
      _polarAngle.text = '30';
      _clearResult();
    });
  }

  void _clear() {
    setState(() {
      _aReal.clear();
      _aImag.clear();
      _bReal.clear();
      _bImag.clear();
      _exponent.text = '2';
      _polarMagnitude.text = '2';
      _polarAngle.text = '30';
      _clearResult();
    });
  }

  void _useResultAsA() {
    final ComplexNumber? result =
        _complexResult;

    if (result == null) return;

    setState(() {
      _aReal.text = _format(result.real);
      _aImag.text = _format(result.imaginary);
      _clearResult();
    });
  }

  void _useResultAsB() {
    final ComplexNumber? result =
        _complexResult;

    if (result == null) return;

    setState(() {
      _bReal.text = _format(result.real);
      _bImag.text = _format(result.imaginary);
      _clearResult();
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

  String _formatComplex(
    ComplexNumber value,
  ) {
    final String real = _format(value.real);
    final double imagValue = value.imaginary;
    final String imag =
        _format(imagValue.abs());

    if (imagValue == 0) {
      return real;
    }

    if (value.real == 0) {
      return '${imagValue < 0 ? '−' : ''}${imag == '1' ? '' : imag}i';
    }

    return '$real ${imagValue < 0 ? '−' : '+'} '
        '${imag == '1' ? '' : imag}i';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CMPLX Mode'),
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
                _buildOperationCard(),
                if (_operation.usesA) ...<Widget>[
                  const SizedBox(height: 14),
                  _buildComplexInputCard(
                    title: 'Complex A',
                    real: _aReal,
                    imaginary: _aImag,
                  ),
                ],
                if (_operation.usesB) ...<Widget>[
                  const SizedBox(height: 14),
                  _buildComplexInputCard(
                    title: 'Complex B',
                    real: _bReal,
                    imaginary: _bImag,
                  ),
                ],
                if (_operation.usesExponent) ...<
                    Widget>[
                  const SizedBox(height: 14),
                  _buildExponentCard(),
                ],
                if (_operation.usesPolarInput) ...<
                    Widget>[
                  const SizedBox(height: 14),
                  _buildPolarInputCard(),
                ],
                const SizedBox(height: 14),
                _buildActions(),
                if (_validationMessage != null) ...<
                    Widget>[
                  const SizedBox(height: 14),
                  _buildValidationMessage(),
                ],
                if (_complexResult != null ||
                    _scalarResult != null ||
                    _polarResult != null) ...<Widget>[
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

  Widget _buildOperationCard() {
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
          DropdownButtonFormField<ComplexOperation>(
            value: _operation,
            decoration: const InputDecoration(
              labelText: 'Operation',
              border: OutlineInputBorder(),
            ),
            items: ComplexOperation.values
                .map(
                  (ComplexOperation operation) =>
                      DropdownMenuItem<
                          ComplexOperation>(
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
          const SizedBox(height: 10),
          const Text(
            'Rectangular form uses a + bi. '
            'Arguments and polar angles are shown in degrees.',
            style: TextStyle(
              color: AppTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplexInputCard({
    required String title,
    required TextEditingController real,
    required TextEditingController imaginary,
  }) {
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
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: real,
                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    signed: true,
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Real part',
                    hintText: 'a',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: imaginary,
                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    signed: true,
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Imaginary coefficient',
                    hintText: 'b',
                    suffixText: 'i',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExponentCard() {
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
        controller: _exponent,
        keyboardType:
            const TextInputType.numberWithOptions(
          signed: true,
          decimal: false,
        ),
        decoration: const InputDecoration(
          labelText: 'Integer exponent n',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildPolarInputCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.display,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF334155),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _polarMagnitude,
              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                signed: false,
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Magnitude r',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _polarAngle,
              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                signed: true,
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Angle θ',
                suffixText: '°',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
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
    String primaryText = '';

    if (_complexResult != null) {
      primaryText = _formatComplex(_complexResult!);
    } else if (_scalarResult != null) {
      primaryText = _operation ==
              ComplexOperation.argument
          ? '${_format(_scalarResult!)}°'
          : _format(_scalarResult!);
    } else if (_polarResult != null) {
      primaryText =
          '${_format(_polarResult!.magnitude)} ∠ '
          '${_format(_polarResult!.angleDegrees)}°';
    }

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
              primaryText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (_complexResult != null) ...<Widget>[
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
