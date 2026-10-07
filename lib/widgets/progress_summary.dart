import 'package:flutter/material.dart';

import '../utils/app_constants.dart';

/// Resumen de progreso: barra semanal lineal y cumplimiento circular, ambos
/// con valor determinado y porcentaje visible.
class ProgressSummary extends StatelessWidget {
  const ProgressSummary({super.key});

  /// Desde este ancho local ambos bloques comparten una fila (si el texto es
  /// normal); en otro caso se apilan en columna.
  static const double _rowMinWidth = 600;

  @override
  Widget build(BuildContext context) {
    final bool largeText =
        MediaQuery.textScalerOf(context).scale(AppTypography.body) >
        AppTypography.largeTextThreshold;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const Widget weekly = _LinearProgressBlock();
        const Widget goals = _CircularProgressBlock();

        if (!largeText && constraints.maxWidth >= _rowMinWidth) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const <Widget>[
              Expanded(child: weekly),
              SizedBox(width: AppSpacing.xl),
              Expanded(child: goals),
            ],
          );
        }
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            weekly,
            SizedBox(height: AppSpacing.xl),
            goals,
          ],
        );
      },
    );
  }
}

/// Progreso semanal con LinearProgressIndicator determinado.
class _LinearProgressBlock extends StatelessWidget {
  const _LinearProgressBlock();

  @override
  Widget build(BuildContext context) {
    return const _ProgressCard(
      title: MockData.weeklyProgressTitle,
      semanticsLabel: MockData.weeklyProgressTitle,
      semanticsValue: MockData.weeklyProgressLabel,
      child: Row(
        children: <Widget>[
          Expanded(
            child: LinearProgressIndicator(
              value: MockData.weeklyProgressValue,
              minHeight: 10,
              borderRadius: BorderRadius.all(
                Radius.circular(AppRadii.indicator),
              ),
              backgroundColor: AppColors.track,
              color: AppColors.accent,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Text(MockData.weeklyProgressLabel, style: AppTextStyles.bodyStrong),
        ],
      ),
    );
  }
}

/// Cumplimiento de metas con CircularProgressIndicator determinado.
class _CircularProgressBlock extends StatelessWidget {
  const _CircularProgressBlock();

  @override
  Widget build(BuildContext context) {
    return const _ProgressCard(
      title: MockData.goalsProgressTitle,
      semanticsLabel: MockData.goalsProgressTitle,
      semanticsValue: MockData.goalsProgressLabel,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // El indicador vive en un SizedBox finito de 80 x 80.
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: MockData.goalsProgressValue,
              strokeWidth: 8,
              backgroundColor: AppColors.track,
              color: AppColors.accent,
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          // El porcentaje va fuera del círculo para admitir escalado sin cortes.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  MockData.goalsProgressLabel,
                  style: AppTextStyles.metricValue,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  MockData.goalsProgressCaption,
                  style: AppTextStyles.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta común de un bloque de progreso con descripción accesible propia.
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.title,
    required this.semanticsLabel,
    required this.semanticsValue,
    required this.child,
  });

  final String title;
  final String semanticsLabel;
  final String semanticsValue;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // excludeSemantics evita que el lector repita el texto visible.
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: semanticsLabel,
      value: semanticsValue,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.softCard,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.subtleBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: AppTextStyles.bodyStrong),
            const SizedBox(height: AppSpacing.lg),
            child,
          ],
        ),
      ),
    );
  }
}
