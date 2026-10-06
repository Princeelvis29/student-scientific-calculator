import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../calculator_button.dart';

class CalculatorKey extends StatelessWidget {
  const CalculatorKey({
    super.key,
    required this.button,
    required this.onPressed,
    this.compact = false,
  });

  final CalculatorButtonData button;
  final ValueChanged<String> onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground = Colors.white;
    Color border = Colors.transparent;

    switch (button.kind) {
      case CalculatorButtonKind.number:
        background = AppTheme.numberKey;
        border = const Color(0xFF334155);
        break;

      case CalculatorButtonKind.function:
        background = AppTheme.functionKey;
        border = AppTheme.border;
        break;

      case CalculatorButtonKind.operator:
        background = AppTheme.operator;
        break;

      case CalculatorButtonKind.equals:
        background = AppTheme.equals;
        foreground = AppTheme.display;
        break;

      case CalculatorButtonKind.danger:
        background = AppTheme.danger;
        break;

      case CalculatorButtonKind.control:
        background = AppTheme.background;
        border = AppTheme.border;
        foreground = AppTheme.secondaryText;
        break;

      case CalculatorButtonKind.active:
        background = AppTheme.active;
        border = AppTheme.equals;
        foreground = const Color(0xFFFDE68A);
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onPressed(button.label),
        borderRadius: BorderRadius.circular(
          compact ? 12 : 14,
        ),
        child: Ink(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(
              compact ? 12 : 14,
            ),
            border: Border.all(color: border),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 4 : 6,
                vertical: compact ? 10 : 7,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (button.secondaryLabel != null)
                    Text(
                      button.secondaryLabel!,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFFFBBF24),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  if (button.alphaLabel != null)
                    Text(
                      button.alphaLabel!,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF60A5FA),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  Text(
                    button.label,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: compact ? 13 : 17,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
