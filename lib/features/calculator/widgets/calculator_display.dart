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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        color: AppTheme.display,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              _Indicator(
                text: isDegreeMode ? 'DEG' : 'RAD',
                active: true,
                onTap: onAngleModeTap,
              ),
              const SizedBox(width: 6),
              _Indicator(
                text: 'SHIFT',
                active: shiftEnabled,
              ),
              const SizedBox(width: 6),
              _Indicator(
                text: 'ALPHA',
                active: alphaEnabled,
              ),
              if (hyperbolicEnabled) ...<Widget>[
                const SizedBox(width: 6),
                const _Indicator(
                  text: 'HYP',
                  active: true,
                ),
              ],
              const Spacer(),
              Text(
                modeLabel,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.mutedText,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Formula library',
                onPressed: onFormulaLibraryTap,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(
                  minWidth: 34,
                  minHeight: 34,
                ),
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.menu_book_outlined,
                  size: 20,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(width: 2),
              IconButton(
                tooltip: 'Calculation history',
                onPressed: onHistoryTap,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(
                  minWidth: 34,
                  minHeight: 34,
                ),
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.history,
                  size: 20,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.battery_5_bar,
                size: 20,
                color: AppTheme.secondaryText,
              ),
            ],
          ),
          const SizedBox(height: 26),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Text(
              equation,
              textAlign: TextAlign.right,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 26,
                color: AppTheme.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Text(
              result,
              textAlign: TextAlign.right,
              maxLines: 1,
              style: TextStyle(
                fontSize: result.length > 16 ? 34 : 44,
                color: AppTheme.primaryText,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({
    required this.text,
    required this.active,
    this.onTap,
  });

  final String text;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget chip = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
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
          fontSize: 11,
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
