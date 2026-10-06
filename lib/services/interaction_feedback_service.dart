import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/settings/app_ui_controller.dart';

class InteractionFeedbackService {
  const InteractionFeedbackService._();

  static void tap(
    BuildContext context, {
    bool stronger = false,
  }) {
    final AppUiController? controller =
        AppUiScope.maybeOf(context);

    final bool haptics =
        controller?.value.hapticsEnabled ?? true;

    final bool sounds =
        controller?.value.buttonSoundsEnabled ?? false;

    if (haptics) {
      if (stronger) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.selectionClick();
      }
    }

    if (sounds) {
      SystemSound.play(
        SystemSoundType.click,
      );
    }
  }
}
