import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'function_table_engine.dart';

class FunctionTableScreen extends StatefulWidget {
  const FunctionTableScreen({super.key});

  @override
  State<FunctionTableScreen> createState() =>
      _FunctionTableScreenState();
}

class _FunctionTableScreenState
    extends State<FunctionTableScreen> {
  final FunctionTableEngine _engine =
      const FunctionTableEngine();

  final TextEditingController _fController =
      TextEditingController(text: 'x^2');
  final TextEditingController _gController =
      TextEditingController();
  final TextEditingController _startController =
      TextEditingController(text: '-5');
  final TextEditingController _endController =
      TextEditingController(text: '5');
  final TextEditingController _stepController =
      TextEditingController(text: '1');

  bool _degrees = true;
  FunctionTableResult? _result;
  String? _validationMessage;

  @override
  void dispose() {
    _fController.dispose();
    _gController.dispose();
    _startController.dispose();
    _endController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  double _parseNumber(
    String raw, {
    required String label,
  }) {
    final double? direct =
        double.tryParse(raw.trim());

    if (direct != null && direct.isFinite) {
      return direct;
    }

    if (raw.contains('/')) {
      final List<String> parts = raw.split('/');

      if (parts.length == 2) {
        final double? numerator =
            double.tryParse(parts[0].trim());
        final double? denominator =
            double.tryParse(parts[1].trim());

        if (numerator != null &&
            denominator != null &&
            denominator != 0) {
          return numerator / denominator;
        }
      }
    }

    throw FormatException(
      '$label: “$raw” is not a valid number.',
    );
  }

  void _generate() {
    FocusScope.of(context).unfocus();

    try {
      final FunctionTableResult result =
          _engine.generate(
        functionF: _fController.text,
        functionG: _gController.text,
        start: _parseNumber(
          _startController.text,
          label: 'Start',
        ),
        end: _parseNumber(
          _endController.text,
          label: 'End',
        ),
        step: _parseNumber(
          _stepController.text,
          label: 'Step',
        ),
        degrees: _degrees,
      );

      setState(() {
        _result = result;
        _validationMessage = null;
      });
    } on FormatException catch (error) {
      setState(() {
        _result = null;
        _validationMessage =
            error.message.toString();
      });
    } catch (_) {
      setState(() {
        _result = null;
        _validationMessage =
            'Could not evaluate the function. '
            'Check the expression and range.';
      });
    }
  }

  void _loadExample() {
    setState(() {
      _fController.text = 'x^2 - 4';
      _gController.text = '2x + 1';
      _startController.text = '-3';
      _endController.text = '3';
      _stepController.text = '1';
      _degrees = true;
      _result = null;
      _validationMessage = null;
    });
  }

  void _clear() {
    setState(() {
      _fController.clear();
      _gController.clear();
      _startController.text = '0';
      _endController.text = '10';
      _stepController.text = '1';
      _result = null;
      _validationMessage = null;
    });
  }

  String _format(double value) {
    if (value == 0) return '0';

    final double rounded = value.roundToDouble();

    if ((value - rounded).abs() < 1e-12 &&
        value.abs() < 1e15) {
      return rounded.toInt().toString();
    }

    String text = value.toStringAsPrecision(10);

    if (!text.contains('e') &&
        !text.contains('E')) {
      text = text.replaceFirst(
        RegExp(r'\.?0+$'),
        '',
      );
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasG =
        _gController.text.trim().isNotEmpty ||
        (_result?.rows.any(
              (FunctionTableRow row) =>
                  row.gx != null,
            ) ??
            false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TABLE Mode'),
        backgroundColor: AppTheme.background,
        surfaceTintColor: AppTheme.background,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                28,
              ),
              children: <Widget>[
                _buildFunctionCard(),
                const SizedBox(height: 14),
                _buildRangeCard(),
                const SizedBox(height: 14),
                _buildActions(),
                if (_validationMessage != null) ...<
                    Widget>[
                  const SizedBox(height: 14),
                  _buildValidationMessage(),
                ],
                if (_result != null) ...<Widget>[
                  const SizedBox(height: 18),
                  _buildTableCard(hasG),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFunctionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.display,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF334155),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _fController,
            decoration: const InputDecoration(
              labelText: 'f(x)',
              hintText: 'x^2 - 4',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _gController,
            decoration: const InputDecoration(
              labelText: 'g(x) — optional',
              hintText: '2x + 1',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          SegmentedButton<bool>(
            segments: const <ButtonSegment<bool>>[
              ButtonSegment<bool>(
                value: true,
                label: Text('DEG'),
              ),
              ButtonSegment<bool>(
                value: false,
                label: Text('RAD'),
              ),
            ],
            selected: <bool>{_degrees},
            onSelectionChanged:
                (Set<bool> selection) {
              setState(() {
                _degrees = selection.first;
                _result = null;
              });
            },
          ),
          const SizedBox(height: 10),
          const Text(
            'Supports calculator syntax such as x^2, '
            '2x, sin(x), cos(x), sqrt(x), log(x), ln(x), π and e.',
            style: TextStyle(
              color: AppTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.display,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF334155),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'x range',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (
              BuildContext context,
              BoxConstraints constraints,
            ) {
              final bool narrow =
                  constraints.maxWidth < 520;

              final List<Widget> fields = <Widget>[
                _rangeField(
                  controller: _startController,
                  label: 'Start',
                ),
                _rangeField(
                  controller: _endController,
                  label: 'End',
                ),
                _rangeField(
                  controller: _stepController,
                  label: 'Step',
                ),
              ];

              if (narrow) {
                return Column(
                  children: fields
                      .map(
                        (Widget field) => Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: field,
                        ),
                      )
                      .toList(),
                );
              }

              return Row(
                children: fields
                    .map(
                      (Widget field) => Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          child: field,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _rangeField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(
        signed: true,
        decimal: true,
      ),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildActions() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: <Widget>[
        FilledButton.icon(
          onPressed: _generate,
          icon: const Icon(Icons.table_chart_outlined),
          label: const Text('Generate table'),
          style: FilledButton.styleFrom(
            backgroundColor:
                const Color(0xFFF6B45F),
            foregroundColor:
                const Color(0xFF2B1A04),
          ),
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
    );
  }

  Widget _buildValidationMessage() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF7F1D1D)
            .withOpacity(0.22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFB91C1C),
        ),
      ),
      child: Text(
        _validationMessage!,
        style: const TextStyle(
          color: Color(0xFFFECACA),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTableCard(bool hasG) {
    final List<FunctionTableRow> rows =
        _result!.rows;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.display,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF334155),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Function table — ${rows.length} rows',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Table(
            border: TableBorder.all(
              color: const Color(0xFF334155),
            ),
            columnWidths: hasG
                ? const <int, TableColumnWidth>{
                    0: FlexColumnWidth(),
                    1: FlexColumnWidth(),
                    2: FlexColumnWidth(),
                  }
                : const <int, TableColumnWidth>{
                    0: FlexColumnWidth(),
                    1: FlexColumnWidth(),
                  },
            children: <TableRow>[
              TableRow(
                decoration: const BoxDecoration(
                  color: AppTheme.numberKey,
                ),
                children: <Widget>[
                  _cell('x', header: true),
                  _cell('f(x)', header: true),
                  if (hasG)
                    _cell('g(x)', header: true),
                ],
              ),
              ...rows.map(
                (FunctionTableRow row) =>
                    TableRow(
                  children: <Widget>[
                    _cell(_format(row.x)),
                    _cell(_format(row.fx)),
                    if (hasG)
                      _cell(
                        row.gx == null
                            ? '—'
                            : _format(row.gx!),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cell(
    String text, {
    bool header = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight:
              header ? FontWeight.w800 : FontWeight.w500,
          color: header
              ? AppTheme.primaryText
              : AppTheme.secondaryText,
        ),
      ),
    );
  }
}
