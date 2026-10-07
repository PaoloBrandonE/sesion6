import 'package:flutter/material.dart';

import '../utils/app_constants.dart';

/// Encabezado con saludo, fecha fija y avatar de ejemplo. Sin interacción.
class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const <Widget>[
              Text(MockData.greeting, style: AppTextStyles.sectionTitle),
              SizedBox(height: AppSpacing.xs),
              Text(MockData.todayLabel, style: AppTextStyles.secondary),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        // El avatar describe un perfil de ejemplo; no anuncia ninguna acción.
        Semantics(
          container: true,
          excludeSemantics: true,
          label: MockData.avatarSemantics,
          child: const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.accent,
            child: Text(
              MockData.avatarInitial,
              style: TextStyle(
                fontSize: AppTypography.body,
                fontWeight: FontWeight.w600,
                color: AppColors.surface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
