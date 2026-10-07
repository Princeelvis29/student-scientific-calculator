import 'package:flutter/material.dart';

import '../calculator_button.dart';
import 'calculator_key.dart';

class CalculatorKeypad extends StatelessWidget {
  const CalculatorKeypad({
    super.key,
    required this.controlButtons,
    required this.scientificButtons,
    required this.keypadButtons,
    required this.onPressed,
    required this.onScanPressed,
    this.showScanButton = true,
    this.compact = false,
  });

  final List<CalculatorButtonData> controlButtons;
  final List<CalculatorButtonData> scientificButtons;
  final List<CalculatorButtonData> keypadButtons;
  final ValueChanged<String> onPressed;
  final VoidCallback onScanPressed;
  final bool showScanButton;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double sectionGap = compact ? 6 : 10;

    return Column(
      children: <Widget>[
        SizedBox(
          height: compact ? 43 : 50,
          child: Row(
            children: controlButtons.map((button) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 2 : 3,
                  ),
                  child: CalculatorKey(
                    button: button,
                    onPressed: onPressed,
                    compact: true,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: sectionGap),
        _Grid(
          buttons: scientificButtons,
          onPressed: onPressed,
          compact: compact,
        ),
        SizedBox(height: sectionGap),
        _Grid(
          buttons: keypadButtons,
          onPressed: onPressed,
          compact: compact,
        ),
        if (showScanButton) ...<Widget>[
          SizedBox(height: sectionGap),
          SizedBox(
            width: double.infinity,
            height: compact ? 42 : 48,
            child: OutlinedButton.icon(
              onPressed: onScanPressed,
              icon: Icon(
                Icons.camera_alt_outlined,
                size: compact ? 18 : 20,
              ),
              label: Text(
                compact ? 'Camera Solver' : 'Scan problem',
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: Size.fromHeight(
                  compact ? 42 : 48,
                ),
                side: const BorderSide(
                  color: Color(0xFF475569),
                ),
                foregroundColor:
                    const Color(0xFFE2E8F0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    compact ? 12 : 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.buttons,
    required this.onPressed,
    required this.compact,
  });

  final List<CalculatorButtonData> buttons;
  final ValueChanged<String> onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: buttons.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: compact ? 5 : 7,
        crossAxisSpacing: compact ? 5 : 7,
        // Larger ratio => shorter keys, which helps small Android phones.
        childAspectRatio: compact ? 1.34 : 1.20,
      ),
      itemBuilder: (
        BuildContext context,
        int index,
      ) {
        return CalculatorKey(
          button: buttons[index],
          onPressed: onPressed,
          compact: compact,
        );
      },
    );
  }
}
