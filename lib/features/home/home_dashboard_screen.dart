import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/app_experience_mode.dart';
import '../../services/app_mode_repository.dart';
import '../calculator/calculator_screen.dart';
import '../camera_solver/camera_solver_screen.dart';
import '../equation/equation_screen.dart';
import '../formula_library/formula_library_screen.dart';
import '../graphing/graphing_screen.dart';
import '../history/calculation_history_repository.dart';
import '../history/calculation_history_screen.dart';
import '../settings/settings_screen.dart';
import '../contact/contact_developer_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() =>
      _HomeDashboardScreenState();
}

class _HomeDashboardScreenState
    extends State<HomeDashboardScreen> {
  final AppModeRepository _modeRepository =
      AppModeRepository();

  final CalculationHistoryRepository
      _historyRepository =
      CalculationHistoryRepository();

  AppExperienceMode _mode =
      AppExperienceMode.study;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMode();
  }

  Future<void> _loadMode() async {
    final AppExperienceMode mode =
        await _modeRepository.load();

    if (!mounted) return;

    setState(() {
      _mode = mode;
      _loading = false;
    });
  }

  Future<void> _setMode(
    AppExperienceMode mode,
  ) async {
    await _modeRepository.save(mode);

    if (!mounted) return;

    setState(() {
      _mode = mode;
    });
  }

  Future<void> _open(
    Widget screen,
  ) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            screen,
      ),
    );
  }

  void _lockedMessage(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$feature is a Study Mode tool. Switch to Study Mode to use it.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final bool study = _mode.isStudy;

    final List<_DashboardItem> items =
        <_DashboardItem>[
      _DashboardItem(
        title: 'Calculator',
        subtitle:
            'COMP, STAT, EQN, MATRIX, VECTOR, TABLE & CMPLX',
        icon: Icons.calculate_outlined,
        enabled: true,
        onTap: () => _open(
          CalculatorScreen(
            studyMode: study,
            showAppBar: true,
          ),
        ),
      ),
      _DashboardItem(
        title: 'Solver',
        subtitle:
            'Linear, simultaneous and polynomial equations',
        icon: Icons.functions,
        enabled: true,
        onTap: () => _open(
          const EquationModeScreen(),
        ),
      ),
      _DashboardItem(
        title: 'Graph',
        subtitle:
            'Multiple functions, roots, turning points and tables',
        icon: Icons.show_chart,
        enabled: study,
        onTap: study
            ? () => _open(
                  const GraphingScreen(),
                )
            : () =>
                _lockedMessage('Graphing'),
      ),
      _DashboardItem(
        title: 'Formulas',
        subtitle:
            'Mathematics, Physics and Chemistry library',
        icon: Icons.menu_book_outlined,
        enabled: study,
        onTap: study
            ? () => _open(
                  const FormulaLibraryScreen(),
                )
            : () =>
                _lockedMessage('Formula Library'),
      ),
      _DashboardItem(
        title: 'History',
        subtitle:
            'Recent and favourite calculations',
        icon: Icons.history,
        enabled: study,
        onTap: study
            ? () => _open(
                  CalculationHistoryScreen(
                    repository:
                        _historyRepository,
                  ),
                )
            : () =>
                _lockedMessage('History'),
      ),
      _DashboardItem(
        title: 'Camera',
        subtitle:
            'Capture, recognize, clean and solve math',
        icon:
            Icons.camera_alt_outlined,
        enabled: study,
        onTap: study
            ? () => _open(
                  const CameraSolverScreen(),
                )
            : () =>
                _lockedMessage('Camera Solver'),
      ),
      _DashboardItem(
        title: 'Settings',
        subtitle:
            'Study/Exam Mode and app preferences',
        icon: Icons.settings_outlined,
        enabled: true,
        onTap: () => _open(
          SettingsScreen(
            initialMode: _mode,
            onModeChanged:
                (AppExperienceMode mode) {
              setState(() {
                _mode = mode;
              });
            },
          ),
        ),
      ),
      _DashboardItem(
        title: 'Contact Developer',
        subtitle:
            'Arktech Solutions support, phone, WhatsApp and email',
        icon: Icons.support_agent_outlined,
        enabled: true,
        onTap: () => _open(
          const ContactDeveloperScreen(),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Arktech Student Scientific Calculator',
        ),
        backgroundColor:
            AppTheme.background,
        surfaceTintColor:
            AppTheme.background,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 1050,
                  ),
                  child:
                      SingleChildScrollView(
                    padding:
                        const EdgeInsets
                            .fromLTRB(
                      16,
                      14,
                      16,
                      30,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .stretch,
                      children: <Widget>[
                        _buildModeCard(),
                        const SizedBox(
                          height: 18,
                        ),
                        Text(
                          study
                              ? 'Study tools'
                              : 'Exam calculator',
                          style:
                              const TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          study
                              ? 'Calculator plus learning, reference and camera tools.'
                              : 'Study aids are locked. Core calculator and equation functions remain available.',
                          style:
                              const TextStyle(
                            color: AppTheme
                                .secondaryText,
                          ),
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        LayoutBuilder(
                          builder: (
                            BuildContext
                                context,
                            BoxConstraints
                                constraints,
                          ) {
                            final int columns =
                                constraints
                                            .maxWidth >=
                                        850
                                    ? 3
                                    : constraints
                                                .maxWidth >=
                                            560
                                        ? 2
                                        : 1;

                            return GridView
                                .builder(
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              itemCount:
                                  items.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    columns,
                                crossAxisSpacing:
                                    12,
                                mainAxisSpacing:
                                    12,
                                childAspectRatio:
                                    columns == 1
                                        ? 3.15
                                        : 1.8,
                              ),
                              itemBuilder:
                                  (
                                    BuildContext
                                        context,
                                    int index,
                                  ) {
                                return _DashboardCard(
                                  item:
                                      items[index],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildModeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.display,
        borderRadius:
            BorderRadius.circular(20),
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
              Icon(
                _mode.isStudy
                    ? Icons.school_outlined
                    : Icons.calculate_outlined,
                color: AppTheme.equals,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _mode.label,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            _mode.description,
            style: const TextStyle(
              color:
                  AppTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 14),
          SegmentedButton<AppExperienceMode>(
            segments: const <
                ButtonSegment<
                    AppExperienceMode>>[
              ButtonSegment<
                  AppExperienceMode>(
                value:
                    AppExperienceMode.study,
                icon:
                    Icon(Icons.school_outlined),
                label: Text('Study'),
              ),
              ButtonSegment<
                  AppExperienceMode>(
                value:
                    AppExperienceMode.exam,
                icon: Icon(
                  Icons.calculate_outlined,
                ),
                label: Text('Exam'),
              ),
            ],
            selected:
                <AppExperienceMode>{_mode},
            onSelectionChanged:
                (
                  Set<AppExperienceMode>
                      selection,
                ) {
              _setMode(selection.first);
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardItem {
  const _DashboardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.item,
  });

  final _DashboardItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.display,
      borderRadius:
          BorderRadius.circular(18),
      child: InkWell(
        onTap: item.onTap,
        borderRadius:
            BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color: item.enabled
                  ? const Color(
                      0xFF334155,
                    )
                  : const Color(
                      0xFF475569,
                    ),
            ),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                alignment:
                    Alignment.center,
                decoration: BoxDecoration(
                  color: item.enabled
                      ? AppTheme.equals
                          .withOpacity(
                          0.13,
                        )
                      : AppTheme.numberKey,
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                ),
                child: Icon(
                  item.enabled
                      ? item.icon
                      : Icons.lock_outline,
                  color: item.enabled
                      ? AppTheme.equals
                      : AppTheme.mutedText,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w800,
                        color: item.enabled
                            ? AppTheme
                                .primaryText
                            : AppTheme
                                .mutedText,
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      item.enabled
                          ? item.subtitle
                          : 'Locked in Exam Mode',
                      style: const TextStyle(
                        color: AppTheme
                            .secondaryText,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
