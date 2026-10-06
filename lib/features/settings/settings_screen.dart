import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/app_experience_mode.dart';
import '../../services/app_mode_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.initialMode,
    required this.onModeChanged,
  });

  final AppExperienceMode initialMode;
  final ValueChanged<AppExperienceMode>
      onModeChanged;

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {
  final AppModeRepository _repository =
      AppModeRepository();

  late AppExperienceMode _mode;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  Future<void> _setMode(
    AppExperienceMode mode,
  ) async {
    await _repository.save(mode);

    if (!mounted) return;

    setState(() {
      _mode = mode;
    });

    widget.onModeChanged(mode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor:
            AppTheme.background,
        surfaceTintColor:
            AppTheme.background,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 720,
            ),
            child: ListView(
              padding:
                  const EdgeInsets.all(16),
              children: <Widget>[
                Container(
                  padding:
                      const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.display,
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                    border: Border.all(
                      color: const Color(
                        0xFF334155,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .stretch,
                    children: <Widget>[
                      const Text(
                        'Experience mode',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      SegmentedButton<
                          AppExperienceMode>(
                        segments:
                            AppExperienceMode
                                .values
                                .map(
                                  (
                                    AppExperienceMode
                                        mode,
                                  ) =>
                                      ButtonSegment<
                                          AppExperienceMode>(
                                    value: mode,
                                    label: Text(
                                      mode ==
                                              AppExperienceMode
                                                  .study
                                          ? 'Study'
                                          : 'Exam',
                                    ),
                                    icon: Icon(
                                      mode ==
                                              AppExperienceMode
                                                  .study
                                          ? Icons
                                              .school_outlined
                                          : Icons
                                              .calculate_outlined,
                                    ),
                                  ),
                                )
                                .toList(),
                        selected:
                            <AppExperienceMode>{
                          _mode,
                        },
                        onSelectionChanged:
                            (
                              Set<
                                      AppExperienceMode>
                                  selection,
                            ) {
                          _setMode(
                            selection.first,
                          );
                        },
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      Text(
                        _mode.description,
                        style:
                            const TextStyle(
                          color: AppTheme
                              .secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _InfoCard(
                  icon:
                      Icons.lock_outline,
                  title:
                      'Exam Mode',
                  text:
                      'Keeps the core calculator modes available while hiding Graph, Formulas, History and Camera Solver. '
                      'Calculations made in Exam Mode are not added to Study history.',
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.school_outlined,
                  title: 'Study Mode',
                  text:
                      'Enables Formula Library, persistent History, Graphing, Camera Solver and step-by-step learning aids.',
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon:
                      Icons.camera_alt_outlined,
                  title:
                      'Camera Solver',
                  text:
                      'Android/iOS OCR uses the existing image_picker and Google ML Kit text recognition packages. '
                      'Chrome can test the cleanup and solving logic with manual text.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.display,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF334155),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon,
            color: AppTheme.equals,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppTheme
                        .secondaryText,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
