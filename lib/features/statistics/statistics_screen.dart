import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'statistics_engine.dart';

enum StatisticsKind {
  oneVariable(
    '1-Variable',
    'x values with optional frequencies',
  ),
  twoVariable(
    '2-Variable',
    'x/y pairs, correlation and regression',
  );

  const StatisticsKind(
    this.label,
    this.description,
  );

  final String label;
  final String description;
}

class StatisticsModeScreen extends StatefulWidget {
  const StatisticsModeScreen({super.key});

  @override
  State<StatisticsModeScreen> createState() =>
      _StatisticsModeScreenState();
}

class _StatisticsModeScreenState
    extends State<StatisticsModeScreen> {
  final StatisticsEngine _engine =
      const StatisticsEngine();

  StatisticsKind _kind =
      StatisticsKind.oneVariable;

  final List<_StatisticsRowControllers> _rows =
      <_StatisticsRowControllers>[];

  OneVariableStatistics? _oneVariableResult;
  TwoVariableStatistics? _twoVariableResult;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _resetRows();
  }

  @override
  void dispose() {
    _disposeRows();
    super.dispose();
  }

  void _disposeRows() {
    for (final _StatisticsRowControllers row
        in _rows) {
      row.dispose();
    }
    _rows.clear();
  }

  void _resetRows() {
    _disposeRows();

    for (int i = 0; i < 5; i++) {
      _rows.add(_StatisticsRowControllers());
    }

    _oneVariableResult = null;
    _twoVariableResult = null;
    _validationMessage = null;
  }

  void _changeKind(StatisticsKind? kind) {
    if (kind == null || kind == _kind) return;

    setState(() {
      _kind = kind;
      _resetRows();
    });
  }

  void _addRow() {
    setState(() {
      if (_rows.length >= 100) {
        _validationMessage =
            'A maximum of 100 input rows is supported.';
        return;
      }

      _rows.add(_StatisticsRowControllers());
      _validationMessage = null;
    });
  }

  void _removeRow(int index) {
    if (_rows.length == 1) {
      _rows[index].clear();
      return;
    }

    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
      _oneVariableResult = null;
      _twoVariableResult = null;
      _validationMessage = null;
    });
  }

  void _clear() {
    setState(_resetRows);
  }

  void _loadExample() {
    setState(() {
      _resetRows();

      if (_kind == StatisticsKind.oneVariable) {
        const List<List<String>> values =
            <List<String>>[
          <String>['1', '', '1'],
          <String>['2', '', '2'],
          <String>['3', '', '1'],
        ];

        for (int i = 0; i < values.length; i++) {
          _rows[i].x.text = values[i][0];
          _rows[i].frequency.text =
              values[i][2];
        }
      } else {
        const List<List<String>> values =
            <List<String>>[
          <String>['1', '2', '1'],
          <String>['2', '4', '1'],
          <String>['3', '6', '1'],
          <String>['4', '8', '1'],
        ];

        for (int i = 0; i < values.length; i++) {
          _rows[i].x.text = values[i][0];
          _rows[i].y.text = values[i][1];
          _rows[i].frequency.text =
              values[i][2];
        }
      }
    });
  }

  void _calculate() {
    FocusScope.of(context).unfocus();

    try {
      if (_kind == StatisticsKind.oneVariable) {
        final List<FrequencyValue> entries =
            <FrequencyValue>[];

        for (int i = 0; i < _rows.length; i++) {
          final _StatisticsRowControllers row =
              _rows[i];

          final String rawX = row.x.text.trim();
          final String rawFrequency =
              row.frequency.text.trim();

          final bool rowIsBlank =
              rawX.isEmpty &&
              rawFrequency.isEmpty;

          if (rowIsBlank) continue;

          if (rawX.isEmpty) {
            throw FormatException(
              'Row ${i + 1}: enter an x value.',
            );
          }

          entries.add(
            FrequencyValue(
              value: _parseNumber(
                rawX,
                label: 'Row ${i + 1} x',
              ),
              frequency: _parseFrequency(
                rawFrequency,
                rowNumber: i + 1,
              ),
            ),
          );
        }

        final OneVariableStatistics result =
            _engine.oneVariable(entries);

        setState(() {
          _oneVariableResult = result;
          _twoVariableResult = null;
          _validationMessage = null;
        });
      } else {
        final List<FrequencyPair> entries =
            <FrequencyPair>[];

        for (int i = 0; i < _rows.length; i++) {
          final _StatisticsRowControllers row =
              _rows[i];

          final String rawX = row.x.text.trim();
          final String rawY = row.y.text.trim();
          final String rawFrequency =
              row.frequency.text.trim();

          final bool rowIsBlank =
              rawX.isEmpty &&
              rawY.isEmpty &&
              rawFrequency.isEmpty;

          if (rowIsBlank) continue;

          if (rawX.isEmpty || rawY.isEmpty) {
            throw FormatException(
              'Row ${i + 1}: enter both x and y.',
            );
          }

          entries.add(
            FrequencyPair(
              x: _parseNumber(
                rawX,
                label: 'Row ${i + 1} x',
              ),
              y: _parseNumber(
                rawY,
                label: 'Row ${i + 1} y',
              ),
              frequency: _parseFrequency(
                rawFrequency,
                rowNumber: i + 1,
              ),
            ),
          );
        }

        final TwoVariableStatistics result =
            _engine.twoVariable(entries);

        setState(() {
          _twoVariableResult = result;
          _oneVariableResult = null;
          _validationMessage = null;
        });
      }
    } on FormatException catch (error) {
      setState(() {
        _oneVariableResult = null;
        _twoVariableResult = null;
        _validationMessage =
            error.message.toString();
      });
    }
  }

  double _parseNumber(
    String raw, {
    required String label,
  }) {
    final String text = raw.trim();

    final double? direct =
        double.tryParse(text);

    if (direct != null) {
      return direct;
    }

    if (text.contains('/')) {
      final List<String> parts =
          text.split('/');

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
      '$label: “$raw” is not a valid number. '
      'You can enter decimals or a fraction such as 1/2.',
    );
  }

  int _parseFrequency(
    String raw, {
    required int rowNumber,
  }) {
    if (raw.trim().isEmpty) {
      return 1;
    }

    final int? frequency =
        int.tryParse(raw.trim());

    if (frequency == null ||
        frequency <= 0) {
      throw FormatException(
        'Row $rowNumber: frequency must be '
        'a positive whole number.',
      );
    }

    return frequency;
  }

  String _format(double value) {
    if (value == 0) return '0';

    final double rounded =
        value.roundToDouble();

    if ((value - rounded).abs() < 1e-12 &&
        value.abs() < 1e15) {
      return rounded.toInt().toString();
    }

    final double absolute = value.abs();

    if (absolute >= 1e10 ||
        absolute < 1e-8) {
      return value
          .toStringAsExponential(8)
          .replaceFirst(
            RegExp(r'\.?0+e'),
            'e',
          );
    }

    String text =
        value.toStringAsPrecision(10);

    if (!text.contains('e') &&
        !text.contains('E')) {
      text = text.replaceFirst(
        RegExp(r'\.?0+$'),
        '',
      );
    }

    return text;
  }

  String _formatNullable(double? value) {
    return value == null
        ? 'Undefined'
        : _format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('STAT Mode'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 920,
            ),
            child: ListView(
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                28,
              ),
              children: <Widget>[
                _buildTypeCard(),
                const SizedBox(height: 16),
                _buildDataEntryCard(),
                const SizedBox(height: 14),
                _buildActions(),
                if (_validationMessage != null) ...<
                    Widget>[
                  const SizedBox(height: 14),
                  _buildValidationMessage(),
                ],
                if (_oneVariableResult != null) ...<
                    Widget>[
                  const SizedBox(height: 18),
                  _buildOneVariableResults(
                    _oneVariableResult!,
                  ),
                ],
                if (_twoVariableResult != null) ...<
                    Widget>[
                  const SizedBox(height: 18),
                  _buildTwoVariableResults(
                    _twoVariableResult!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard() {
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
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: <Widget>[
          DropdownButtonFormField<
              StatisticsKind>(
            initialValue: _kind,
            decoration:
                const InputDecoration(
              labelText: 'Statistics type',
              border:
                  OutlineInputBorder(),
            ),
            items: StatisticsKind.values
                .map(
                  (StatisticsKind kind) =>
                      DropdownMenuItem<
                          StatisticsKind>(
                    value: kind,
                    child: Text(kind.label),
                  ),
                )
                .toList(),
            onChanged: _changeKind,
          ),
          const SizedBox(height: 12),
          Text(
            _kind.description,
            style: const TextStyle(
              color: AppTheme.mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _kind ==
                    StatisticsKind.oneVariable
                ? 'Enter x values and frequencies. '
                    'Leave frequency blank to use 1.'
                : 'Enter paired x/y values. '
                    'Frequency is optional and defaults to 1.',
            style: const TextStyle(
              color: AppTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataEntryCard() {
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
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Data table',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _addRow,
                icon: const Icon(
                  Icons.add,
                ),
                label:
                    const Text('Add row'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTableHeader(),
          const SizedBox(height: 6),
          ...List<Widget>.generate(
            _rows.length,
            (int index) =>
                _buildDataRow(index),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    final bool hasY =
        _kind ==
            StatisticsKind.twoVariable;

    return Row(
      children: <Widget>[
        const SizedBox(
          width: 30,
          child: Text(
            '#',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.mutedText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 6),
        const Expanded(
          child: Text(
            'x',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.mutedText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (hasY) ...<Widget>[
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'y',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.mutedText,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
        ],
        const SizedBox(width: 8),
        const SizedBox(
          width: 88,
          child: Text(
            'Freq',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.mutedText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 42),
      ],
    );
  }

  Widget _buildDataRow(int index) {
    final bool hasY =
        _kind ==
            StatisticsKind.twoVariable;
    final _StatisticsRowControllers row =
        _rows[index];

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 8,
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 30,
            child: Text(
              '${index + 1}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color:
                    AppTheme.mutedText,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _numberField(
              controller: row.x,
              hint: 'x',
            ),
          ),
          if (hasY) ...<Widget>[
            const SizedBox(width: 8),
            Expanded(
              child: _numberField(
                controller: row.y,
                hint: 'y',
              ),
            ),
          ],
          const SizedBox(width: 8),
          SizedBox(
            width: 88,
            child: TextField(
              controller:
                  row.frequency,
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                hintText: '1',
                isDense: true,
                border:
                    OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(
            width: 42,
            child: IconButton(
              tooltip: 'Remove row',
              onPressed: () =>
                  _removeRow(index),
              icon: const Icon(
                Icons.close,
                size: 19,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        border:
            const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildActions() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: <Widget>[
        FilledButton.icon(
          onPressed: _calculate,
          icon: const Icon(
            Icons.calculate_outlined,
          ),
          label: const Text('Calculate'),
          style: FilledButton.styleFrom(
            backgroundColor:
                const Color(0xFFF6B45F),
            foregroundColor:
                const Color(0xFF2B1A04),
          ),
        ),
        OutlinedButton.icon(
          onPressed: _loadExample,
          icon: const Icon(
            Icons.science_outlined,
          ),
          label:
              const Text('Load example'),
        ),
        OutlinedButton.icon(
          onPressed: _clear,
          icon: const Icon(
            Icons.refresh,
          ),
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
            .withValues(alpha: 0.22),
        borderRadius:
            BorderRadius.circular(14),
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

  Widget _buildOneVariableResults(
    OneVariableStatistics result,
  ) {
    final String modeText =
        result.modes.isEmpty
            ? 'No unique mode'
            : result.modes
                .map(_format)
                .join(', ');

    return _ResultsSection(
      title: '1-Variable results',
      children: <Widget>[
        _resultGrid(
          <_Metric>[
            _Metric(
              'n',
              '${result.count}',
            ),
            _Metric(
              'Σx',
              _format(result.sum),
            ),
            _Metric(
              'Σx²',
              _format(result.sumSquares),
            ),
            _Metric(
              'Mean x̄',
              _format(result.mean),
            ),
            _Metric(
              'Median',
              _format(result.median),
            ),
            _Metric(
              'Mode',
              modeText,
            ),
            _Metric(
              'Min',
              _format(result.minimum),
            ),
            _Metric(
              'Max',
              _format(result.maximum),
            ),
            _Metric(
              'Population variance σ²',
              _format(
                result.populationVariance,
              ),
            ),
            _Metric(
              'Sample variance s²',
              _formatNullable(
                result.sampleVariance,
              ),
            ),
            _Metric(
              'Population SD σ',
              _format(
                result.populationStdDev,
              ),
            ),
            _Metric(
              'Sample SD s',
              _formatNullable(
                result.sampleStdDev,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTwoVariableResults(
    TwoVariableStatistics result,
  ) {
    final String regressionText =
        result.regressionSlope == null ||
                result.regressionIntercept ==
                    null
            ? 'Undefined'
            : 'y = '
                '${_format(result.regressionIntercept!)} '
                '${result.regressionSlope! >= 0 ? '+' : '−'} '
                '${_format(result.regressionSlope!.abs())}x';

    return _ResultsSection(
      title: '2-Variable results',
      children: <Widget>[
        _resultGrid(
          <_Metric>[
            _Metric(
              'n',
              '${result.count}',
            ),
            _Metric(
              'Σx',
              _format(result.sumX),
            ),
            _Metric(
              'Σy',
              _format(result.sumY),
            ),
            _Metric(
              'Σx²',
              _format(result.sumX2),
            ),
            _Metric(
              'Σy²',
              _format(result.sumY2),
            ),
            _Metric(
              'Σxy',
              _format(result.sumXY),
            ),
            _Metric(
              'Mean x̄',
              _format(result.meanX),
            ),
            _Metric(
              'Mean ȳ',
              _format(result.meanY),
            ),
            _Metric(
              'Population SD x',
              _format(
                result.populationStdDevX,
              ),
            ),
            _Metric(
              'Population SD y',
              _format(
                result.populationStdDevY,
              ),
            ),
            _Metric(
              'Sample SD x',
              _formatNullable(
                result.sampleStdDevX,
              ),
            ),
            _Metric(
              'Sample SD y',
              _formatNullable(
                result.sampleStdDevY,
              ),
            ),
            _Metric(
              'Correlation r',
              _formatNullable(
                result.correlation,
              ),
            ),
            _Metric(
              'Regression slope b',
              _formatNullable(
                result.regressionSlope,
              ),
            ),
            _Metric(
              'Regression intercept a',
              _formatNullable(
                result.regressionIntercept,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.numberKey,
            borderRadius:
                BorderRadius.circular(14),
            border: Border.all(
              color:
                  const Color(0xFF334155),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Linear regression',
                style: TextStyle(
                  color:
                      AppTheme.mutedText,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                regressionText,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _resultGrid(
    List<_Metric> metrics,
  ) {
    return LayoutBuilder(
      builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        final int columns =
            constraints.maxWidth >= 720
                ? 3
                : constraints.maxWidth >= 480
                    ? 2
                    : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio:
                columns == 1 ? 4.4 : 2.5,
          ),
          itemBuilder: (
            BuildContext context,
            int index,
          ) {
            final _Metric metric =
                metrics[index];

            return Container(
              padding:
                  const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    AppTheme.numberKey,
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
                border: Border.all(
                  color: const Color(
                    0xFF334155,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    metric.label,
                    style:
                        const TextStyle(
                      color: AppTheme
                          .mutedText,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    metric.value,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StatisticsRowControllers {
  _StatisticsRowControllers()
      : x = TextEditingController(),
        y = TextEditingController(),
        frequency = TextEditingController();

  final TextEditingController x;
  final TextEditingController y;
  final TextEditingController frequency;

  void clear() {
    x.clear();
    y.clear();
    frequency.clear();
  }

  void dispose() {
    x.dispose();
    y.dispose();
    frequency.dispose();
  }
}

class _Metric {
  const _Metric(this.label, this.value);

  final String label;
  final String value;
}

class _ResultsSection extends StatelessWidget {
  const _ResultsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
