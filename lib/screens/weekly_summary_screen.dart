import 'package:flutter/material.dart';

import '../utils/app_constants.dart';
import '../widgets/achievement_card.dart';
import '../widgets/header_section.dart';
import '../widgets/metric_card.dart';
import '../widgets/progress_summary.dart';
import '../widgets/reminder_card.dart';
import '../widgets/weekly_calendar.dart';

/// Pantalla única «Resumen semanal de hábitos de estudio y bienestar».
class WeeklySummaryScreen extends StatelessWidget {
  const WeeklySummaryScreen({super.key});

  /// Ancho máximo del contenido, centrado en viewports amplios.
  static const double _maxContentWidth = 1120;

  /// Por debajo de este ancho de viewport se usa un padding más compacto.
  static const double _compactViewportWidth = 600;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double horizontalPadding =
        mediaQuery.size.width < _compactViewportWidth ? 16 : 24;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: AppSpacing.xl,
                ),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    // Column bajo scroll: sin flexibles verticales.
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const HeaderSection(),
                        const SizedBox(height: AppSpacing.sectionSpacing),
                        const Text(
                          MockData.screenTitle,
                          style: AppTextStyles.screenTitle,
                        ),
                        const SizedBox(height: AppSpacing.sectionSpacing),
                        const WeeklyCalendar(),
                        const SizedBox(height: AppSpacing.sectionSpacing),
                        const _MetricsSection(),
                        const SizedBox(height: AppSpacing.sectionSpacing),
                        const ProgressSummary(),
                        const SizedBox(height: AppSpacing.sectionSpacing),
                        const AchievementCard(),
                        const SizedBox(height: AppSpacing.sectionSpacing),
                        const _RemindersSection(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Métricas en Wrap: cuatro columnas si hay ancho y texto normal, dos columnas
/// por debajo y una columna como salvaguarda para texto grande o ancho mínimo.
class _MetricsSection extends StatelessWidget {
  const _MetricsSection();

  static const double _fourColumnMinWidth = 900;
  static const double _singleColumnMaxWidth = 280;

  @override
  Widget build(BuildContext context) {
    final bool largeText =
        MediaQuery.textScalerOf(context).scale(AppTypography.body) >
        AppTypography.largeTextThreshold;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          MockData.metricsSectionTitle,
          style: AppTextStyles.sectionTitle,
        ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double availableWidth = constraints.maxWidth;
            final int columns;
            if (largeText || availableWidth < _singleColumnMaxWidth) {
              columns = 1;
            } else if (availableWidth >= _fourColumnMinWidth) {
              columns = 4;
            } else {
              columns = 2;
            }
            final double cardWidth =
                (availableWidth - AppSpacing.metricSpacing * (columns - 1)) /
                columns;
            return Wrap(
              spacing: AppSpacing.metricSpacing,
              runSpacing: AppSpacing.metricSpacing,
              children: <Widget>[
                for (final WeeklyMetric metric in MockData.metrics)
                  SizedBox(
                    width: cardWidth,
                    child: MetricCard(
                      icon: metric.icon,
                      name: metric.name,
                      value: metric.value,
                      unit: metric.unit,
                      status: metric.status,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Recordatorios en una lista corta anidada: el scroll lo hace la página.
class _RemindersSection extends StatelessWidget {
  const _RemindersSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          MockData.remindersSectionTitle,
          style: AppTextStyles.sectionTitle,
        ),
        const SizedBox(height: AppSpacing.md),
        ListView.separated(
          shrinkWrap: true,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: MockData.reminders.length,
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(height: AppSpacing.md),
          itemBuilder: (BuildContext context, int index) {
            final StudyReminder reminder = MockData.reminders[index];
            return ReminderCard(
              icon: reminder.icon,
              name: reminder.name,
              time: reminder.time,
            );
          },
        ),
      ],
    );
  }
}
