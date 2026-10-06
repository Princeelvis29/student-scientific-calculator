import '../../models/calculator_mode.dart';

class CalculatorState {
  String equation = '0';
  String result = '0';

  bool isDegreeMode = true;
  bool shiftEnabled = false;
  bool alphaEnabled = false;
  bool hyperbolicEnabled = false;

  double lastAnswer = 0;
  CalculatorMode mode = CalculatorMode.comp;

  final Map<String, double> variables = <String, double>{
    'A': 0,
    'B': 0,
    'C': 0,
    'D': 0,
    'X': 0,
    'Y': 0,
    'M': 0,
  };

  void reset() {
    equation = '0';
    result = '0';
    shiftEnabled = false;
    alphaEnabled = false;
    hyperbolicEnabled = false;
  }

  void clearModifiers() {
    shiftEnabled = false;
    alphaEnabled = false;
  }
}
