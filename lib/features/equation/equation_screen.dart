import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'equation_solver.dart';

enum EquationKind {
  linear('Linear', 'ax + b = c'),
  simultaneous2('Simultaneous 2×2', 'Two equations, x and y'),
  simultaneous3('Simultaneous 3×3', 'Three equations, x, y and z'),
  quadratic('Quadratic', 'ax² + bx + c = 0'),
  polynomial3('Polynomial degree 3', 'ax³ + bx² + cx + d = 0'),
  polynomial4('Polynomial degree 4', 'ax⁴ + bx³ + cx² + dx + e = 0');

  const EquationKind(this.label, this.description);

  final String label;
  final String description;
}

class EquationModeScreen extends StatefulWidget {
  const EquationModeScreen({super.key});

  @override
  State<EquationModeScreen> createState() =>
      _EquationModeScreenState();
}

class _EquationModeScreenState extends State<EquationModeScreen> {
  final EquationSolver _solver = const EquationSolver();

  EquationKind _kind = EquationKind.linear;
  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};
  EquationSolution? _solution;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _resetControllers();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    for (final TextEditingController controller
        in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }

  void _resetControllers() {
    _disposeControllers();

    for (final _FieldSpec field in _fieldsFor(_kind)) {
      _controllers[field.key] = TextEditingController();
    }

    _solution = null;
    _validationMessage = null;
  }

  void _changeKind(EquationKind? kind) {
    if (kind == null || kind == _kind) return;

    setState(() {
      _kind = kind;
      _resetControllers();
    });
  }

  double _value(String key) {
    final String raw = _controllers[key]!.text.trim();

    if (raw.isEmpty) {
      throw FormatException('Enter a value for $key.');
    }

    final double? direct = double.tryParse(raw);
    if (direct != null) return direct;

    if (raw.contains('/')) {
      final List<String> pieces = raw.split('/');
      if (pieces.length == 2) {
        final double? numerator =
            double.tryParse(pieces[0].trim());
        final double? denominator =
            double.tryParse(pieces[1].trim());

        if (numerator != null &&
            denominator != null &&
            denominator != 0) {
          return numerator / denominator;
        }
      }
    }

    throw FormatException(
      '“$raw” is not a valid number. You can also enter a fraction such as 1/2.',
    );
  }

  void _solve() {
    FocusScope.of(context).unfocus();

    try {
      final EquationSolution solution;

      switch (_kind) {
        case EquationKind.linear:
          solution = _solver.solveLinear(
            a: _value('a'),
            b: _value('b'),
            c: _value('c'),
          );
          break;

        case EquationKind.simultaneous2:
          solution = _solver.solveSimultaneous(
            coefficients: <List<double>>[
              <double>[_value('a1'), _value('b1')],
              <double>[_value('a2'), _value('b2')],
            ],
            constants: <double>[
              _value('c1'),
              _value('c2'),
            ],
            variableNames: const <String>['x', 'y'],
          );
          break;

        case EquationKind.simultaneous3:
          solution = _solver.solveSimultaneous(
            coefficients: <List<double>>[
              <double>[
                _value('a1'),
                _value('b1'),
                _value('c1'),
              ],
              <double>[
                _value('a2'),
                _value('b2'),
                _value('c2'),
              ],
              <double>[
                _value('a3'),
                _value('b3'),
                _value('c3'),
              ],
            ],
            constants: <double>[
              _value('d1'),
              _value('d2'),
              _value('d3'),
            ],
            variableNames: const <String>['x', 'y', 'z'],
          );
          break;

        case EquationKind.quadratic:
          solution = _solver.solveQuadratic(
            a: _value('a'),
            b: _value('b'),
            c: _value('c'),
          );
          break;

        case EquationKind.polynomial3:
          solution = _solver.solvePolynomial(
            <double>[
              _value('a'),
              _value('b'),
              _value('c'),
              _value('d'),
            ],
          );
          break;

        case EquationKind.polynomial4:
          solution = _solver.solvePolynomial(
            <double>[
              _value('a'),
              _value('b'),
              _value('c'),
              _value('d'),
              _value('e'),
            ],
          );
          break;
      }

      setState(() {
        _solution = solution;
        _validationMessage = null;
      });
    } on FormatException catch (error) {
      setState(() {
        _solution = null;
        _validationMessage = error.message.toString();
      });
    }
  }

  void _clear() {
    setState(_resetControllers);
  }

  void _loadExample() {
    final Map<String, String> values;

    switch (_kind) {
      case EquationKind.linear:
        values = const <String, String>{
          'a': '2',
          'b': '3',
          'c': '11',
        };
        break;

      case EquationKind.simultaneous2:
        values = const <String, String>{
          'a1': '2',
          'b1': '1',
          'c1': '5',
          'a2': '1',
          'b2': '-1',
          'c2': '1',
        };
        break;

      case EquationKind.simultaneous3:
        values = const <String, String>{
          'a1': '1',
          'b1': '1',
          'c1': '1',
          'd1': '6',
          'a2': '2',
          'b2': '-1',
          'c2': '1',
          'd2': '3',
          'a3': '1',
          'b3': '2',
          'c3': '-1',
          'd3': '2',
        };
        break;

      case EquationKind.quadratic:
        values = const <String, String>{
          'a': '1',
          'b': '-5',
          'c': '6',
        };
        break;

      case EquationKind.polynomial3:
        values = const <String, String>{
          'a': '1',
          'b': '-6',
          'c': '11',
          'd': '-6',
        };
        break;

      case EquationKind.polynomial4:
        values = const <String, String>{
          'a': '1',
          'b': '0',
          'c': '-5',
          'd': '0',
          'e': '4',
        };
        break;
    }

    setState(() {
      for (final MapEntry<String, String> entry in values.entries) {
        _controllers[entry.key]?.text = entry.value;
      }
      _solution = null;
      _validationMessage = null;
    });
  }

  List<_FieldSpec> _fieldsFor(EquationKind kind) {
    switch (kind) {
      case EquationKind.linear:
        return const <_FieldSpec>[
          _FieldSpec('a', 'a', 'Coefficient of x'),
          _FieldSpec('b', 'b', 'Constant on left'),
          _FieldSpec('c', 'c', 'Right-hand side'),
        ];

      case EquationKind.simultaneous2:
        return const <_FieldSpec>[
          _FieldSpec('a1', 'a₁', 'x coefficient, equation 1'),
          _FieldSpec('b1', 'b₁', 'y coefficient, equation 1'),
          _FieldSpec('c1', 'c₁', 'constant, equation 1'),
          _FieldSpec('a2', 'a₂', 'x coefficient, equation 2'),
          _FieldSpec('b2', 'b₂', 'y coefficient, equation 2'),
          _FieldSpec('c2', 'c₂', 'constant, equation 2'),
        ];

      case EquationKind.simultaneous3:
        return const <_FieldSpec>[
          _FieldSpec('a1', 'a₁', 'x coefficient, equation 1'),
          _FieldSpec('b1', 'b₁', 'y coefficient, equation 1'),
          _FieldSpec('c1', 'c₁', 'z coefficient, equation 1'),
          _FieldSpec('d1', 'd₁', 'constant, equation 1'),
          _FieldSpec('a2', 'a₂', 'x coefficient, equation 2'),
          _FieldSpec('b2', 'b₂', 'y coefficient, equation 2'),
          _FieldSpec('c2', 'c₂', 'z coefficient, equation 2'),
          _FieldSpec('d2', 'd₂', 'constant, equation 2'),
          _FieldSpec('a3', 'a₃', 'x coefficient, equation 3'),
          _FieldSpec('b3', 'b₃', 'y coefficient, equation 3'),
          _FieldSpec('c3', 'c₃', 'z coefficient, equation 3'),
          _FieldSpec('d3', 'd₃', 'constant, equation 3'),
        ];

      case EquationKind.quadratic:
        return const <_FieldSpec>[
          _FieldSpec('a', 'a', 'x² coefficient'),
          _FieldSpec('b', 'b', 'x coefficient'),
          _FieldSpec('c', 'c', 'constant'),
        ];

      case EquationKind.polynomial3:
        return const <_FieldSpec>[
          _FieldSpec('a', 'a', 'x³ coefficient'),
          _FieldSpec('b', 'b', 'x² coefficient'),
          _FieldSpec('c', 'c', 'x coefficient'),
          _FieldSpec('d', 'd', 'constant'),
        ];

      case EquationKind.polynomial4:
        return const <_FieldSpec>[
          _FieldSpec('a', 'a', 'x⁴ coefficient'),
          _FieldSpec('b', 'b', 'x³ coefficient'),
          _FieldSpec('c', 'c', 'x² coefficient'),
          _FieldSpec('d', 'd', 'x coefficient'),
          _FieldSpec('e', 'e', 'constant'),
        ];
    }
  }

  String _equationTemplate() {
    switch (_kind) {
      case EquationKind.linear:
        return 'ax + b = c';
      case EquationKind.simultaneous2:
        return 'a₁x + b₁y = c₁\na₂x + b₂y = c₂';
      case EquationKind.simultaneous3:
        return 'a₁x + b₁y + c₁z = d₁\n'
            'a₂x + b₂y + c₂z = d₂\n'
            'a₃x + b₃y + c₃z = d₃';
      case EquationKind.quadratic:
        return 'ax² + bx + c = 0';
      case EquationKind.polynomial3:
        return 'ax³ + bx² + cx + d = 0';
      case EquationKind.polynomial4:
        return 'ax⁴ + bx³ + cx² + dx + e = 0';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<_FieldSpec> fields = _fieldsFor(_kind);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EQN Mode'),
        backgroundColor: AppTheme.background,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: <Widget>[
                _HeaderCard(
                  template: _equationTemplate(),
                  kind: _kind,
                  onKindChanged: _changeKind,
                ),
                const SizedBox(height: 14),
                Text(
                  'Enter coefficients',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (
                    BuildContext context,
                    BoxConstraints constraints,
                  ) {
                    final int columns = constraints.maxWidth >= 620
                        ? 4
                        : constraints.maxWidth >= 420
                            ? 3
                            : 2;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: fields.length,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.65,
                      ),
                      itemBuilder: (
                        BuildContext context,
                        int index,
                      ) {
                        final _FieldSpec field = fields[index];
                        return TextField(
                          controller: _controllers[field.key],
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: field.label,
                            helperText: field.help,
                            helperMaxLines: 2,
                            filled: true,
                            fillColor: AppTheme.numberKey,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                if (_validationMessage != null) ...<Widget>[
                  const SizedBox(height: 12),
                  _MessageCard(
                    icon: Icons.error_outline,
                    text: _validationMessage!,
                    color: const Color(0xFFFCA5A5),
                  ),
                ],
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    FilledButton.icon(
                      onPressed: _solve,
                      icon: const Icon(Icons.calculate_outlined),
                      label: const Text('Solve'),
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
                ),
                if (_solution != null) ...<Widget>[
                  const SizedBox(height: 18),
                  _ResultCard(solution: _solution!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.template,
    required this.kind,
    required this.onKindChanged,
  });

  final String template;
  final EquationKind kind;
  final ValueChanged<EquationKind?> onKindChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.display,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          DropdownButtonFormField<EquationKind>(
            initialValue: kind,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Equation type',
              border: OutlineInputBorder(),
            ),
            items: EquationKind.values
                .map(
                  (EquationKind value) => DropdownMenuItem<EquationKind>(
                    value: value,
                    child: Text(value.label),
                  ),
                )
                .toList(),
            onChanged: onKindChanged,
          ),
          const SizedBox(height: 14),
          Text(
            kind.description,
            style: const TextStyle(
              color: AppTheme.mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          SelectableText(
            template,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              height: 1.45,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.solution});

  final EquationSolution solution;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color accent;

    switch (solution.status) {
      case EquationStatus.unique:
        icon = Icons.check_circle_outline;
        accent = const Color(0xFF86EFAC);
        break;
      case EquationStatus.multiple:
        icon = Icons.all_inclusive;
        accent = const Color(0xFFFDE68A);
        break;
      case EquationStatus.none:
        icon = Icons.block;
        accent = const Color(0xFFFCA5A5);
        break;
      case EquationStatus.invalid:
        icon = Icons.error_outline;
        accent = const Color(0xFFFCA5A5);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.display,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  solution.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...solution.lines.map(
            (String line) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SelectableText(
                line,
                style: const TextStyle(
                  fontSize: 17,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _FieldSpec {
  const _FieldSpec(this.key, this.label, this.help);

  final String key;
  final String label;
  final String help;
}
