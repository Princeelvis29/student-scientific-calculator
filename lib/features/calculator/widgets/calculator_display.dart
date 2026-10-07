import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class CalculatorDisplay extends StatelessWidget {
  const CalculatorDisplay({
    super.key,
    required this.equation,
    required this.result,
    required this.isDegreeMode,
    required this.shiftEnabled,
    required this.alphaEnabled,
    required this.hyperbolicEnabled,
    required this.modeLabel,
    required this.onAngleModeTap,
    required this.onHistoryTap,
    required this.onFormulaLibraryTap,
    required this.onGraphingTap,
    this.showStudyTools = true,
    this.compact = false,
  });

  final String equation;
  final String result;
  final bool isDegreeMode;
  final bool shiftEnabled;
  final bool alphaEnabled;
  final bool hyperbolicEnabled;
  final String modeLabel;
  final VoidCallback onAngleModeTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onFormulaLibraryTap;
  final VoidCallback onGraphingTap;
  final bool showStudyTools;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        // The full desktop header does not fit on narrow Android phones.
        // On compact widths, Study tools move into a single overflow menu.
        final bool narrow = constraints.maxWidth < 430;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            compact ? 12 : 18,
            compact ? 10 : 14,
            compact ? 12 : 18,
            compact ? 13 : 18,
          ),
          decoration: BoxDecoration(
            color: AppTheme.display,
            borderRadius: BorderRadius.circular(
              compact ? 17 : 20,
            ),
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
                  _Indicator(
                    text:
                        isDegreeMode ? 'DEG' : 'RAD',
                    active: true,
                    onTap: onAngleModeTap,
                    compact: compact,
                  ),
                  SizedBox(width: compact ? 4 : 6),
                  _Indicator(
                    text: 'SHIFT',
                    active: shiftEnabled,
                    compact: compact,
                  ),
                  SizedBox(width: compact ? 4 : 6),
                  _Indicator(
                    text: 'ALPHA',
                    active: alphaEnabled,
                    compact: compact,
                  ),
                  if (hyperbolicEnabled && !narrow) ...<Widget>[
                    const SizedBox(width: 6),
                    _Indicator(
                      text: 'HYP',
                      active: true,
                      compact: compact,
                    ),
                  ],
                  const Spacer(),
                  Flexible(
                    child: Text(
                      modeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: compact ? 9 : 10,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.mutedText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  if (showStudyTools && !narrow) ...<Widget>[
                    _HeaderIconButton(
                      tooltip: 'Graphing',
                      icon: Icons.show_chart,
                      onPressed: onGraphingTap,
                    ),
                    _HeaderIconButton(
                      tooltip: 'Formula library',
                      icon: Icons.menu_book_outlined,
                      onPressed: onFormulaLibraryTap,
                    ),
                    _HeaderIconButton(
                      tooltip: 'Calculation history',
                      icon: Icons.history,
                      onPressed: onHistoryTap,
                    ),
                  ],
                  if (showStudyTools && narrow)
                    PopupMenuButton<_StudyToolAction>(
                      tooltip: 'Study tools',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 180,
                      ),
                      icon: const Icon(
                        Icons.more_vert,
                        size: 21,
                        color: AppTheme.secondaryText,
                      ),
                      onSelected: (
                        _StudyToolAction action,
                      ) {
                        switch (action) {
                          case _StudyToolAction.graph:
                            onGraphingTap();
                            return;
                          case _StudyToolAction.formulas:
                            onFormulaLibraryTap();
                            return;
                          case _StudyToolAction.history:
                            onHistoryTap();
                            return;
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          const <
                              PopupMenuEntry<
                                  _StudyToolAction>>[
                        PopupMenuItem<_StudyToolAction>(
                          value: _StudyToolAction.graph,
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.show_chart),
                            title: Text('Graph'),
                          ),
                        ),
                        PopupMenuItem<_StudyToolAction>(
                          value: _StudyToolAction.formulas,
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading:
                                Icon(Icons.menu_book_outlined),
                            title: Text('Formula Library'),
                          ),
                        ),
                        PopupMenuItem<_StudyToolAction>(
                          value: _StudyToolAction.history,
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.history),
                            title: Text('History'),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(width: compact ? 1 : 4),
                  Icon(
                    Icons.battery_5_bar,
                    size: compact ? 18 : 20,
                    color: AppTheme.secondaryText,
                  ),
                ],
              ),
              SizedBox(height: compact ? 14 : 26),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(
                  equation,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: compact ? 20 : 26,
                    color: AppTheme.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: compact ? 7 : 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(
                  result,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: compact
                        ? (result.length > 16 ? 27 : 34)
                        : (result.length > 16 ? 34 : 44),
                    color: AppTheme.primaryText,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum _StudyToolAction {
  graph,
  formulas,
  history,
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(
        minWidth: 34,
        minHeight: 34,
      ),
      padding: EdgeInsets.zero,
      icon: Icon(
        icon,
        size: 20,
        color: AppTheme.secondaryText,
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({
    required this.text,
    required this.active,
    this.onTap,
    this.compact = false,
  });

  final String text;
  final bool active;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Widget chip = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: active
            ? AppTheme.equals.withOpacity(0.18)
            : AppTheme.numberKey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active
              ? AppTheme.equals
              : const Color(0xFF334155),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w800,
          color: active
              ? const Color(0xFFFBBF24)
              : AppTheme.mutedText,
        ),
      ),
    );

    if (onTap == null) {
      return chip;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: chip,
    );
  }
}
