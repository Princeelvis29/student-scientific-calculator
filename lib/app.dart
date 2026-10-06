import 'package:flutter/material.dart';

import 'core/settings/app_ui_controller.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_dashboard_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

class ScientificCalculatorApp
    extends StatefulWidget {
  const ScientificCalculatorApp({
    super.key,
  });

  @override
  State<ScientificCalculatorApp>
      createState() =>
          _ScientificCalculatorAppState();
}

class _ScientificCalculatorAppState
    extends State<ScientificCalculatorApp> {
  late final AppUiController _ui;

  @override
  void initState() {
    super.initState();
    _ui = AppUiController();
    _ui.load();
  }

  @override
  void dispose() {
    _ui.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppUiScope(
      controller: _ui,
      child:
          AnimatedBuilder(
        animation: _ui,
        builder: (
          BuildContext context,
          Widget? child,
        ) {
          if (!_ui.loaded) {
            return MaterialApp(
              debugShowCheckedModeBanner:
                  false,
              theme: AppTheme.dark(),
              home: const _BootScreen(),
            );
          }

          final prefs = _ui.value;

          return MaterialApp(
            title:
                'Arktech Calculator',
            debugShowCheckedModeBanner:
                false,
            theme: AppTheme.light(
              highContrast:
                  prefs.highContrast,
            ),
            darkTheme: AppTheme.dark(
              highContrast:
                  prefs.highContrast,
            ),
            themeMode: _ui.themeMode,
            builder: (
              BuildContext context,
              Widget? child,
            ) {
              if (child == null) {
                return const SizedBox.shrink();
              }

              final MediaQueryData media =
                  MediaQuery.of(context);

              return MediaQuery(
                data: media.copyWith(
                  textScaler:
                      TextScaler.linear(
                    prefs.textSize.scale,
                  ),
                ),
                child: child,
              );
            },
            home: prefs.onboardingCompleted
                ? const HomeDashboardScreen()
                : OnboardingScreen(
                    onFinished: () async {
                      await _ui
                          .completeOnboarding();
                    },
                  ),
          );
        },
      ),
    );
  }
}

class _BootScreen extends StatelessWidget {
  const _BootScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: <Widget>[
            Image.asset(
              'assets/branding/arktech_splash_logo.png',
              width: 104,
              height: 104,
            ),
            const SizedBox(height: 20),
            const Text(
              'Arktech Calculator',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            const SizedBox(
              width: 26,
              height: 26,
              child:
                  CircularProgressIndicator(
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
