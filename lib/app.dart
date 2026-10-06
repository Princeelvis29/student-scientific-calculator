import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/calculator/calculator_screen.dart';

class ScientificCalculatorApp extends StatelessWidget {
  const ScientificCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scientific Calculator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const CalculatorScreen(),
    );
  }
}
