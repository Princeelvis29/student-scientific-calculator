import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'graphing_engine.dart';

class GraphFunctionDefinition {
  const GraphFunctionDefinition({
    required this.name,
    required this.expression,
  });

  final String name;
  final String expression;
}

class GraphFunctionTableScreen extends StatefulWidget {
  const GraphFunctionTableScreen({
    super.key,
    required this.functions,
    required this.degrees,
    required this.initialStart,
    required this.initialEnd,
  });

  final List<GraphFunctionDefinition> functions;
  final bool degrees;
  final double initialStart;
  final double initialEnd;

  @override
  State<GraphFunctionTableScreen> createState() =>
      _GraphFunctionTableScreenState();
}

class _GraphFunctionTableScreenState
    extends State<GraphFunctionTableScreen> {
  final GraphingEngine _engine =
      const GraphingEngine();

  late final TextEditingController _startController;
  late final TextEditingController _endController;
  late final TextEditingController _stepController;

  List<_GraphTableRow> _rows = <_GraphTableRow>[];
  String? _error;

  @override
  void initState() {
    super.initState();

    _startController = TextEditingController(
      text: _format(widget.initialStart),
    );
    _endController = TextEditingController(
      text: _format(widget.initialEnd),
    );

    final double suggestedStep =
        (widget.initialEnd - widget.initialStart) / 10;

    _stepController = TextEditingController(
      text: _format(
        suggestedStep.abs() < 1e-9
            ? 1
            : suggestedStep,
      ),
    );

    _generate();
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  double _parse(
    TextEditingController controller,
    String label,
  ) {
    final double? value =
        double.tryParse(controller.text.trim());

    if (value == null || !value.isFinite) {
      throw FormatException(
        '$label must be a finite number.',
      );
    }

    return value;
  }

  void _generate() {
    try {
      final double start =
          _parse(_startController, 'Start');
      final double end =
          _parse(_endController, 'End');
      final double step =
          _parse(_stepController, 'Step');

      if (step == 0) {
        throw const FormatException(
          'Step cannot be zero.',
        );
      }

      if (start < end && step < 0) {
        throw const FormatException(
          'Use a positive step when start < end.',
        );
      }

      if (start > end && step > 0) {
        throw const FormatException(
          'Use a negative step when start > end.',
        );
      }

      final List<_GraphTableRow> rows =
          <_GraphTableRow>[];

      bool inRange(double x) => step > 0
          ? x <= end + 1e-12
          : x >= end - 1e-12;

      for (int index = 0; index < 201; index++) {
        final double x = start + (step * index);

        if (!inRange(x)) break;

        final List<double?> values =
            <double?>[];

        for (final GraphFunctionDefinition function
            in widget.functions) {
          try {
            final double y = _engine.evaluate(
              expression: function.expression,
              x: x,
              degrees: widget.degrees,
            );

            values.add(
              y.isFinite ? y : null,
            );
          } catch (_) {
            values.add(null);
          }
        }

        rows.add(
          _GraphTableRow(
            x: x,
            values: values,
          ),
        );
      }

      if (rows.isEmpty) {
        throw const FormatException(
          'The range produced no rows.',
        );
      }

      final double nextX =
          start + (step * rows.length);

      if (inRange(nextX)) {
        throw const FormatException(
          'More than 201 rows would be generated. '
          'Increase the step size.',
        );
      }

      setState(() {
        _rows = rows;
        _error = null;
      });
    } on FormatException catch (error) {
      setState(() {
        _rows = <_GraphTableRow>[];
        _error = error.message.toString();
      });
    }
  }

  String _format(double value) {
    if (value.abs() < 1e-12) return '0';

    final double rounded = value.roundToDouble();

    if ((value - rounded).abs() < 1e-12 &&
        value.abs() < 1e15) {
      return rounded.toInt().toString();
    }

    String text = value.toStringAsPrecision(9);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Graph Table'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: 980),
            child: ListView(
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                28,
              ),
              children: <Widget>[
                _buildRangeCard(),
                if (_error != null) ...<Widget>[
                  const SizedBox(height: 12),
                  _buildError(),
                ],
                if (_rows.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  _buildTable(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRangeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.display,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF334155),
        ),
      ),
      child: Column(
        children: <Widget>[
          LayoutBuilder(
            builder: (
              BuildContext context,
              BoxConstraints constraints,
            ) {
              final bool narrow =
                  constraints.maxWidth < 520;

              final List<Widget> fields =
                  <Widget>[
                _rangeField(
                  _startController,
                  'Start',
                ),
                _rangeField(
                  _endController,
                  'End',
                ),
                _rangeField(
                  _stepController,
                  'Step',
                ),
              ];

              if (narrow) {
                return Column(
                  children: fields
                      .map(
                        (Widget child) => Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: child,
                        ),
                      )
                      .toList(),
                );
              }

              return Row(
                children: fields
                    .map(
                      (Widget child) =>
                          Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 4,
                          ),
                          child: child,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _generate,
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Regenerate table',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rangeField(
    TextEditingController controller,
    String label,
  ) {
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

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF7F1D1D)
            .withOpacity(0.22),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFB91C1C),
        ),
      ),
      child: Text(
        _error!,
        style: const TextStyle(
          color: Color(0xFFFECACA),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.display,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF334155),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: <DataColumn>[
            const DataColumn(
              label: Text('x'),
            ),
            ...widget.functions.map(
              (GraphFunctionDefinition function) =>
                  DataColumn(
                label: Text(
                  function.name,
                ),
              ),
            ),
          ],
          rows: _rows
              .map(
                (_GraphTableRow row) =>
                    DataRow(
                  cells: <DataCell>[
                    DataCell(
                      Text(_format(row.x)),
                    ),
                    ...row.values.map(
                      (double? value) =>
                          DataCell(
                        Text(
                          value == null
                              ? '—'
                              : _format(value),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _GraphTableRow {
  const _GraphTableRow({
    required this.x,
    required this.values,
  });

  final double x;
  final List<double?> values;
}
