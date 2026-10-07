import 'package:flutter/material.dart';

import '../utils/app_constants.dart';

/// Tarjeta de logro con insignia de trofeo superpuesta en la esquina superior.
class AchievementCard extends StatelessWidget {
  const AchievementCard({super.key});

  /// Espacio reservado arriba para que la insignia no tape el texto.
  static const double _topReservedSpace = 24;

  /// Espacio reservado a la derecha para que la insignia no tape el texto.
  static const double _sideReservedSpace = 56;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.cardPadding,
            _topReservedSpace,
            _sideReservedSpace,
            AppSpacing.cardPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.softCard,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: AppColors.subtleBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.local_fire_department,
                    size: 22,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      MockData.achievementTitle,
                      style: AppTextStyles.sectionTitle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                MockData.achievementSubtitle,
                style: AppTextStyles.secondary,
              ),
            ],
          ),
        ),
        const Positioned(top: 0, right: 0, child: _AchievementBadge()),
      ],
    );
  }
}

/// Insignia de trofeo dentro de los límites del Stack.
class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.emoji_events,
        size: 24,
        color: AppColors.surface,
        semanticLabel: MockData.achievementBadgeSemantics,
      ),
    );
  }
}
