enum CalculatorButtonKind {
  number,
  function,
  operator,
  equals,
  danger,
  control,
  active,
}

class CalculatorButtonData {
  const CalculatorButtonData(
    this.label, {
    this.kind = CalculatorButtonKind.number,
    this.secondaryLabel,
    this.alphaLabel,
  });

  final String label;
  final CalculatorButtonKind kind;
  final String? secondaryLabel;
  final String? alphaLabel;
}
