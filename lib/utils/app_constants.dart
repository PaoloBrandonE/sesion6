import 'package:flutter/material.dart';

/// Colores y superficies de la dirección visual (inspiración conceptual en
/// Google Fit: calma, espacio en blanco y tarjetas suaves).
abstract final class AppColors {
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color softCard = Color(0xFFEDF3FA);
  static const Color textPrimary = Color(0xFF172B4D);
  static const Color textSecondary = Color(0xFF42526E);
  static const Color accent = Color(0xFF2457A7);
  static const Color success = Color(0xFF216E4E);
  static const Color successSurface = Color(0xFFE8F5ED);
  static const Color subtleBorder = Color(0xFFD6E0EC);
  static const Color track = Color(0xFFCBD8E8);
}

/// Escala de separación: 4, 8, 12, 16, 24 y 32 dp.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const double cardPadding = 16;
  static const double metricSpacing = 12;
  static const double sectionSpacing = 24;
}

/// Radios consistentes: tarjetas 16, chips 12, indicadores 8.
abstract final class AppRadii {
  static const double card = 16;
  static const double chip = 12;
  static const double indicator = 8;
}

/// Tamaños de la jerarquía tipográfica en sp.
abstract final class AppTypography {
  static const double screenTitle = 28;
  static const double sectionTitle = 20;
  static const double metricValue = 30;
  static const double body = 16;
  static const double secondary = 14;

  /// Umbral para considerar «texto grande»: scale(16) > 20.
  static const double largeTextThreshold = 20;
}

/// Estilos de texto derivados de la jerarquía tipográfica.
abstract final class AppTextStyles {
  static const TextStyle screenTitle = TextStyle(
    fontSize: AppTypography.screenTitle,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: AppTypography.sectionTitle,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle metricValue = TextStyle(
    fontSize: AppTypography.metricValue,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  static const TextStyle body = TextStyle(
    fontSize: AppTypography.body,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontSize: AppTypography.body,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle secondary = TextStyle(
    fontSize: AppTypography.secondary,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  static const TextStyle secondaryStrong = TextStyle(
    fontSize: AppTypography.secondary,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
}

/// Estado de un día de la semana resumida.
enum DayStatus {
  completed('Cumplido'),
  pending('Pendiente');

  const DayStatus(this.label);

  /// Etiqueta textual que acompaña al icono: el estado nunca depende del color.
  final String label;
}

/// Día del calendario semanal (dato mock inmutable).
@immutable
class StudyDay {
  const StudyDay({
    required this.abbreviation,
    required this.dayNumber,
    required this.status,
  });

  final String abbreviation;
  final int dayNumber;
  final DayStatus status;
}

/// Métrica semanal (dato mock inmutable).
@immutable
class WeeklyMetric {
  const WeeklyMetric({
    required this.icon,
    required this.name,
    required this.value,
    required this.unit,
    required this.status,
  });

  final IconData icon;
  final String name;
  final String value;
  final String unit;
  final String status;
}

/// Recordatorio de ejemplo (dato mock inmutable, sin acciones).
@immutable
class StudyReminder {
  const StudyReminder({
    required this.icon,
    required this.name,
    required this.time,
  });

  final IconData icon;
  final String name;
  final String time;
}

/// Datos constantes de la pantalla. No se calcula ninguna métrica de negocio;
/// los porcentajes son valores mock suministrados.
abstract final class MockData {
  static const String greeting = 'Buenos días, Alex';
  static const String todayLabel = 'Martes, 6 de octubre de 2026';
  static const String avatarInitial = 'A';
  static const String avatarSemantics = 'Perfil de ejemplo';
  static const String screenTitle = 'Tu resumen semanal';
  static const String weekSectionTitle = 'Esta semana';
  static const String weekRangeLabel =
      'Semana resumida anterior · 28 sep. – 4 oct. de 2026';
  static const String metricsSectionTitle = 'Métricas de la semana';
  static const String remindersSectionTitle = 'Recordatorios';
  static const String achievementTitle = '5 días de racha';
  static const String achievementSubtitle = 'Semana productiva';
  static const String achievementBadgeSemantics = 'Insignia de trofeo';

  // Progreso semanal y cumplimiento: valores constantes suministrados.
  static const String weeklyProgressTitle = 'Progreso semanal';
  static const String weeklyProgressLabel = '82 %';
  static const double weeklyProgressValue = 0.82;

  static const String goalsProgressTitle = 'Cumplimiento de metas';
  static const String goalsProgressLabel = '82 %';
  static const String goalsProgressCaption = '18 de 22 metas completadas';
  static const double goalsProgressValue = 0.82;

  static const List<StudyDay> weekDays = <StudyDay>[
    StudyDay(abbreviation: 'Lun', dayNumber: 28, status: DayStatus.completed),
    StudyDay(abbreviation: 'Mar', dayNumber: 29, status: DayStatus.completed),
    StudyDay(abbreviation: 'Mié', dayNumber: 30, status: DayStatus.completed),
    StudyDay(abbreviation: 'Jue', dayNumber: 1, status: DayStatus.completed),
    StudyDay(abbreviation: 'Vie', dayNumber: 2, status: DayStatus.completed),
    StudyDay(abbreviation: 'Sáb', dayNumber: 3, status: DayStatus.pending),
    StudyDay(abbreviation: 'Dom', dayNumber: 4, status: DayStatus.pending),
  ];

  static const List<WeeklyMetric> metrics = <WeeklyMetric>[
    WeeklyMetric(
      icon: Icons.menu_book,
      name: 'Horas de estudio',
      value: '18',
      unit: 'h',
      status: 'Meta cumplida',
    ),
    WeeklyMetric(
      icon: Icons.bedtime,
      name: 'Sueño',
      value: '7,5',
      unit: 'h por noche',
      status: 'Óptimo',
    ),
    WeeklyMetric(
      icon: Icons.directions_run,
      name: 'Actividad física',
      value: '180',
      unit: 'min',
      status: 'Meta cumplida',
    ),
    WeeklyMetric(
      icon: Icons.flag,
      name: 'Cumplimiento de metas',
      value: '82',
      unit: '%',
      status: '18 de 22 completadas',
    ),
  ];

  static const List<StudyReminder> reminders = <StudyReminder>[
    StudyReminder(icon: Icons.menu_book, name: 'Estudiar Redes', time: '19:00'),
    StudyReminder(
      icon: Icons.directions_run,
      name: 'Actividad física',
      time: '07:00',
    ),
    StudyReminder(icon: Icons.bedtime, name: 'Dormir', time: '22:30'),
  ];
}
