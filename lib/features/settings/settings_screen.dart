import 'package:flutter/material.dart';

import '../../core/settings/app_ui_controller.dart';
import '../../core/settings/app_ui_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../models/app_experience_mode.dart';
import '../../services/app_mode_repository.dart';
import '../../services/interaction_feedback_service.dart';
import '../onboarding/onboarding_screen.dart';

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

    InteractionFeedbackService.tap(
      context,
      stronger: true,
    );

    setState(() {
      _mode = mode;
    });

    widget.onModeChanged(mode);
  }

  Future<void> _replayOnboarding(
    AppUiController ui,
  ) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            OnboardingScreen(
          onFinished: () async {
            await ui
                .completeOnboarding();

            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppUiController ui =
        AppUiScope.of(context);

    final AppUiPreferences prefs =
        ui.value;

    final ColorScheme scheme =
        Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 760,
            ),
            child: ListView(
              padding:
                  const EdgeInsets.all(16),
              children: <Widget>[
                _SettingsSection(
                  icon:
                      Icons.school_outlined,
                  title:
                      'Experience mode',
                  subtitle:
                      'Choose the tools available while studying or practising.',
                  child:
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
                ),
                const SizedBox(height: 14),
                _SettingsSection(
                  icon:
                      Icons.palette_outlined,
                  title: 'Appearance',
                  subtitle:
                      'Control theme and readability.',
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .stretch,
                    children: <Widget>[
                      DropdownButtonFormField<
                          AppThemePreference>(
                        value: prefs.theme,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Theme',
                        ),
                        items:
                            AppThemePreference
                                .values
                                .map(
                                  (
                                    AppThemePreference
                                        item,
                                  ) =>
                                      DropdownMenuItem<
                                          AppThemePreference>(
                                    value:
                                        item,
                                    child: Text(
                                      item.label,
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (
                              AppThemePreference?
                                  value,
                            ) {
                          if (value !=
                              null) {
                            InteractionFeedbackService
                                .tap(
                              context,
                            );
                            ui.setTheme(
                              value,
                            );
                          }
                        },
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      DropdownButtonFormField<
                          AppTextSize>(
                        value: prefs.textSize,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Text size',
                        ),
                        items: AppTextSize
                            .values
                            .map(
                              (
                                AppTextSize
                                    item,
                              ) =>
                                  DropdownMenuItem<
                                      AppTextSize>(
                                value:
                                    item,
                                child: Text(
                                  '${item.label} (${(item.scale * 100).round()}%)',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged:
                            (
                              AppTextSize?
                                  value,
                            ) {
                          if (value !=
                              null) {
                            InteractionFeedbackService
                                .tap(
                              context,
                            );
                            ui.setTextSize(
                              value,
                            );
                          }
                        },
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      SwitchListTile(
                        contentPadding:
                            EdgeInsets.zero,
                        title: const Text(
                          'High contrast',
                        ),
                        subtitle:
                            const Text(
                          'Strengthens borders and surface contrast.',
                        ),
                        value:
                            prefs.highContrast,
                        onChanged:
                            ui.setHighContrast,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _SettingsSection(
                  icon:
                      Icons.touch_app_outlined,
                  title:
                      'Calculator feedback',
                  subtitle:
                      'Control physical and audible key feedback.',
                  child: Column(
                    children: <Widget>[
                      SwitchListTile(
                        contentPadding:
                            EdgeInsets.zero,
                        title: const Text(
                          'Haptics / vibration',
                        ),
                        subtitle:
                            const Text(
                          'Provides tactile feedback when calculator keys are pressed.',
                        ),
                        value: prefs
                            .hapticsEnabled,
                        onChanged:
                            ui.setHaptics,
                      ),
                      Divider(
                        color: scheme
                            .outlineVariant,
                      ),
                      SwitchListTile(
                        contentPadding:
                            EdgeInsets.zero,
                        title: const Text(
                          'Button sounds',
                        ),
                        subtitle:
                            const Text(
                          'Optional system click sound for calculator keys.',
                        ),
                        value: prefs
                            .buttonSoundsEnabled,
                        onChanged:
                            ui.setButtonSounds,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _SettingsSection(
                  icon:
                      Icons.accessibility_new,
                  title:
                      'Accessibility',
                  subtitle:
                      'The app uses minimum 44px touch targets, semantic labels and scalable text.',
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .stretch,
                    children: <Widget>[
                      const Text(
                        'Text scales across screens through the selected text-size setting. '
                        'Calculator keys include accessibility labels and the interface remains responsive on narrow phones.',
                        style: TextStyle(
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            _replayOnboarding(
                          ui,
                        ),
                        icon: const Icon(
                          Icons.slideshow_outlined,
                        ),
                        label: const Text(
                          'Replay onboarding',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const _InfoCard(
                  icon:
                      Icons.lock_outline,
                  title:
                      'Exam Mode',
                  text:
                      'Keeps core calculator modes available while study aids such as Graph, Formulas, History and Camera Solver are hidden.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsSection
    extends StatelessWidget {
  const _SettingsSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: scheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                alignment:
                    Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primary
                      .withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  icon,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: scheme
                            .onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
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
    final ColorScheme scheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon,
            color: scheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: TextStyle(
                    color: scheme
                        .onSurfaceVariant,
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
