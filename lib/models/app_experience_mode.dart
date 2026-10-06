enum AppExperienceMode {
  study(
    'Study Mode',
    'Full learning tools: formulas, history, graphing, camera solver and explanations.',
  ),
  exam(
    'Exam Mode',
    'Calculator-only environment with study aids hidden.',
  );

  const AppExperienceMode(
    this.label,
    this.description,
  );

  final String label;
  final String description;

  bool get isStudy => this == AppExperienceMode.study;
}
