import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const ScientificCalculatorApp());
}

class ScientificCalculatorApp extends StatelessWidget {
  const ScientificCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scientific Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF59E0B),
          brightness: Brightness.dark,
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String equation = '0';
  String result = '0';

  bool isDegreeMode = true;
  bool shiftEnabled = false;
  bool alphaEnabled = false;
  bool hyperbolicEnabled = false;

  double lastAnswer = 0;

  static const List<String> _functionTokens = <String>[
    'asinh(',
    'acosh(',
    'atanh(',
    'asin(',
    'acos(',
    'atan(',
    'sinh(',
    'cosh(',
    'tanh(',
    'sqrt(',
    'sin(',
    'cos(',
    'tan(',
    'log(',
    'ln(',
  ];

  Future<void> scanMathProblem() async {
    if (kIsWeb) {
      _showMessage(
        'Camera OCR is reserved for the Android/iOS build. '
        'You can keep testing the calculator itself in Chrome.',
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (image == null) {
      return;
    }

    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer(
      script: TextRecognitionScript.latin,
    );

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      final String scannedEquation = _cleanScannedText(recognizedText.text);

      if (!mounted) return;

      setState(() {
        equation = scannedEquation.isEmpty ? '0' : scannedEquation;
        result = scannedEquation.isEmpty ? 'No equation found' : 'Scanned';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        result = 'Scan failed';
      });
    } finally {
      await textRecognizer.close();
    }
  }

  String _cleanScannedText(String value) {
    return value
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('X', '×')
        .replaceAll('x', '×')
        .replaceAll('*', '×')
        .replaceAll('/', '÷')
        .replaceAll('−', '-')
        .replaceAll('–', '-')
        .replaceAll('^', '^');
  }

  void buttonPressed(String buttonText) {
    switch (buttonText) {
      case 'AC':
      case 'ON':
        setState(() {
          equation = '0';
          result = '0';
          shiftEnabled = false;
          alphaEnabled = false;
          hyperbolicEnabled = false;
        });
        return;

      case 'DEL':
        _deleteLast();
        return;

      case 'SHIFT':
        setState(() {
          shiftEnabled = !shiftEnabled;
        });
        return;

      case 'ALPHA':
        setState(() {
          alphaEnabled = !alphaEnabled;
        });
        return;

      case 'MODE':
        _showModeSheet();
        return;

      case 'DEG/RAD':
        setState(() {
          isDegreeMode = !isDegreeMode;
        });
        return;

      case 'hyp':
        setState(() {
          hyperbolicEnabled = !hyperbolicEnabled;
        });
        return;

      case '📷':
        scanMathProblem();
        return;

      case '=':
        _calculate();
        return;

      case 'Ans':
        _appendText(_formatNumber(lastAnswer));
        return;

      case 'ENG':
        _showEngineeringNotation();
        return;

      case 'RCL':
        _appendText(_formatNumber(lastAnswer));
        return;

      case 'x⁻¹':
        _appendText('^(-1)');
        return;

      case 'x²':
        _appendText('^2');
        return;

      case '√':
        _appendFunction('sqrt');
        return;

      case 'log':
        _appendFunction('log');
        return;

      case 'ln':
        _appendFunction('ln');
        return;

      case 'sin':
      case 'cos':
      case 'tan':
        _appendTrigFunction(buttonText);
        return;

      case '(-)':
        _appendText('-');
        return;

      case 'π':
        _appendText('π');
        return;

      case 'EXP':
        _appendText('E');
        return;

      case '×':
      case '÷':
      case '+':
      case '−':
      case '^':
        _appendOperator(buttonText);
        return;

      case '.':
        _appendDecimal();
        return;

      default:
        _appendText(buttonText);
    }
  }

  void _appendTrigFunction(String base) {
    String functionName = base;

    if (hyperbolicEnabled && shiftEnabled) {
      functionName = 'a${base}h';
    } else if (hyperbolicEnabled) {
      functionName = '${base}h';
    } else if (shiftEnabled) {
      functionName = 'a$base';
    }

    _appendFunction(functionName);

    setState(() {
      shiftEnabled = false;
      alphaEnabled = false;
    });
  }

  void _appendFunction(String functionName) {
    _appendText('$functionName(');
  }

  void _appendText(String value) {
    setState(() {
      if (equation == '0' || result == 'Error') {
        equation = value;
      } else {
        equation += value;
      }

      if (result == 'Error' || result == 'Scanned' || result == 'Scan failed') {
        result = '0';
      }
    });
  }

  void _appendOperator(String value) {
    setState(() {
      if (equation == '0' && value != '−') {
        return;
      }

      if (_endsWithOperator(equation)) {
        equation = equation.substring(0, equation.length - 1) + value;
      } else {
        equation += value;
      }
    });
  }

  void _appendDecimal() {
    setState(() {
      if (equation == '0') {
        equation = '0.';
        return;
      }

      final String currentNumber =
          equation.split(RegExp(r'[+\-×÷^()]')).last;

      if (!currentNumber.contains('.')) {
        equation += '.';
      }
    });
  }

  bool _endsWithOperator(String value) {
    if (value.isEmpty) return false;
    return <String>{'+', '−', '-', '×', '÷', '^'}.contains(value[value.length - 1]);
  }

  void _deleteLast() {
    setState(() {
      if (equation == '0' || equation.isEmpty) {
        equation = '0';
        return;
      }

      for (final token in _functionTokens) {
        if (equation.endsWith(token)) {
          equation = equation.substring(0, equation.length - token.length);
          if (equation.isEmpty) equation = '0';
          return;
        }
      }

      equation = equation.substring(0, equation.length - 1);
      if (equation.isEmpty) {
        equation = '0';
      }
    });
  }

  void _calculate() {
    try {
      final parser = _ExpressionParser(
        equation,
        degrees: isDegreeMode,
      );

      final double value = parser.parse();

      if (value.isNaN || value.isInfinite) {
        throw const FormatException('Invalid result');
      }

      setState(() {
        lastAnswer = value;
        result = _formatNumber(value);
        shiftEnabled = false;
        alphaEnabled = false;
      });
    } catch (_) {
      setState(() {
        result = 'Error';
      });
    }
  }

  void _showEngineeringNotation() {
    if (result == 'Error') return;

    final double? value = double.tryParse(result);
    if (value == null) return;

    setState(() {
      result = _toEngineering(value);
    });
  }

  String _toEngineering(double value) {
    if (value == 0) return '0';

    final int exponent =
        (math.log(value.abs()) / math.ln10).floor();
    final int engineeringExponent = (exponent / 3).floor() * 3;
    final double mantissa = value / math.pow(10, engineeringExponent);

    final String mantissaText = _formatNumber(mantissa);

    if (engineeringExponent == 0) {
      return mantissaText;
    }

    return '${mantissaText}E$engineeringExponent';
  }

  String _formatNumber(double value) {
    if (value == 0) return '0';

    final double rounded = value.roundToDouble();
    if ((value - rounded).abs() < 1e-12 && value.abs() < 1e15) {
      return rounded.toInt().toString();
    }

    final double absValue = value.abs();

    if (absValue >= 1e12 || absValue < 1e-9) {
      return value.toStringAsExponential(10).replaceFirst(RegExp(r'\.?0+e'), 'e');
    }

    String text = value.toStringAsPrecision(12);

    if (!text.contains('e') && !text.contains('E')) {
      text = text.replaceFirst(RegExp(r'\.?0+$'), '');
    }

    return text;
  }

  Future<void> _showModeSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Calculator mode',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.calculate_outlined),
                  title: const Text('COMP'),
                  subtitle: const Text('Standard scientific calculations'),
                  trailing: const Icon(Icons.check_circle),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.straighten),
                  title: Text(
                    isDegreeMode ? 'Switch to RAD' : 'Switch to DEG',
                  ),
                  subtitle: Text(
                    'Current angle mode: ${isDegreeMode ? 'DEG' : 'RAD'}',
                  ),
                  onTap: () {
                    setState(() {
                      isDegreeMode = !isDegreeMode;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final List<_CalcButton> scientificButtons = <_CalcButton>[
      const _CalcButton('x⁻¹', kind: _ButtonKind.function),
      const _CalcButton('x²', kind: _ButtonKind.function),
      const _CalcButton('√', kind: _ButtonKind.function),
      const _CalcButton('log', kind: _ButtonKind.function),
      const _CalcButton('ln', kind: _ButtonKind.function),
      const _CalcButton('(-)', kind: _ButtonKind.function),
      const _CalcButton('π', kind: _ButtonKind.function),
      _CalcButton(
        'hyp',
        kind: hyperbolicEnabled
            ? _ButtonKind.active
            : _ButtonKind.function,
      ),
      _CalcButton(
        'sin',
        secondaryLabel: shiftEnabled ? 'sin⁻¹' : null,
        kind: _ButtonKind.function,
      ),
      _CalcButton(
        'cos',
        secondaryLabel: shiftEnabled ? 'cos⁻¹' : null,
        kind: _ButtonKind.function,
      ),
      _CalcButton(
        'tan',
        secondaryLabel: shiftEnabled ? 'tan⁻¹' : null,
        kind: _ButtonKind.function,
      ),
      const _CalcButton('RCL', kind: _ButtonKind.function),
      const _CalcButton('ENG', kind: _ButtonKind.function),
      const _CalcButton('(', kind: _ButtonKind.function),
      const _CalcButton(')', kind: _ButtonKind.function),
    ];

    const List<_CalcButton> keypadButtons = <_CalcButton>[
      _CalcButton('7'),
      _CalcButton('8'),
      _CalcButton('9'),
      _CalcButton('DEL', kind: _ButtonKind.danger),
      _CalcButton('AC', kind: _ButtonKind.danger),
      _CalcButton('4'),
      _CalcButton('5'),
      _CalcButton('6'),
      _CalcButton('×', kind: _ButtonKind.operator),
      _CalcButton('÷', kind: _ButtonKind.operator),
      _CalcButton('1'),
      _CalcButton('2'),
      _CalcButton('3'),
      _CalcButton('+', kind: _ButtonKind.operator),
      _CalcButton('−', kind: _ButtonKind.operator),
      _CalcButton('0'),
      _CalcButton('.'),
      _CalcButton('EXP', kind: _ButtonKind.function),
      _CalcButton('Ans', kind: _ButtonKind.function),
      _CalcButton('=', kind: _ButtonKind.equals),
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: math.max(0.0, constraints.maxHeight - 24),
                    ),
                    child: Column(
                      children: <Widget>[
                        _buildDisplay(),
                        const SizedBox(height: 10),
                        _buildControlRow(),
                        const SizedBox(height: 10),
                        _buildButtonGrid(scientificButtons),
                        const SizedBox(height: 10),
                        _buildButtonGrid(keypadButtons),
                        const SizedBox(height: 10),
                        _buildBottomTools(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              _indicator(
                isDegreeMode ? 'DEG' : 'RAD',
                active: true,
                onTap: () => buttonPressed('DEG/RAD'),
              ),
              const SizedBox(width: 6),
              _indicator('SHIFT', active: shiftEnabled),
              const SizedBox(width: 6),
              _indicator('ALPHA', active: alphaEnabled),
              if (hyperbolicEnabled) ...<Widget>[
                const SizedBox(width: 6),
                _indicator('HYP', active: true),
              ],
              const Spacer(),
              const Icon(
                Icons.battery_5_bar,
                size: 20,
                color: Color(0xFFCBD5E1),
              ),
            ],
          ),
          const SizedBox(height: 26),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Text(
              equation,
              textAlign: TextAlign.right,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 26,
                color: Color(0xFFCBD5E1),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Text(
              result,
              textAlign: TextAlign.right,
              maxLines: 1,
              style: TextStyle(
                fontSize: result.length > 16 ? 34 : 44,
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _indicator(
    String text, {
    required bool active,
    VoidCallback? onTap,
  }) {
    final Widget chip = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFF59E0B).withOpacity(0.18)
            : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active
              ? const Color(0xFFF59E0B)
              : const Color(0xFF334155),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: active
              ? const Color(0xFFFBBF24)
              : const Color(0xFF94A3B8),
        ),
      ),
    );

    if (onTap == null) return chip;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: chip,
    );
  }

  Widget _buildControlRow() {
    final List<_CalcButton> controls = <_CalcButton>[
      _CalcButton(
        'SHIFT',
        kind: shiftEnabled ? _ButtonKind.active : _ButtonKind.control,
      ),
      _CalcButton(
        'ALPHA',
        kind: alphaEnabled ? _ButtonKind.active : _ButtonKind.control,
      ),
      const _CalcButton('MODE', kind: _ButtonKind.control),
      const _CalcButton('ON', kind: _ButtonKind.control),
    ];

    return Row(
      children: controls.map((button) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _buildButton(button, compact: true),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildButtonGrid(List<_CalcButton> buttons) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: buttons.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 7,
        crossAxisSpacing: 7,
        childAspectRatio: 1.22,
      ),
      itemBuilder: (BuildContext context, int index) {
        return _buildButton(buttons[index]);
      },
    );
  }

  Widget _buildBottomTools() {
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: scanMathProblem,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Scan problem'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: Color(0xFF475569)),
              foregroundColor: const Color(0xFFE2E8F0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
    _CalcButton button, {
    bool compact = false,
  }) {
    Color background;
    Color foreground = Colors.white;
    Color border = Colors.transparent;

    switch (button.kind) {
      case _ButtonKind.number:
        background = const Color(0xFF1E293B);
        border = const Color(0xFF334155);
        break;
      case _ButtonKind.function:
        background = const Color(0xFF334155);
        border = const Color(0xFF475569);
        break;
      case _ButtonKind.operator:
        background = const Color(0xFFB45309);
        break;
      case _ButtonKind.equals:
        background = const Color(0xFFF59E0B);
        foreground = const Color(0xFF111827);
        break;
      case _ButtonKind.danger:
        background = const Color(0xFF7F1D1D);
        break;
      case _ButtonKind.control:
        background = const Color(0xFF0F172A);
        border = const Color(0xFF475569);
        foreground = const Color(0xFFCBD5E1);
        break;
      case _ButtonKind.active:
        background = const Color(0xFF78350F);
        border = const Color(0xFFF59E0B);
        foreground = const Color(0xFFFDE68A);
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => buttonPressed(button.label),
        borderRadius: BorderRadius.circular(compact ? 12 : 14),
        child: Ink(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(compact ? 12 : 14),
            border: Border.all(color: border),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 4 : 6,
                vertical: compact ? 10 : 8,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (button.secondaryLabel != null)
                    Text(
                      button.secondaryLabel!,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFFFBBF24),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  Text(
                    button.label,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: compact ? 13 : 17,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _ButtonKind {
  number,
  function,
  operator,
  equals,
  danger,
  control,
  active,
}

class _CalcButton {
  const _CalcButton(
    this.label, {
    this.kind = _ButtonKind.number,
    this.secondaryLabel,
  });

  final String label;
  final _ButtonKind kind;
  final String? secondaryLabel;
}

/// Small self-contained expression parser used by the calculator.
///
/// Supported:
/// +, -, ×, ÷, *, /, ^, %, !, parentheses, implicit multiplication,
/// π/pi, e, scientific notation, sqrt, log, ln, sin, cos, tan,
/// inverse trig, hyperbolic trig and inverse hyperbolic trig.
class _ExpressionParser {
  _ExpressionParser(
    String input, {
    required this.degrees,
  }) : _source = input
            .replaceAll('×', '*')
            .replaceAll('÷', '/')
            .replaceAll('−', '-')
            .replaceAll('π', 'pi')
            .replaceAll('√', 'sqrt');

  final String _source;
  final bool degrees;

  int _index = 0;

  double parse() {
    _index = 0;
    final double value = _parseExpression();
    _skipSpaces();

    if (_index != _source.length) {
      throw FormatException(
        'Unexpected token at position $_index',
      );
    }

    return value;
  }

  double _parseExpression() {
    double value = _parseTerm();

    while (true) {
      _skipSpaces();

      if (_match('+')) {
        value += _parseTerm();
      } else if (_match('-')) {
        value -= _parseTerm();
      } else {
        return value;
      }
    }
  }

  double _parseTerm() {
    double value = _parsePower();

    while (true) {
      _skipSpaces();

      if (_match('*')) {
        value *= _parsePower();
      } else if (_match('/')) {
        final double divisor = _parsePower();
        if (divisor == 0) {
          throw const FormatException('Division by zero');
        }
        value /= divisor;
      } else if (_startsImplicitFactor()) {
        value *= _parsePower();
      } else {
        return value;
      }
    }
  }

  double _parsePower() {
    double value = _parseUnary();
    _skipSpaces();

    if (_match('^')) {
      final double exponent = _parsePower();
      value = math.pow(value, exponent).toDouble();
    }

    return value;
  }

  double _parseUnary() {
    _skipSpaces();

    if (_match('+')) {
      return _parseUnary();
    }

    if (_match('-')) {
      return -_parseUnary();
    }

    double value = _parsePrimary();

    while (true) {
      _skipSpaces();

      if (_match('%')) {
        value /= 100;
      } else if (_match('!')) {
        value = _factorial(value);
      } else {
        break;
      }
    }

    return value;
  }

  double _parsePrimary() {
    _skipSpaces();

    if (_match('(')) {
      final double value = _parseExpression();
      _expect(')');
      return value;
    }

    final String? number = _readNumber();
    if (number != null) {
      return double.parse(number);
    }

    final String? identifier = _readIdentifier();
    if (identifier != null) {
      final String id = identifier.toLowerCase();

      if (id == 'pi') {
        return math.pi;
      }

      if (id == 'e') {
        return math.e;
      }

      _skipSpaces();
      _expect('(');
      final double argument = _parseExpression();
      _expect(')');

      return _applyFunction(id, argument);
    }

    throw FormatException(
      'Expected a number, constant, or function at position $_index',
    );
  }

  double _applyFunction(String name, double x) {
    switch (name) {
      case 'sqrt':
        if (x < 0) throw const FormatException('Square root domain error');
        return math.sqrt(x);

      case 'log':
        if (x <= 0) throw const FormatException('Log domain error');
        return math.log(x) / math.ln10;

      case 'ln':
        if (x <= 0) throw const FormatException('Ln domain error');
        return math.log(x);

      case 'sin':
        return math.sin(_toRadiansIfNeeded(x));

      case 'cos':
        return math.cos(_toRadiansIfNeeded(x));

      case 'tan':
        return math.tan(_toRadiansIfNeeded(x));

      case 'asin':
        return _fromRadiansIfNeeded(math.asin(x));

      case 'acos':
        return _fromRadiansIfNeeded(math.acos(x));

      case 'atan':
        return _fromRadiansIfNeeded(math.atan(x));

      case 'sinh':
        return (math.exp(x) - math.exp(-x)) / 2;

      case 'cosh':
        return (math.exp(x) + math.exp(-x)) / 2;

      case 'tanh':
        final double positive = math.exp(x);
        final double negative = math.exp(-x);
        return (positive - negative) / (positive + negative);

      case 'asinh':
        return math.log(x + math.sqrt((x * x) + 1));

      case 'acosh':
        if (x < 1) throw const FormatException('acosh domain error');
        return math.log(x + math.sqrt((x * x) - 1));

      case 'atanh':
        if (x <= -1 || x >= 1) {
          throw const FormatException('atanh domain error');
        }
        return 0.5 * math.log((1 + x) / (1 - x));

      default:
        throw FormatException('Unsupported function: $name');
    }
  }

  double _toRadiansIfNeeded(double value) {
    return degrees ? value * math.pi / 180 : value;
  }

  double _fromRadiansIfNeeded(double value) {
    return degrees ? value * 180 / math.pi : value;
  }

  double _factorial(double value) {
    if (value < 0 || value != value.roundToDouble()) {
      throw const FormatException(
        'Factorial requires a non-negative integer',
      );
    }

    if (value > 170) {
      throw const FormatException('Factorial too large');
    }

    double total = 1;
    for (int i = 2; i <= value.toInt(); i++) {
      total *= i;
    }
    return total;
  }

  bool _startsImplicitFactor() {
    _skipSpaces();

    if (_index >= _source.length) {
      return false;
    }

    final String char = _source[_index];

    return char == '(' ||
        char == '.' ||
        _isDigit(char) ||
        _isLetter(char);
  }

  String? _readNumber() {
    _skipSpaces();

    final int start = _index;
    bool hasDigits = false;
    bool hasDecimal = false;

    while (_index < _source.length) {
      final String char = _source[_index];

      if (_isDigit(char)) {
        hasDigits = true;
        _index++;
      } else if (char == '.' && !hasDecimal) {
        hasDecimal = true;
        _index++;
      } else {
        break;
      }
    }

    if (!hasDigits) {
      _index = start;
      return null;
    }

    if (_index < _source.length &&
        (_source[_index] == 'E' || _source[_index] == 'e')) {
      final int exponentStart = _index;
      _index++;

      if (_index < _source.length &&
          (_source[_index] == '+' || _source[_index] == '-')) {
        _index++;
      }

      final int exponentDigitsStart = _index;

      while (_index < _source.length && _isDigit(_source[_index])) {
        _index++;
      }

      if (_index == exponentDigitsStart) {
        _index = exponentStart;
      }
    }

    return _source.substring(start, _index);
  }

  String? _readIdentifier() {
    _skipSpaces();

    if (_index >= _source.length || !_isLetter(_source[_index])) {
      return null;
    }

    final int start = _index;

    while (_index < _source.length && _isLetter(_source[_index])) {
      _index++;
    }

    return _source.substring(start, _index);
  }

  bool _isDigit(String char) {
    final int code = char.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }

  bool _isLetter(String char) {
    final int code = char.codeUnitAt(0);
    return (code >= 65 && code <= 90) ||
        (code >= 97 && code <= 122);
  }

  bool _match(String token) {
    _skipSpaces();

    if (_source.startsWith(token, _index)) {
      _index += token.length;
      return true;
    }

    return false;
  }

  void _expect(String token) {
    if (!_match(token)) {
      throw FormatException(
        'Expected "$token" at position $_index',
      );
    }
  }

  void _skipSpaces() {
    while (_index < _source.length &&
        _source[_index].trim().isEmpty) {
      _index++;
    }
  }
}
