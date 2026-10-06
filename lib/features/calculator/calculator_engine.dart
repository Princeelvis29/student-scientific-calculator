import 'dart:math' as math;

class CalculatorEngine {
  const CalculatorEngine();

  double evaluate(
    String input, {
    required bool degrees,
    Map<String, double> variables = const <String, double>{},
  }) {
    final parser = _ExpressionParser(
      input,
      degrees: degrees,
      variables: variables,
    );

    final double value = parser.parse();

    if (value.isNaN || value.isInfinite) {
      throw const FormatException('Invalid result');
    }

    return value;
  }

  String formatNumber(double value) {
    if (value == 0) return '0';

    final double rounded = value.roundToDouble();

    if ((value - rounded).abs() < 1e-12 && value.abs() < 1e15) {
      return rounded.toInt().toString();
    }

    final double absolute = value.abs();

    if (absolute >= 1e12 || absolute < 1e-9) {
      return value
          .toStringAsExponential(10)
          .replaceFirst(RegExp(r'\.?0+e'), 'e');
    }

    String text = value.toStringAsPrecision(12);

    if (!text.contains('e') && !text.contains('E')) {
      text = text.replaceFirst(RegExp(r'\.?0+$'), '');
    }

    return text;
  }

  String toEngineering(double value) {
    if (value == 0) return '0';

    final int exponent =
        (math.log(value.abs()) / math.ln10).floor();
    final int engineeringExponent = (exponent / 3).floor() * 3;
    final double mantissa =
        value / math.pow(10, engineeringExponent).toDouble();

    final String mantissaText = formatNumber(mantissa);

    if (engineeringExponent == 0) {
      return mantissaText;
    }

    return '${mantissaText}E$engineeringExponent';
  }

  String toFraction(double value, {int maxDenominator = 10000}) {
    if (value.isNaN || value.isInfinite) {
      return 'Error';
    }

    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    final bool negative = value < 0;
    final double target = value.abs();

    int bestNumerator = target.round();
    int bestDenominator = 1;
    double bestError =
        (target - bestNumerator / bestDenominator).abs();

    for (int denominator = 1;
        denominator <= maxDenominator;
        denominator++) {
      final int numerator = (target * denominator).round();
      final double approximation = numerator / denominator;
      final double error = (target - approximation).abs();

      if (error < bestError) {
        bestError = error;
        bestNumerator = numerator;
        bestDenominator = denominator;
      }

      if (error < 1e-12) break;
    }

    final int divisor = _gcd(bestNumerator, bestDenominator);
    bestNumerator ~/= divisor;
    bestDenominator ~/= divisor;

    final String sign = negative ? '-' : '';
    return '$sign$bestNumerator/$bestDenominator';
  }

  int _gcd(int a, int b) {
    int x = a.abs();
    int y = b.abs();

    while (y != 0) {
      final int t = x % y;
      x = y;
      y = t;
    }

    return x == 0 ? 1 : x;
  }
}

class _ExpressionParser {
  _ExpressionParser(
    String input, {
    required this.degrees,
    required this.variables,
  }) : _source = input
            .replaceAll('×', '*')
            .replaceAll('÷', '/')
            .replaceAll('−', '-')
            .replaceAll('π', 'pi')
            .replaceAll('√', 'sqrt');

  final String _source;
  final bool degrees;
  final Map<String, double> variables;

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
      } else if (_match('nCr')) {
        value = _combination(value, _parsePower());
      } else if (_match('nPr')) {
        value = _permutation(value, _parsePower());
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
      final String lower = identifier.toLowerCase();
      final String upper = identifier.toUpperCase();

      if (lower == 'pi') {
        return math.pi;
      }

      if (lower == 'e') {
        return math.e;
      }

      if (variables.containsKey(upper)) {
        return variables[upper]!;
      }

      _skipSpaces();
      _expect('(');
      final double argument = _parseExpression();
      _expect(')');

      return _applyFunction(lower, argument);
    }

    throw FormatException(
      'Expected a number, constant, variable, or function '
      'at position $_index',
    );
  }

  double _applyFunction(String name, double x) {
    switch (name) {
      case 'sqrt':
        if (x < 0) {
          throw const FormatException('Square root domain error');
        }
        return math.sqrt(x);

      case 'cbrt':
        return x < 0
            ? -math.pow(-x, 1 / 3).toDouble()
            : math.pow(x, 1 / 3).toDouble();

      case 'log':
        if (x <= 0) {
          throw const FormatException('Log domain error');
        }
        return math.log(x) / math.ln10;

      case 'ln':
        if (x <= 0) {
          throw const FormatException('Ln domain error');
        }
        return math.log(x);

      case 'pow10':
        return math.pow(10, x).toDouble();

      case 'exp':
        return math.exp(x);

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
        if (x < 1) {
          throw const FormatException('acosh domain error');
        }
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

  double _combination(double nValue, double rValue) {
    final int n = _asNonNegativeInteger(nValue, 'nCr');
    final int r = _asNonNegativeInteger(rValue, 'nCr');

    if (r > n) {
      throw const FormatException('nCr requires r ≤ n');
    }

    final int smallR = math.min(r, n - r);
    double result = 1;

    for (int i = 1; i <= smallR; i++) {
      result = result * (n - smallR + i) / i;
    }

    return result;
  }

  double _permutation(double nValue, double rValue) {
    final int n = _asNonNegativeInteger(nValue, 'nPr');
    final int r = _asNonNegativeInteger(rValue, 'nPr');

    if (r > n) {
      throw const FormatException('nPr requires r ≤ n');
    }

    double result = 1;

    for (int i = 0; i < r; i++) {
      result *= n - i;
    }

    return result;
  }

  int _asNonNegativeInteger(double value, String operation) {
    if (value < 0 || value != value.roundToDouble()) {
      throw FormatException(
        '$operation requires non-negative integers',
      );
    }

    if (value > 170) {
      throw FormatException('$operation input is too large');
    }

    return value.toInt();
  }

  double _factorial(double value) {
    final int integer = _asNonNegativeInteger(value, 'Factorial');

    double total = 1;

    for (int i = 2; i <= integer; i++) {
      total *= i;
    }

    return total;
  }

  double _toRadiansIfNeeded(double value) {
    return degrees ? value * math.pi / 180 : value;
  }

  double _fromRadiansIfNeeded(double value) {
    return degrees ? value * 180 / math.pi : value;
  }

  bool _startsImplicitFactor() {
    _skipSpaces();

    if (_index >= _source.length) {
      return false;
    }

    if (_source.startsWith('nCr', _index) ||
        _source.startsWith('nPr', _index)) {
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

      while (_index < _source.length &&
          _isDigit(_source[_index])) {
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

    if (_index >= _source.length ||
        !_isLetter(_source[_index])) {
      return null;
    }

    final int start = _index;

    while (_index < _source.length &&
        (_isLetter(_source[_index]) ||
            _isDigit(_source[_index]))) {
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
