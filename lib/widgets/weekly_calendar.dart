import 'package:flutter/material.dart';

import '../utils/app_constants.dart';

/// Calendario de la semana resumida con los siete días y su estado.
class WeeklyCalendar extends StatelessWidget {
  const WeeklyCalendar({super.key});

  /// Desde este ancho local se usa una fila con siete celdas expandidas.
  static const double _rowMinWidth = 700;

  /// Ancho mínimo aproximado por celda en el diseño envuelto (Wrap).
  static const double _wrapCellMinWidth = 96;

  /// Ancho mínimo por celda cuando el texto del sistema está ampliado.
  static const double _wrapCellMinWidthLargeText = 128;

  static const double _wrapSpacing = 8;
  static const int _maxColumns = 7;

  @override
  Widget build(BuildContext context) {
    final bool largeText =
        MediaQuery.textScalerOf(context).scale(AppTypography.body) >
        AppTypography.largeTextThreshold;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          MockData.weekSectionTitle,
          style: AppTextStyles.sectionTitle,
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(MockData.weekRangeLabel, style: AppTextStyles.secondary),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double availableWidth = constraints.maxWidth;
            if (!largeText && availableWidth >= _rowMinWidth) {
              return _buildRowCalendar();
            }
            return _buildWrappedCalendar(availableWidth, largeText);
          },
        ),
      ],
    );
  }

  /// Fila con siete celdas expandidas para anchos amplios y texto normal.
  Widget _buildRowCalendar() {
    final int lastIndex = MockData.weekDays.length - 1;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i <= lastIndex; i++) ...<Widget>[
          Expanded(child: _DayCell(day: MockData.weekDays[i])),
          if (i != lastIndex) const SizedBox(width: _wrapSpacing),
        ],
      ],
    );
  }

  /// Envoltura con celdas de ancho finito para anchos estrechos o texto grande.
  /// Nunca se coloca Expanded dentro de un Wrap.
  Widget _buildWrappedCalendar(double availableWidth, bool largeText) {
    final double minCellWidth = largeText
        ? _wrapCellMinWidthLargeText
        : _wrapCellMinWidth;
    final int columns =
        ((availableWidth + _wrapSpacing) / (minCellWidth + _wrapSpacing))
            .floor()
            .clamp(1, _maxColumns);
    final double cellWidth =
        (availableWidth - _wrapSpacing * (columns - 1)) / columns;
    return Wrap(
      spacing: _wrapSpacing,
      runSpacing: _wrapSpacing,
      children: <Widget>[
        for (final StudyDay day in MockData.weekDays)
          SizedBox(
            width: cellWidth,
            child: _DayCell(day: day),
          ),
      ],
    );
  }
}

/// Celda de un día: abreviatura, número y estado con icono y texto.
class _DayCell extends StatelessWidget {
  const _DayCell({required this.day});

  final StudyDay day;

  @override
  Widget build(BuildContext context) {
    final bool completed = day.status == DayStatus.completed;
    final Color statusColor = completed
        ? AppColors.success
        : AppColors.textSecondary;
    final Color surfaceColor = completed
        ? AppColors.successSurface
        : AppColors.softCard;
    final IconData statusIcon = completed
        ? Icons.check_circle
        : Icons.radio_button_unchecked;

    // El estado no depende del color: icono + texto lo describen.
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: '${day.abbreviation} ${day.dayNumber}, ${day.status.label}',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          border: Border.all(color: AppColors.subtleBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(day.abbreviation, style: AppTextStyles.secondaryStrong),
            const SizedBox(height: AppSpacing.xs),
            Text('${day.dayNumber}', style: AppTextStyles.sectionTitle),
            const SizedBox(height: AppSpacing.sm),
            // Wrap evita que el estado se recorte en celdas estrechas: el
            // icono y el texto pasan a renglones distintos si hace falta.
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Icon(statusIcon, size: 16, color: statusColor),
                Text(
                  day.status.label,
                  style: TextStyle(
                    fontSize: AppTypography.secondary,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
