import 'package:flutter/material.dart';

import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/spacing.dart';
import '../../../../../core/theme/typography.dart';
import '../../domain/entities/qr_code.dart';

class QrStatusBadge extends StatelessWidget {
  final String status;

  const QrStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (status.toUpperCase()) {
      'ACTIF' => (AppColors.success, 'Actif'),
      'EXPIRE' => (AppColors.error, 'Expiré'),
      'REVOQUE' => (AppColors.warning, 'Révoqué'),
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

class QrTypeBadge extends StatelessWidget {
  final String type;

  const QrTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon, String label) = switch (type.toUpperCase()) {
      'STAGIAIRE' => (AppColors.info, Icons.school_rounded, 'Stagiaire'),
      'VISITEUR' => (AppColors.tertiary, Icons.group_rounded, 'Visiteur'),
      _ => (AppColors.outline, Icons.help_outline_rounded, type),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xxs + 1),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
        border: Border.all(color: color.withAlpha(76)),
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

class QrCard extends StatelessWidget {
  final QrCode qrCode;
  final VoidCallback onTap;

  const QrCard({super.key, required this.qrCode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  '${qrCode.proprietairePrenom?[0] ?? '?'}'
                  '${qrCode.proprietaireNom?[0] ?? ''}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      qrCode.proprietaireFullName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        QrTypeBadge(type: qrCode.typeProprietaire),
                        const SizedBox(width: Spacing.sm),
                        Text(
                          'Exp. ${qrCode.dateExpiration.day.toString().padLeft(2, '0')}/'
                          '${qrCode.dateExpiration.month.toString().padLeft(2, '0')}/'
                          '${qrCode.dateExpiration.year}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              QrStatusBadge(status: qrCode.statut),
              const SizedBox(width: Spacing.sm),
              Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
