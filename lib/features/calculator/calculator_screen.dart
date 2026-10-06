import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/calculator_mode.dart';
import '../../services/math_scanner_service.dart';
import '../equation/equation_screen.dart';
import '../statistics/statistics_screen.dart';
import 'calculator_button.dart';
import 'calculator_engine.dart';
import 'calculator_state.dart';
import 'widgets/calculator_display.dart';
import 'widgets/calculator_keypad.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() =>
      _CalculatorScreenState();
}

class _CalculatorScreenState
    extends State<CalculatorScreen> {
  final CalculatorState _state = CalculatorState();
  final CalculatorEngine _engine = const CalculatorEngine();
  final MathScannerService _scanner =
      const MathScannerService();

  static const Map<String, String> _alphaKeys =
      <String, String>{
    '7': 'A',
    '8': 'B',
    '9': 'C',
    '4': 'D',
    '1': 'X',
    '2': 'Y',
    '3': 'M',
  };

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
    'pow10(',
    'sqrt(',
    'cbrt(',
    'exp(',
    'sin(',
    'cos(',
    'tan(',
    'log(',
    'ln(',
  ];

  Future<void> _scanMathProblem() async {
    if (!_scanner.isAvailable) {
      _showMessage(
        'Camera OCR is reserved for the Android/iOS build. '
        'Keep testing the calculator in Chrome for now.',
      );
      return;
    }

    try {
      final String? scanned =
          await _scanner.scanFromCamera();

      if (scanned == null || !mounted) {
        return;
      }

      setState(() {
        _state.equation =
            scanned.isEmpty ? '0' : scanned;
        _state.result =
            scanned.isEmpty ? 'No equation found' : 'Scanned';
      });
    } on UnsupportedError catch (error) {
      _showMessage(error.message ?? 'Camera is unavailable.');
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _state.result = 'Scan failed';
      });
    }
  }

  void _buttonPressed(String text) {
    if (_state.alphaEnabled &&
        _alphaKeys.containsKey(text)) {
      _appendText(_alphaKeys[text]!);

      setState(() {
        _state.alphaEnabled = false;
      });
      return;
    }

    switch (text) {
      case 'AC':
      case 'ON':
        setState(_state.reset);
        return;

      case 'DEL':
        _deleteLast();
        return;

      case 'SHIFT':
        setState(() {
          _state.shiftEnabled =
              !_state.shiftEnabled;
        });
        return;

      case 'ALPHA':
        setState(() {
          _state.alphaEnabled =
              !_state.alphaEnabled;
        });
        return;

      case 'MODE':
        _showModeSheet();
        return;

      case 'DEG/RAD':
        setState(() {
          _state.isDegreeMode =
              !_state.isDegreeMode;
        });
        return;

      case 'hyp':
        setState(() {
          _state.hyperbolicEnabled =
              !_state.hyperbolicEnabled;
        });
        return;

      case '=':
        _calculate();
        return;

      case 'Ans':
        _appendText(
          _engine.formatNumber(_state.lastAnswer),
        );
        return;

      case 'STO':
        _selectRegister(store: true);
        return;

      case 'RCL':
        _selectRegister(store: false);
        return;

      case 'ENG':
        setState(() {
          _state.result =
              _engine.toEngineering(_state.lastAnswer);
        });
        return;

      case 'a/b':
        setState(() {
          _state.result =
              _engine.toFraction(_state.lastAnswer);
        });
        return;

      case 'x⁻¹':
        if (_consumeShift()) {
          _appendText('!');
        } else {
          _appendText('^(-1)');
        }
        return;

      case 'x²':
        if (_consumeShift()) {
          _appendText('^3');
        } else {
          _appendText('^2');
        }
        return;

      case 'x³':
        _appendText('^3');
        return;

      case '√':
        _appendFunction(
          _consumeShift() ? 'cbrt' : 'sqrt',
        );
        return;

      case '∛':
        _appendFunction('cbrt');
        return;

      case 'log':
        _appendFunction(
          _consumeShift() ? 'pow10' : 'log',
        );
        return;

      case 'ln':
        _appendFunction(
          _consumeShift() ? 'exp' : 'ln',
        );
        return;

      case 'sin':
      case 'cos':
      case 'tan':
        _appendTrigFunction(text);
        return;

      case 'π':
        _appendText(
          _consumeShift() ? 'e' : 'π',
        );
        return;

      case 'e':
        _appendText('e');
        return;

      case 'x!':
        _appendText('!');
        return;

      case 'nCr':
      case 'nPr':
        _appendCombinatoric(text);
        return;

      case '(-)':
        _appendText('-');
        return;

      case '%':
        _appendText('%');
        return;

      case '^':
        _appendOperator('^');
        return;

      case 'EXP':
        _appendText('E');
        return;

      case '×':
      case '÷':
      case '+':
      case '−':
        _appendOperator(text);
        return;

      case '.':
        _appendDecimal();
        return;

      default:
        _appendText(text);
    }
  }

  bool _consumeShift() {
    final bool wasEnabled = _state.shiftEnabled;

    if (wasEnabled) {
      setState(() {
        _state.shiftEnabled = false;
      });
    }

    return wasEnabled;
  }

  void _appendTrigFunction(String base) {
    String functionName = base;

    if (_state.hyperbolicEnabled &&
        _state.shiftEnabled) {
      functionName = 'a${base}h';
    } else if (_state.hyperbolicEnabled) {
      functionName = '${base}h';
    } else if (_state.shiftEnabled) {
      functionName = 'a$base';
    }

    _appendFunction(functionName);

    setState(() {
      _state.clearModifiers();
    });
  }

  void _appendFunction(String functionName) {
    _appendText('$functionName(');
  }

  void _appendText(String value) {
    setState(() {
      if (_state.equation == '0' ||
          _state.result == 'Error') {
        _state.equation = value;
      } else {
        _state.equation += value;
      }

      if (_state.result == 'Error' ||
          _state.result == 'Scanned' ||
          _state.result == 'Scan failed') {
        _state.result = '0';
      }
    });
  }

  void _appendOperator(String value) {
    setState(() {
      if (_state.equation == '0' &&
          value != '−') {
        return;
      }

      if (_endsWithOperator(_state.equation)) {
        _state.equation =
            _state.equation.substring(
                  0,
                  _state.equation.length - 1,
                ) +
                value;
      } else {
        _state.equation += value;
      }
    });
  }

  void _appendCombinatoric(String value) {
    setState(() {
      if (_state.equation == '0') {
        return;
      }

      _state.equation += value;
    });
  }

  void _appendDecimal() {
    setState(() {
      if (_state.equation == '0') {
        _state.equation = '0.';
        return;
      }

      final String currentNumber =
          _state.equation
              .split(
                RegExp(r'[+\-×÷^()%!]'),
              )
              .last;

      if (!currentNumber.contains('.')) {
        _state.equation += '.';
      }
    });
  }

  bool _endsWithOperator(String value) {
    if (value.isEmpty) return false;

    return <String>{
      '+',
      '−',
      '-',
      '×',
      '÷',
      '^',
    }.contains(value[value.length - 1]);
  }

  void _deleteLast() {
    setState(() {
      if (_state.equation == '0' ||
          _state.equation.isEmpty) {
        _state.equation = '0';
        return;
      }

      for (final String token
          in _functionTokens) {
        if (_state.equation.endsWith(token)) {
          _state.equation =
              _state.equation.substring(
            0,
            _state.equation.length -
                token.length,
          );

          if (_state.equation.isEmpty) {
            _state.equation = '0';
          }
          return;
        }
      }

      for (final String token
          in const <String>['nCr', 'nPr']) {
        if (_state.equation.endsWith(token)) {
          _state.equation =
              _state.equation.substring(
            0,
            _state.equation.length -
                token.length,
          );

          if (_state.equation.isEmpty) {
            _state.equation = '0';
          }
          return;
        }
      }

      _state.equation =
          _state.equation.substring(
        0,
        _state.equation.length - 1,
      );

      if (_state.equation.isEmpty) {
        _state.equation = '0';
      }
    });
  }

  void _calculate() {
    try {
      final double value = _engine.evaluate(
        _state.equation,
        degrees: _state.isDegreeMode,
        variables: _state.variables,
      );

      setState(() {
        _state.lastAnswer = value;
        _state.result =
            _engine.formatNumber(value);
        _state.clearModifiers();
      });
    } catch (_) {
      setState(() {
        _state.result = 'Error';
      });
    }
  }

  Future<void> _selectRegister({
    required bool store,
  }) async {
    final String? selected =
        await showModalBottomSheet<String>(
      context: context,
      backgroundColor:
          const Color(0xFF1E293B),
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    store
                        ? 'Store answer in register'
                        : 'Recall register',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _state.variables.keys
                      .map((String key) {
                    return FilledButton.tonal(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          key,
                        );
                      },
                      child: Text(
                        '$key = '
                        '${_engine.formatNumber(_state.variables[key]!)}',
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || !mounted) {
      return;
    }

    if (store) {
      setState(() {
        _state.variables[selected] =
            _state.lastAnswer;
      });

      _showMessage(
        'Stored ${_engine.formatNumber(_state.lastAnswer)} '
        'in $selected.',
      );
    } else {
      _appendText(selected);
    }
  }

  Future<void> _showModeSheet() async {
    final CalculatorMode? selected =
        await showModalBottomSheet<
            CalculatorMode>(
      context: context,
      backgroundColor:
          const Color(0xFF1E293B),
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding:
                const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              20,
            ),
            children: <Widget>[
              const Text(
                'Calculator mode',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ...CalculatorMode.values.map(
                (CalculatorMode mode) {
                  return ListTile(
                    enabled: mode.isImplemented,
                    title: Text(mode.label),
                    subtitle:
                        Text(mode.description),
                    trailing:
                        mode == _state.mode
                            ? const Icon(
                                Icons
                                    .check_circle,
                              )
                            : mode.isImplemented
                                ? null
                                : const Text(
                                    'Next',
                                  ),
                    onTap: mode.isImplemented
                        ? () =>
                            Navigator.pop(
                              context,
                              mode,
                            )
                        : null,
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading:
                    const Icon(Icons.straighten),
                title: Text(
                  _state.isDegreeMode
                      ? 'Switch to RAD'
                      : 'Switch to DEG',
                ),
                subtitle: Text(
                  'Current angle mode: '
                  '${_state.isDegreeMode ? 'DEG' : 'RAD'}',
                ),
                onTap: () {
                  setState(() {
                    _state.isDegreeMode =
                        !_state
                            .isDegreeMode;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );

    if (selected == null || !mounted) {
      return;
    }

    if (selected == CalculatorMode.eqn) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              const EquationModeScreen(),
        ),
      );
      return;
    }

    if (selected == CalculatorMode.stat) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              const StatisticsModeScreen(),
        ),
      );
      return;
    }

    setState(() {
      _state.mode = selected;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  List<CalculatorButtonData>
      _controlButtons() {
    return <CalculatorButtonData>[
      CalculatorButtonData(
        'SHIFT',
        kind: _state.shiftEnabled
            ? CalculatorButtonKind.active
            : CalculatorButtonKind.control,
      ),
      CalculatorButtonData(
        'ALPHA',
        kind: _state.alphaEnabled
            ? CalculatorButtonKind.active
            : CalculatorButtonKind.control,
      ),
      const CalculatorButtonData(
        'MODE',
        kind: CalculatorButtonKind.control,
      ),
      const CalculatorButtonData(
        'ON',
        kind: CalculatorButtonKind.control,
      ),
    ];
  }

  List<CalculatorButtonData>
      _scientificButtons() {
    return <CalculatorButtonData>[
      CalculatorButtonData(
        'x⁻¹',
        secondaryLabel:
            _state.shiftEnabled ? 'x!' : null,
        kind: CalculatorButtonKind.function,
      ),
      CalculatorButtonData(
        'x²',
        secondaryLabel:
            _state.shiftEnabled ? 'x³' : null,
        kind: CalculatorButtonKind.function,
      ),
      CalculatorButtonData(
        '√',
        secondaryLabel:
            _state.shiftEnabled ? '∛' : null,
        kind: CalculatorButtonKind.function,
      ),
      CalculatorButtonData(
        'log',
        secondaryLabel:
            _state.shiftEnabled ? '10ˣ' : null,
        kind: CalculatorButtonKind.function,
      ),
      CalculatorButtonData(
        'ln',
        secondaryLabel:
            _state.shiftEnabled ? 'eˣ' : null,
        kind: CalculatorButtonKind.function,
      ),
      const CalculatorButtonData(
        'x³',
        kind: CalculatorButtonKind.function,
      ),
      const CalculatorButtonData(
        '∛',
        kind: CalculatorButtonKind.function,
      ),
      const CalculatorButtonData(
        'nPr',
        kind: CalculatorButtonKind.function,
      ),
      const CalculatorButtonData(
        'nCr',
        kind: CalculatorButtonKind.function,
      ),
      const CalculatorButtonData(
        'x!',
        kind: CalculatorButtonKind.function,
      ),
      const CalculatorButtonData(
        '(-)',
        kind: CalculatorButtonKind.function,
      ),
      CalculatorButtonData(
        'π',
        secondaryLabel:
            _state.shiftEnabled ? 'e' : null,
        kind: CalculatorButtonKind.function,
      ),
      CalculatorButtonData(
        'hyp',
        kind: _state.hyperbolicEnabled
            ? CalculatorButtonKind.active
            : CalculatorButtonKind.function,
      ),
      CalculatorButtonData(
        'sin',
        secondaryLabel:
            _state.shiftEnabled
                ? 'sin⁻¹'
                : null,
        kind: CalculatorButtonKind.function,
      ),
      CalculatorButtonData(
        'cos',
        secondaryLabel:
            _state.shiftEnabled
                ? 'cos⁻¹'
                : null,
        kind: CalculatorButtonKind.function,
      ),
      CalculatorButtonData(
        'tan',
        secondaryLabel:
            _state.shiftEnabled
                ? 'tan⁻¹'
                : null,
        kind: CalculatorButtonKind.function,
      ),
      const CalculatorButtonData(
        'STO',
        kind: CalculatorButtonKind.function,
      ),
      const CalculatorButtonData(
        'RCL',
        kind: CalculatorButtonKind.function,
      ),
      const CalculatorButtonData(
        'ENG',
        kind: CalculatorButtonKind.function,
      ),
      const CalculatorButtonData(
        '(',
        kind: CalculatorButtonKind.function,
      ),
      const CalculatorButtonData(
        ')',
        kind: CalculatorButtonKind.function,
      ),
      const CalculatorButtonData(
        'a/b',
        kind: CalculatorButtonKind.function,
      ),
      const CalculatorButtonData(
        '%',
        kind: CalculatorButtonKind.function,
      ),
      const CalculatorButtonData(
        '^',
        kind: CalculatorButtonKind.function,
      ),
      const CalculatorButtonData(
        'e',
        kind: CalculatorButtonKind.function,
      ),
    ];
  }

  List<CalculatorButtonData>
      _keypadButtons() {
    CalculatorButtonData number(
      String value,
    ) {
      return CalculatorButtonData(
        value,
        alphaLabel: _state.alphaEnabled
            ? _alphaKeys[value]
            : null,
      );
    }

    return <CalculatorButtonData>[
      number('7'),
      number('8'),
      number('9'),
      const CalculatorButtonData(
        'DEL',
        kind: CalculatorButtonKind.danger,
      ),
      const CalculatorButtonData(
        'AC',
        kind: CalculatorButtonKind.danger,
      ),
      number('4'),
      number('5'),
      number('6'),
      const CalculatorButtonData(
        '×',
        kind: CalculatorButtonKind.operator,
      ),
      const CalculatorButtonData(
        '÷',
        kind: CalculatorButtonKind.operator,
      ),
      number('1'),
      number('2'),
      number('3'),
      const CalculatorButtonData(
        '+',
        kind: CalculatorButtonKind.operator,
      ),
      const CalculatorButtonData(
        '−',
        kind: CalculatorButtonKind.operator,
      ),
      number('0'),
      const CalculatorButtonData('.'),
      const CalculatorButtonData(
        'EXP',
        kind: CalculatorButtonKind.function,
      ),
      const CalculatorButtonData(
        'Ans',
        kind: CalculatorButtonKind.function,
      ),
      const CalculatorButtonData(
        '=',
        kind: CalculatorButtonKind.equals,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 520,
            ),
            child: LayoutBuilder(
              builder: (
                BuildContext context,
                BoxConstraints constraints,
              ) {
                return SingleChildScrollView(
                  padding:
                      const EdgeInsets.all(12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: math.max(
                        0.0,
                        constraints.maxHeight -
                            24,
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        CalculatorDisplay(
                          equation:
                              _state.equation,
                          result:
                              _state.result,
                          isDegreeMode:
                              _state
                                  .isDegreeMode,
                          shiftEnabled:
                              _state
                                  .shiftEnabled,
                          alphaEnabled:
                              _state
                                  .alphaEnabled,
                          hyperbolicEnabled:
                              _state
                                  .hyperbolicEnabled,
                          modeLabel:
                              _state.mode.label,
                          onAngleModeTap: () =>
                              _buttonPressed(
                            'DEG/RAD',
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CalculatorKeypad(
                          controlButtons:
                              _controlButtons(),
                          scientificButtons:
                              _scientificButtons(),
                          keypadButtons:
                              _keypadButtons(),
                          onPressed:
                              _buttonPressed,
                          onScanPressed:
                              _scanMathProblem,
                        ),
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
}
