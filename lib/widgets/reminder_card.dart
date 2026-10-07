import 'package:flutter/material.dart';

import '../utils/app_constants.dart';

/// Recordatorio de ejemplo: icono, nombre y hora. Sin acciones funcionales.
class ReminderCard extends StatelessWidget {
  const ReminderCard({
    super.key,
    required this.icon,
    required this.name,
    required this.time,
  });

  final IconData icon;
  final String name;
  final String time;

  /// Por debajo de este ancho local (o con texto grande) la hora baja al
  /// segundo renglón para evitar desbordes.
  static const double _stackMaxWidth = 360;

  @override
  Widget build(BuildContext context) {
    final bool largeText =
        MediaQuery.textScalerOf(context).scale(AppTypography.body) >
        AppTypography.largeTextThreshold;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool stackTime =
            largeText || constraints.maxWidth < _stackMaxWidth;
        final Text nameText = Text(name, style: AppTextStyles.bodyStrong);
        final Text timeText = Text(time, style: AppTextStyles.secondary);

        return Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: AppColors.softCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.card),
            side: const BorderSide(color: AppColors.subtleBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: 24, color: AppColors.accent),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: stackTime
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            nameText,
                            const SizedBox(height: AppSpacing.xs),
                            timeText,
                          ],
                        )
                      : Row(
                          children: <Widget>[
                            Expanded(child: nameText),
                            const SizedBox(width: AppSpacing.md),
                            timeText,
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
