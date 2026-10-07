import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/math_scanner_service.dart';
import 'camera_math_cleaner.dart';
import 'camera_math_solver.dart';

class CameraSolverScreen extends StatefulWidget {
  const CameraSolverScreen({super.key});

  @override
  State<CameraSolverScreen> createState() =>
      _CameraSolverScreenState();
}

class _CameraSolverScreenState
    extends State<CameraSolverScreen> {
  final MathScannerService _scanner =
      const MathScannerService();

  final CameraMathCleaner _cleaner =
      const CameraMathCleaner();

  final CameraMathSolver _solver =
      const CameraMathSolver();

  final TextEditingController _rawController =
      TextEditingController();

  bool _degrees = true;
  bool _working = false;

  String _cleaned = '';
  CameraMathSolution? _solution;
  String? _message;

  @override
  void dispose() {
    _rawController.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    await _scan(fromGallery: false);
  }

  Future<void> _gallery() async {
    await _scan(fromGallery: true);
  }

  Future<void> _scan({
    required bool fromGallery,
  }) async {
    if (!_scanner.isAvailable) {
      setState(() {
        _message =
            'Camera OCR runs in the Android/iOS build. '
            'In Chrome, type or paste a math problem below to test cleanup and solving.';
      });
      return;
    }

    setState(() {
      _working = true;
      _message = null;
    });

    try {
      final String? text = fromGallery
          ? await _scanner.scanRawTextFromGallery()
          : await _scanner.scanRawTextFromCamera();

      if (!mounted || text == null) {
        return;
      }

      _rawController.text = text;

      _solve();
    } on UnsupportedError catch (error) {
      if (!mounted) return;

      setState(() {
        _message = error.message?.toString();
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _message =
            'OCR failed. Try a clearer image with good lighting and the equation centered.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
        });
      }
    }
  }

  void _solve() {
    final String raw =
        _rawController.text;

    final String cleaned =
        _cleaner.clean(raw);

    final CameraMathSolution solution =
        _solver.solve(
      raw,
      degrees: _degrees,
    );

    setState(() {
      _cleaned = cleaned;
      _solution = solution;
      _message = null;
    });
  }

  void _loadExample() {
    _rawController.text =
        'x² - 5x + 6 = 0';

    _solve();
  }

  void _clear() {
    setState(() {
      _rawController.clear();
      _cleaned = '';
      _solution = null;
      _message = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Solver'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 860,
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
                _buildCaptureCard(),
                const SizedBox(height: 14),
                _buildInputCard(),
                if (_message != null) ...<
                    Widget>[
                  const SizedBox(height: 12),
                  _buildMessage(),
                ],
                if (_solution != null) ...<
                    Widget>[
                  const SizedBox(height: 16),
                  _buildSolutionCard(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureCard() {
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
          const Text(
            'Scan a math problem',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Capture a clear printed expression or equation. '
            'OCR is performed locally with ML Kit, then the recognized text is cleaned and solved.',
            style: TextStyle(
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              FilledButton.icon(
                onPressed:
                    _working ? null : _capture,
                icon: const Icon(
                  Icons.camera_alt_outlined,
                ),
                label: const Text(
                  'Capture photo',
                ),
              ),
              OutlinedButton.icon(
                onPressed:
                    _working ? null : _gallery,
                icon: const Icon(
                  Icons.photo_library_outlined,
                ),
                label: const Text(
                  'Choose image',
                ),
              ),
              if (_working)
                const Padding(
                  padding:
                      EdgeInsets.all(8),
                  child:
                      CircularProgressIndicator(),
                ),
            ],
          ),
          if (!_scanner.isAvailable) ...<
              Widget>[
            const SizedBox(height: 12),
            const Text(
              'Chrome test mode: device OCR is unavailable here, '
              'but the recognition cleanup and solver can be tested by typing below.',
              style: TextStyle(
                color: AppTheme.mutedText,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputCard() {
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
          TextField(
            controller: _rawController,
            minLines: 2,
            maxLines: 6,
            decoration:
                const InputDecoration(
              labelText:
                  'Recognized / manual math text',
              hintText:
                  'Example: 2x + 3 = 11',
              border:
                  OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<bool>(
            segments:
                const <ButtonSegment<bool>>[
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
                _degrees =
                    selection.first;
              });
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              FilledButton.icon(
                onPressed: _solve,
                icon: const Icon(
                  Icons.auto_fix_high,
                ),
                label:
                    const Text('Clean & solve'),
                style:
                    FilledButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xFFF6B45F,
                  ),
                  foregroundColor:
                      const Color(
                    0xFF2B1A04,
                  ),
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
                icon:
                    const Icon(Icons.refresh),
                label: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessage() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.numberKey,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF475569),
        ),
      ),
      child: Text(
        _message!,
        style: const TextStyle(
          color: AppTheme.secondaryText,
        ),
      ),
    );
  }

  Widget _buildSolutionCard() {
    final CameraMathSolution solution =
        _solution!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.display,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: solution.isSolved
              ? AppTheme.equals
                  .withValues(alpha: 0.45)
              : const Color(0xFFB91C1C),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Recognized math',
            style: TextStyle(
              color: AppTheme.mutedText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          SelectableText(
            _cleaned,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Divider(height: 26),
          const Text(
            'Answer',
            style: TextStyle(
              color: AppTheme.mutedText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          SelectableText(
            solution.answer,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Step-by-step',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ...List<Widget>.generate(
            solution.steps.length,
            (int index) => Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 9,
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 26,
                    height: 26,
                    alignment:
                        Alignment.center,
                    decoration:
                        BoxDecoration(
                      color: AppTheme.equals
                          .withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w800,
                        color:
                            Color(0xFFFBBF24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child:
                        SelectableText(
                      solution.steps[index],
                      style:
                          const TextStyle(
                        color: AppTheme
                            .secondaryText,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Current local recognition is optimized for printed numeric expressions and one-variable linear/quadratic equations. '
            'More advanced handwriting and symbolic recognition can be added later.',
            style: TextStyle(
              color: AppTheme.mutedText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
