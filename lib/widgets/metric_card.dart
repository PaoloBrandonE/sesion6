import 'package:flutter/material.dart';

import '../utils/app_constants.dart';

/// Tarjeta de una métrica semanal: icono, nombre, valor, unidad y estado.
/// Sin altura fija: la tarjeta crece según su contenido.
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.softCard,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 24, color: AppColors.accent),
          const SizedBox(height: AppSpacing.sm),
          Text(name, style: AppTextStyles.bodyStrong),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(value, style: AppTextStyles.metricValue),
              const SizedBox(width: AppSpacing.xs),
              Flexible(child: Text(unit, style: AppTextStyles.secondary)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(status, style: AppTextStyles.secondary),
        ],
      ),
    );
  }
}
