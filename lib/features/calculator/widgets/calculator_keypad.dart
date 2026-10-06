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
  });

  final List<CalculatorButtonData> controlButtons;
  final List<CalculatorButtonData> scientificButtons;
  final List<CalculatorButtonData> keypadButtons;
  final ValueChanged<String> onPressed;
  final VoidCallback onScanPressed;
  final bool showScanButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: controlButtons.map((button) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: CalculatorKey(
                  button: button,
                  onPressed: onPressed,
                  compact: true,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        _Grid(
          buttons: scientificButtons,
          onPressed: onPressed,
        ),
        const SizedBox(height: 10),
        _Grid(
          buttons: keypadButtons,
          onPressed: onPressed,
        ),
        if (showScanButton) ...<Widget>[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onScanPressed,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Scan problem'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(
                  color: Color(0xFF475569),
                ),
                foregroundColor: const Color(0xFFE2E8F0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
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
  });

  final List<CalculatorButtonData> buttons;
  final ValueChanged<String> onPressed;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: buttons.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 7,
        crossAxisSpacing: 7,
        childAspectRatio: 1.20,
      ),
      itemBuilder: (
        BuildContext context,
        int index,
      ) {
        return CalculatorKey(
          button: buttons[index],
          onPressed: onPressed,
        );
      },
    );
  }
}
