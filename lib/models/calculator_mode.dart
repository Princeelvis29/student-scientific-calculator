enum CalculatorMode {
  comp('COMP', 'Scientific calculations', true),
  stat('STAT', 'Statistics', true),
  eqn('EQN', 'Equations & simultaneous equations', true),
  matrix('MATRIX', 'Matrix calculations', true),
  vector('VECTOR', 'Vector calculations', true),
  table('TABLE', 'Function tables', true),
  complex('CMPLX', 'Complex numbers', true);

  const CalculatorMode(
    this.label,
    this.description,
    this.isImplemented,
  );

  final String label;
  final String description;
  final bool isImplemented;
}
