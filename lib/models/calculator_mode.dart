enum CalculatorMode {
  comp('COMP', 'Scientific calculations', true),
  stat('STAT', 'Statistics', false),
  eqn('EQN', 'Equations & simultaneous equations', false),
  matrix('MATRIX', 'Matrix calculations', false),
  vector('VECTOR', 'Vector calculations', false),
  table('TABLE', 'Function tables', false),
  complex('CMPLX', 'Complex numbers', false);

  const CalculatorMode(
    this.label,
    this.description,
    this.isImplemented,
  );

  final String label;
  final String description;
  final bool isImplemented;
}
