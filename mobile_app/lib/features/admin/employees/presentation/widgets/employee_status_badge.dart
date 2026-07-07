import 'package:flutter/material.dart';

import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/spacing.dart';
import '../../../../../core/theme/typography.dart';

class EmployeeStatusBadge extends StatelessWidget {
  final String status;

  const EmployeeStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (status.toUpperCase()) {
      'ACTIF' => (AppColors.success, 'Actif'),
      'INACTIF' => (AppColors.warning, 'Inactif'),
      'SUPPRIME' => (AppColors.error, 'Supprimé'),
      'NON_ENROLE' => (AppColors.outline, 'Non enrolé'),
      'ENROLE' => (AppColors.info, 'Enrolé'),
      'ENROLEMENT_ECHOUE' => (AppColors.error, 'Échec enrôlement'),
      _ => (AppColors.outline, status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xxs + 1),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Text(
        label,
        style: AppTypography.badgeLabel.copyWith(color: color),
      ),
    );
  }
}
