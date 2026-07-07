import 'package:flutter/material.dart';

import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/spacing.dart';
import '../../../../../core/theme/typography.dart';
import '../../domain/entities/meal_history.dart';

class MealStatusBadge extends StatelessWidget {
  final TypeIdentification type;

  const MealStatusBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (type) {
      TypeIdentification.face => ('Visage', AppColors.success, Icons.face),
      TypeIdentification.qr => ('QR Code', AppColors.info, Icons.qr_code),
      TypeIdentification.unknown => ('Inconnu', AppColors.outline, Icons.help_outline),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTypography.badgeLabel.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
