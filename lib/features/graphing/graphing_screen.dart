import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'graph_function_table_screen.dart';
import 'graphing_engine.dart';

class GraphingScreen extends StatefulWidget {
  const GraphingScreen({
    super.key,
    this.initialExpressions = const <String>[],
    this.initialDegrees = true,
  });

  final List<String> initialExpressions;
  final bool initialDegrees;

  @override
  State<GraphingScreen> createState() =>
      _GraphingScreenState();
}

class _GraphingScreenState
    extends State<GraphingScreen> {
  final GraphingEngine _engine =
      const GraphingEngine();

  late final List<_FunctionEditor> _functions;

  bool _degrees = true;
  bool _showKeyPoints = true;

  double _xMin = -10;
  double _xMax = 10;
  double _yMin = -10;
  double _yMax = 10;

  double _startXMin = -10;
  double _startXMax = 10;
  double _startYMin = -10;
  double _startYMax = 10;
  Offset _startFocal = Offset.zero;

  String? _error;

  static const List<Color> _palette =
      <Color>[
    Color(0xFF38BDF8),
    Color(0xFFF59E0B),
    Color(0xFFA78BFA),
    Color(0xFF34D399),
  ];

  @override
  void initState() {
    super.initState();

    _degrees = widget.initialDegrees;

    final List<String> initial =
        widget.initialExpressions
            .where(
              (String value) =>
                  value.trim().isNotEmpty,
            )
            .take(4)
            .toList();

    _functions = List<_FunctionEditor>.generate(
      math.max(2, initial.length),
      (int index) => _FunctionEditor(
        expression: index < initial.length
            ? initial[index]
            : index == 0
                ? 'x^2 - 4'
                : index == 1
                    ? '2x + 1'
                    : '',
        enabled: index < 2 ||
            index < initial.length,
        color: _palette[
            index % _palette.length],
      ),
    );

    _recalculate();
  }

  @override
  void dispose() {
    for (final _FunctionEditor function
        in _functions) {
      function.dispose();
    }

    super.dispose();
  }

  List<_GraphSeries> get _series {
    final List<_GraphSeries> result =
        <_GraphSeries>[];

    for (int i = 0; i < _functions.length; i++) {
      final _FunctionEditor function =
          _functions[i];

      if (!function.enabled ||
          function.controller.text.trim().isEmpty) {
        continue;
      }

      try {
        final GraphAnalysis analysis =
            _engine.analyze(
          expression:
              function.controller.text.trim(),
          xMin: _xMin,
          xMax: _xMax,
          degrees: _degrees,
          samples: 700,
        );

        result.add(
          _GraphSeries(
            name: 'f${i + 1}(x)',
            expression:
                function.controller.text.trim(),
            color: function.color,
            analysis: analysis,
          ),
        );
      } catch (_) {
        // Invalid functions are surfaced in _recalculate().
      }
    }

    return result;
  }

  void _recalculate() {
    String? error;

    for (int i = 0; i < _functions.length; i++) {
      final _FunctionEditor function =
          _functions[i];

      if (!function.enabled ||
          function.controller.text.trim().isEmpty) {
        continue;
      }

      try {
        _engine.analyze(
          expression:
              function.controller.text.trim(),
          xMin: _xMin,
          xMax: _xMax,
          degrees: _degrees,
          samples: 160,
        );
      } catch (exception) {
        error =
            'f${i + 1}(x): ${exception.toString().replaceFirst('FormatException: ', '')}';
        break;
      }
    }

    setState(() {
      _error = error;
    });
  }

  void _addFunction() {
    if (_functions.length >= 4) {
      setState(() {
        _error =
            'A maximum of four functions can be graphed at once.';
      });
      return;
    }

    setState(() {
      _functions.add(
        _FunctionEditor(
          expression: '',
          enabled: true,
          color: _palette[
              _functions.length %
                  _palette.length],
        ),
      );
      _error = null;
    });
  }

  void _removeFunction(int index) {
    if (_functions.length <= 1) return;

    setState(() {
      _functions[index].dispose();
      _functions.removeAt(index);
      _error = null;
    });

    _recalculate();
  }

  void _resetView() {
    setState(() {
      _xMin = -10;
      _xMax = 10;
      _yMin = -10;
      _yMax = 10;
    });
  }

  void _startGesture(
    ScaleStartDetails details,
  ) {
    _startXMin = _xMin;
    _startXMax = _xMax;
    _startYMin = _yMin;
    _startYMax = _yMax;
    _startFocal = details.localFocalPoint;
  }

  void _updateGesture(
    ScaleUpdateDetails details,
    Size size,
  ) {
    if (size.width <= 0 ||
        size.height <= 0) {
      return;
    }

    final double startXRange =
        _startXMax - _startXMin;
    final double startYRange =
        _startYMax - _startYMin;

    final double scale =
        details.scale.clamp(0.15, 8.0);

    final double newXRange =
        startXRange / scale;
    final double newYRange =
        startYRange / scale;

    final double anchorX =
        _startXMin +
        (_startFocal.dx / size.width) *
            startXRange;

    final double anchorY =
        _startYMax -
        (_startFocal.dy / size.height) *
            startYRange;

    final Offset current =
        details.localFocalPoint;

    final double newXMin =
        anchorX -
        (current.dx / size.width) *
            newXRange;

    final double newYMax =
        anchorY +
        (current.dy / size.height) *
            newYRange;

    setState(() {
      _xMin = newXMin;
      _xMax = newXMin + newXRange;
      _yMax = newYMax;
      _yMin = newYMax - newYRange;
    });
  }

  void _zoomAtPointer(
    PointerScrollEvent event,
    Size size,
  ) {
    if (size.width <= 0 ||
        size.height <= 0) {
      return;
    }

    final double factor =
        event.scrollDelta.dy > 0
            ? 1.18
            : 1 / 1.18;

    final double xRange =
        _xMax - _xMin;
    final double yRange =
        _yMax - _yMin;

    final double anchorX =
        _xMin +
        (event.localPosition.dx /
                size.width) *
            xRange;

    final double anchorY =
        _yMax -
        (event.localPosition.dy /
                size.height) *
            yRange;

    final double newXRange =
        (xRange * factor)
            .clamp(0.02, 1e6);
    final double newYRange =
        (yRange * factor)
            .clamp(0.02, 1e6);

    final double xRatio =
        event.localPosition.dx /
            size.width;
    final double yRatio =
        event.localPosition.dy /
            size.height;

    setState(() {
      _xMin =
          anchorX - (xRatio * newXRange);
      _xMax = _xMin + newXRange;

      _yMax =
          anchorY + (yRatio * newYRange);
      _yMin = _yMax - newYRange;
    });
  }

  Future<void> _openTable() async {
    final List<GraphFunctionDefinition>
        functions =
        <GraphFunctionDefinition>[];

    for (int i = 0; i < _functions.length; i++) {
      final _FunctionEditor function =
          _functions[i];

      if (!function.enabled ||
          function.controller.text
              .trim()
              .isEmpty) {
        continue;
      }

      functions.add(
        GraphFunctionDefinition(
          name: 'f${i + 1}(x)',
          expression:
              function.controller.text.trim(),
        ),
      );
    }

    if (functions.isEmpty) {
      setState(() {
        _error =
            'Enable at least one valid function before opening the table.';
      });
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            GraphFunctionTableScreen(
          functions: functions,
          degrees: _degrees,
          initialStart: _xMin,
          initialEnd: _xMax,
        ),
      ),
    );
  }

  void _loadExample() {
    setState(() {
      for (final _FunctionEditor function
          in _functions) {
        function.enabled = false;
        function.controller.clear();
      }

      while (_functions.length < 3) {
        _functions.add(
          _FunctionEditor(
            expression: '',
            enabled: false,
            color: _palette[
                _functions.length %
                    _palette.length],
          ),
        );
      }

      _functions[0]
        ..enabled = true
        ..controller.text = 'x^2 - 4';

      _functions[1]
        ..enabled = true
        ..controller.text = '2x + 1';

      _functions[2]
        ..enabled = true
        ..controller.text = 'sin(x)';

      _degrees = true;
      _xMin = -6;
      _xMax = 6;
      _yMin = -8;
      _yMax = 8;
      _error = null;
    });
  }

  String _format(double value) {
    if (value.abs() < 1e-9) {
      return '0';
    }

    final double rounded =
        value.roundToDouble();

    if ((value - rounded).abs() < 1e-7 &&
        value.abs() < 1e8) {
      return rounded.toInt().toString();
    }

    String text =
        value.toStringAsPrecision(6);

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
    final List<_GraphSeries> series =
        _series;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Graphing'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Function table',
            onPressed: _openTable,
            icon: const Icon(
              Icons.table_chart_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Reset view',
            onPressed: _resetView,
            icon: const Icon(
              Icons.center_focus_strong,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (
            BuildContext context,
            BoxConstraints constraints,
          ) {
            final bool wide =
                constraints.maxWidth >= 900;

            final Widget controls =
                _buildControls(series);

            final Widget graph =
                _buildGraph(series);

            if (wide) {
              return Row(
                children: <Widget>[
                  SizedBox(
                    width: 370,
                    child:
                        SingleChildScrollView(
                      padding:
                          const EdgeInsets.all(
                        12,
                      ),
                      child: controls,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(
                        0,
                        12,
                        12,
                        12,
                      ),
                      child: graph,
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding:
                  const EdgeInsets.all(12),
              children: <Widget>[
                controls,
                const SizedBox(height: 12),
                SizedBox(
                  height: 560,
                  child: graph,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildControls(
    List<_GraphSeries> series,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.display,
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color:
                  const Color(0xFF334155),
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
                      'Functions',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addFunction,
                    icon:
                        const Icon(Icons.add),
                    label:
                        const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...List<Widget>.generate(
                _functions.length,
                (int index) =>
                    _functionEditor(
                  index,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.display,
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color:
                  const Color(0xFF334155),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: <Widget>[
              SegmentedButton<bool>(
                segments:
                    const <
                        ButtonSegment<bool>>[
                  ButtonSegment<bool>(
                    value: true,
                    label: Text('DEG'),
                  ),
                  ButtonSegment<bool>(
                    value: false,
                    label: Text('RAD'),
                  ),
                ],
                selected:
                    <bool>{_degrees},
                onSelectionChanged:
                    (
                      Set<bool> selection,
                    ) {
                  setState(() {
                    _degrees =
                        selection.first;
                  });
                  _recalculate();
                },
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding:
                    EdgeInsets.zero,
                title: const Text(
                  'Show intercepts, roots & turning points',
                ),
                value: _showKeyPoints,
                onChanged: (bool value) {
                  setState(() {
                    _showKeyPoints = value;
                  });
                },
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: _loadExample,
                    icon: const Icon(
                      Icons.science_outlined,
                    ),
                    label: const Text(
                      'Load example',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _openTable,
                    icon: const Icon(
                      Icons.table_chart_outlined,
                    ),
                    label:
                        const Text('Table'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _resetView,
                    icon: const Icon(
                      Icons.center_focus_strong,
                    ),
                    label: const Text(
                      'Reset view',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_error != null) ...<Widget>[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF7F1D1D)
                  .withOpacity(0.22),
              borderRadius:
                  BorderRadius.circular(12),
              border: Border.all(
                color:
                    const Color(0xFFB91C1C),
              ),
            ),
            child: Text(
              _error!,
              style: const TextStyle(
                color:
                    Color(0xFFFECACA),
              ),
            ),
          ),
        ],
        if (_showKeyPoints &&
            series.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          _buildAnalysisSummary(series),
        ],
      ],
    );
  }

  Widget _functionEditor(int index) {
    final _FunctionEditor function =
        _functions[index];

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: <Widget>[
          Checkbox(
            value: function.enabled,
            activeColor: function.color,
            onChanged: (bool? value) {
              setState(() {
                function.enabled =
                    value ?? false;
              });
              _recalculate();
            },
          ),
          Container(
            width: 10,
            height: 34,
            decoration: BoxDecoration(
              color: function.color,
              borderRadius:
                  BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller:
                  function.controller,
              onChanged: (_) =>
                  _recalculate(),
              decoration: InputDecoration(
                labelText:
                    'f${index + 1}(x)',
                hintText: 'x^2 - 4',
                border:
                    const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          if (_functions.length > 1)
            IconButton(
              tooltip: 'Remove function',
              onPressed: () =>
                  _removeFunction(index),
              icon: const Icon(
                Icons.close,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSummary(
    List<_GraphSeries> series,
  ) {
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
          const Text(
            'Key points in current x-range',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ...series.map(
            (_GraphSeries item) {
              final List<GraphKeyPoint> points =
                  item.analysis.keyPoints;

              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 10,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: 10,
                          height: 10,
                          decoration:
                              BoxDecoration(
                            color: item.color,
                            shape:
                                BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            '${item.name} = ${item.expression}',
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    if (points.isEmpty)
                      const Text(
                        'No roots/intercepts/turning points detected.',
                        style: TextStyle(
                          color: AppTheme
                              .mutedText,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: points
                            .map(
                              (GraphKeyPoint point) =>
                                  Chip(
                                label: Text(
                                  '${point.label}: '
                                  '(${_format(point.point.x)}, '
                                  '${_format(point.point.y)})',
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGraph(
    List<_GraphSeries> series,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080D17),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF334155),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (
          BuildContext context,
          BoxConstraints constraints,
        ) {
          final Size size = Size(
            constraints.maxWidth,
            constraints.maxHeight,
          );

          return Listener(
            onPointerSignal:
                (PointerSignalEvent event) {
              if (event
                  is PointerScrollEvent) {
                _zoomAtPointer(
                  event,
                  size,
                );
              }
            },
            child: GestureDetector(
              behavior:
                  HitTestBehavior.opaque,
              onScaleStart: _startGesture,
              onScaleUpdate:
                  (
                    ScaleUpdateDetails
                        details,
                  ) =>
                      _updateGesture(
                details,
                size,
              ),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GraphPainter(
                        series: series,
                        xMin: _xMin,
                        xMax: _xMax,
                        yMin: _yMin,
                        yMax: _yMax,
                        showKeyPoints:
                            _showKeyPoints,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration:
                          BoxDecoration(
                        color: AppTheme
                            .display
                            .withOpacity(
                          0.88,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(10),
                      ),
                      child: Text(
                        'x: ${_format(_xMin)} → ${_format(_xMax)}\n'
                        'y: ${_format(_yMin)} → ${_format(_yMax)}',
                        style:
                            const TextStyle(
                          fontSize: 11,
                          color: AppTheme
                              .secondaryText,
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    right: 12,
                    bottom: 10,
                    child: Text(
                      'Drag to pan • pinch / mouse wheel to zoom',
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            AppTheme.mutedText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FunctionEditor {
  _FunctionEditor({
    required String expression,
    required this.enabled,
    required this.color,
  }) : controller =
            TextEditingController(
          text: expression,
        );

  final TextEditingController controller;
  bool enabled;
  final Color color;

  void dispose() {
    controller.dispose();
  }
}

class _GraphSeries {
  const _GraphSeries({
    required this.name,
    required this.expression,
    required this.color,
    required this.analysis,
  });

  final String name;
  final String expression;
  final Color color;
  final GraphAnalysis analysis;
}

class _GraphPainter extends CustomPainter {
  const _GraphPainter({
    required this.series,
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
    required this.showKeyPoints,
  });

  final List<_GraphSeries> series;
  final double xMin;
  final double xMax;
  final double yMin;
  final double yMax;
  final bool showKeyPoints;

  Offset _toCanvas(
    GraphPoint point,
    Size size,
  ) {
    final double x =
        (point.x - xMin) /
        (xMax - xMin) *
        size.width;

    final double y =
        (yMax - point.y) /
        (yMax - yMin) *
        size.height;

    return Offset(x, y);
  }

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    if (size.width <= 0 ||
        size.height <= 0) {
      return;
    }

    _drawGrid(canvas, size);
    _drawAxes(canvas, size);

    for (final _GraphSeries item in series) {
      _drawFunction(
        canvas,
        size,
        item,
      );

      if (showKeyPoints) {
        _drawKeyPoints(
          canvas,
          size,
          item,
        );
      }
    }
  }

  void _drawGrid(
    Canvas canvas,
    Size size,
  ) {
    final Paint minor = Paint()
      ..color =
          const Color(0xFF172033)
      ..strokeWidth = 1;

    final double xStep =
        _niceStep(
      (xMax - xMin) / 10,
    );
    final double yStep =
        _niceStep(
      (yMax - yMin) / 10,
    );

    final double firstX =
        (xMin / xStep).ceil() * xStep;

    for (double x = firstX;
        x <= xMax + 1e-12;
        x += xStep) {
      final Offset start =
          _toCanvas(
        GraphPoint(x, yMin),
        size,
      );

      final Offset end =
          _toCanvas(
        GraphPoint(x, yMax),
        size,
      );

      canvas.drawLine(
        start,
        end,
        minor,
      );
    }

    final double firstY =
        (yMin / yStep).ceil() * yStep;

    for (double y = firstY;
        y <= yMax + 1e-12;
        y += yStep) {
      final Offset start =
          _toCanvas(
        GraphPoint(xMin, y),
        size,
      );

      final Offset end =
          _toCanvas(
        GraphPoint(xMax, y),
        size,
      );

      canvas.drawLine(
        start,
        end,
        minor,
      );
    }
  }

  void _drawAxes(
    Canvas canvas,
    Size size,
  ) {
    final Paint axis = Paint()
      ..color =
          const Color(0xFF94A3B8)
      ..strokeWidth = 1.4;

    if (xMin <= 0 && xMax >= 0) {
      canvas.drawLine(
        _toCanvas(
          GraphPoint(0, yMin),
          size,
        ),
        _toCanvas(
          GraphPoint(0, yMax),
          size,
        ),
        axis,
      );
    }

    if (yMin <= 0 && yMax >= 0) {
      canvas.drawLine(
        _toCanvas(
          GraphPoint(xMin, 0),
          size,
        ),
        _toCanvas(
          GraphPoint(xMax, 0),
          size,
        ),
        axis,
      );
    }
  }

  void _drawFunction(
    Canvas canvas,
    Size size,
    _GraphSeries item,
  ) {
    final Paint paint = Paint()
      ..color = item.color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path path = Path();
    bool started = false;
    Offset? previous;

    for (final GraphPoint? point
        in item.analysis.points) {
      if (point == null) {
        started = false;
        previous = null;
        continue;
      }

      final Offset canvasPoint =
          _toCanvas(
        point,
        size,
      );

      final bool wildlyOffscreen =
          canvasPoint.dy < -size.height * 8 ||
          canvasPoint.dy > size.height * 9;

      if (wildlyOffscreen) {
        started = false;
        previous = null;
        continue;
      }

      if (!started) {
        path.moveTo(
          canvasPoint.dx,
          canvasPoint.dy,
        );
        started = true;
      } else {
        if (previous != null &&
            (canvasPoint.dy -
                        previous.dy)
                    .abs() >
                size.height * 2) {
          path.moveTo(
            canvasPoint.dx,
            canvasPoint.dy,
          );
        } else {
          path.lineTo(
            canvasPoint.dx,
            canvasPoint.dy,
          );
        }
      }

      previous = canvasPoint;
    }

    canvas.drawPath(path, paint);
  }

  void _drawKeyPoints(
    Canvas canvas,
    Size size,
    _GraphSeries item,
  ) {
    final Paint fill = Paint()
      ..color = item.color
      ..style = PaintingStyle.fill;

    final Paint ring = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final GraphKeyPoint point
        in item.analysis.keyPoints) {
      if (point.point.x < xMin ||
          point.point.x > xMax ||
          point.point.y < yMin ||
          point.point.y > yMax) {
        continue;
      }

      final Offset canvasPoint =
          _toCanvas(
        point.point,
        size,
      );

      canvas.drawCircle(
        canvasPoint,
        5,
        fill,
      );
      canvas.drawCircle(
        canvasPoint,
        5,
        ring,
      );
    }
  }

  double _niceStep(double raw) {
    if (raw <= 0 || !raw.isFinite) {
      return 1;
    }

    final double exponent =
        math.pow(
          10,
          (math.log(raw) / math.ln10)
              .floor(),
        ).toDouble();

    final double fraction =
        raw / exponent;

    final double niceFraction;

    if (fraction < 1.5) {
      niceFraction = 1;
    } else if (fraction < 3) {
      niceFraction = 2;
    } else if (fraction < 7) {
      niceFraction = 5;
    } else {
      niceFraction = 10;
    }

    return niceFraction * exponent;
  }

  @override
  bool shouldRepaint(
    covariant _GraphPainter oldDelegate,
  ) {
    return oldDelegate.series != series ||
        oldDelegate.xMin != xMin ||
        oldDelegate.xMax != xMax ||
        oldDelegate.yMin != yMin ||
        oldDelegate.yMax != yMax ||
        oldDelegate.showKeyPoints !=
            showKeyPoints;
  }
}
