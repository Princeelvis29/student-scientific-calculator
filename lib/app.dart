import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/home/home_dashboard_screen.dart';

class ScientificCalculatorApp extends StatelessWidget {
  const ScientificCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arktech Student Scientific Calculator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const HomeDashboardScreen(),
    );
  }
}
