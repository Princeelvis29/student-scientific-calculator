enum FormulaSubject {
  mathematics('Mathematics'),
  physics('Physics'),
  chemistry('Chemistry');

  const FormulaSubject(this.label);

  final String label;
}

class FormulaEntry {
  const FormulaEntry({
    required this.id,
    required this.subject,
    required this.topic,
    required this.title,
    required this.formula,
    required this.symbols,
    required this.units,
    required this.explanation,
    required this.example,
    required this.relatedMode,
  });

  final String id;
  final FormulaSubject subject;
  final String topic;
  final String title;
  final String formula;
  final String symbols;
  final String units;
  final String explanation;
  final String example;
  final String relatedMode;

  String get searchableText => <String>[
        subject.label,
        topic,
        title,
        formula,
        symbols,
        units,
        explanation,
        example,
        relatedMode,
      ].join(' ').toLowerCase();
}
