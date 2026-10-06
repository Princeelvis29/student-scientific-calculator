import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/interaction_feedback_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.onFinished,
  });

  final Future<void> Function() onFinished;

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {
  final PageController _controller =
      PageController();

  int _index = 0;
  bool _finishing = false;

  static const List<_OnboardingPageData>
      _pages = <_OnboardingPageData>[
    _OnboardingPageData(
      icon: Icons.calculate_outlined,
      eyebrow: 'ARKTECH SOLUTIONS',
      title:
          'A serious scientific calculator for students',
      body:
          'COMP, STAT, EQN, MATRIX, VECTOR, TABLE and CMPLX are built into one focused calculator.',
      accent: Color(0xFFF59E0B),
    ),
    _OnboardingPageData(
      icon: Icons.school_outlined,
      eyebrow: 'STUDY + EXAM',
      title:
          'Switch between learning and calculator-only modes',
      body:
          'Study Mode unlocks formulas, graphing, history and Camera Solver. Exam Mode keeps the interface focused on calculator functions.',
      accent: Color(0xFF38BDF8),
    ),
    _OnboardingPageData(
      icon: Icons.auto_awesome_outlined,
      eyebrow: 'SMART STUDY TOOLS',
      title:
          'Graph, scan and understand the problem',
      body:
          'Use function graphing, formula references and Android camera OCR with step-by-step local solving.',
      accent: Color(0xFFA78BFA),
    ),
    _OnboardingPageData(
      icon: Icons.accessibility_new,
      eyebrow: 'MADE FOR YOU',
      title:
          'Comfortable, responsive and accessible',
      body:
          'Choose light or dark appearance, text size, high contrast, haptic feedback and optional button sounds.',
      accent: Color(0xFF34D399),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_finishing) return;

    setState(() {
      _finishing = true;
    });

    await widget.onFinished();

    if (mounted) {
      setState(() {
        _finishing = false;
      });
    }
  }

  void _next() {
    InteractionFeedbackService.tap(
      context,
    );

    if (_index ==
        _pages.length - 1) {
      _finish();
      return;
    }

    _controller.nextPage(
      duration:
          const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme =
        Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                18,
                12,
                12,
                0,
              ),
              child: Row(
                children: <Widget>[
                  Image.asset(
                    'assets/branding/arktech_splash_logo.png',
                    width: 42,
                    height: 42,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Arktech Calculator',
                      maxLines: 2,
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed:
                        _finishing
                            ? null
                            : _finish,
                    child:
                        const Text('Skip'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged:
                    (int value) {
                  setState(() {
                    _index = value;
                  });
                },
                itemBuilder:
                    (
                      BuildContext context,
                      int index,
                    ) {
                  final _OnboardingPageData
                      page = _pages[index];

                  return LayoutBuilder(
                    builder: (
                      BuildContext context,
                      BoxConstraints constraints,
                    ) {
                      final bool compact =
                          constraints.maxHeight <
                              520;

                      return SingleChildScrollView(
                        padding:
                            EdgeInsets.fromLTRB(
                          24,
                          compact ? 18 : 44,
                          24,
                          18,
                        ),
                        child: Center(
                          child:
                              ConstrainedBox(
                            constraints:
                                const BoxConstraints(
                              maxWidth: 620,
                            ),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  width:
                                      compact
                                          ? 98
                                          : 132,
                                  height:
                                      compact
                                          ? 98
                                          : 132,
                                  decoration:
                                      BoxDecoration(
                                    gradient:
                                        LinearGradient(
                                      begin: Alignment
                                          .topLeft,
                                      end: Alignment
                                          .bottomRight,
                                      colors: <Color>[
                                        page.accent,
                                        page.accent
                                            .withOpacity(
                                          0.45,
                                        ),
                                      ],
                                    ),
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      34,
                                    ),
                                    boxShadow: <
                                        BoxShadow>[
                                      BoxShadow(
                                        color: page
                                            .accent
                                            .withOpacity(
                                          0.22,
                                        ),
                                        blurRadius:
                                            32,
                                        offset:
                                            const Offset(
                                          0,
                                          14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    page.icon,
                                    size:
                                        compact
                                            ? 48
                                            : 62,
                                    color:
                                        Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      compact
                                          ? 24
                                          : 38,
                                ),
                                Text(
                                  page.eyebrow,
                                  textAlign:
                                      TextAlign
                                          .center,
                                  style:
                                      TextStyle(
                                    color:
                                        page.accent,
                                    fontSize: 13,
                                    fontWeight:
                                        FontWeight
                                            .w900,
                                    letterSpacing:
                                        1.4,
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Text(
                                  page.title,
                                  textAlign:
                                      TextAlign
                                          .center,
                                  style: TextStyle(
                                    fontSize:
                                        compact
                                            ? 28
                                            : 34,
                                    height: 1.12,
                                    fontWeight:
                                        FontWeight
                                            .w900,
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  page.body,
                                  textAlign:
                                      TextAlign
                                          .center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: scheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                20,
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children:
                        List<Widget>.generate(
                      _pages.length,
                      (int index) {
                        final bool selected =
                            index == _index;

                        return AnimatedContainer(
                          duration:
                              const Duration(
                            milliseconds: 220,
                          ),
                          width:
                              selected ? 26 : 8,
                          height: 8,
                          margin:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 4,
                          ),
                          decoration:
                              BoxDecoration(
                            color: selected
                                ? _pages[index]
                                    .accent
                                : scheme
                                    .outlineVariant,
                            borderRadius:
                                BorderRadius
                                    .circular(8),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed:
                          _finishing
                              ? null
                              : _next,
                      style:
                          FilledButton.styleFrom(
                        minimumSize:
                            const Size.fromHeight(
                          54,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(16),
                        ),
                      ),
                      child: _finishing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _index ==
                                      _pages.length -
                                          1
                                  ? 'Get started'
                                  : 'Continue',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.accent,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String body;
  final Color accent;
}
