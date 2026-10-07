import 'package:flutter/material.dart';

import 'screens/weekly_summary_screen.dart';
import 'utils/app_constants.dart';

void main() {
  runApp(const ResumenSemanalApp());
}

/// Aplicación de una sola pantalla con tema Material 3.
class ResumenSemanalApp extends StatelessWidget {
  const ResumenSemanalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resumen semanal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const WeeklySummaryScreen(),
    );
  }
}
