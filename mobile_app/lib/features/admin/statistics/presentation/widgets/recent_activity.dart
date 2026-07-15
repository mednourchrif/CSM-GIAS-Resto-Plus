import 'package:flutter/material.dart';

import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/spacing.dart';
import '../../domain/entities/dashboard_stats.dart';

class RecentActivityWidget extends StatelessWidget {
  final List<RecentRegistrationItem> items;
  const RecentActivityWidget({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text('Aucune activité récente',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
      itemBuilder: (context, index) {
        final item = items[index];
        final theme = Theme.of(context);
        final isFace = item.typeIdentification == 'FACE';
        final methodColor = isFace ? AppColors.success : AppColors.info;
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Spacing.xs,
            vertical: Spacing.xxs,
          ),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: methodColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
            ),
            child: Icon(
              isFace ? Icons.face_rounded : Icons.qr_code_rounded,
              size: Spacing.iconSm,
              color: methodColor,
            ),
          ),
          title: Text(
            item.displayName.isNotEmpty ? item.displayName : item.utilisateurUuid,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${item.categorieNom ?? "Repas"} • ${item.heureRepas.length >= 19 ? item.heureRepas.substring(11, 19) : item.heureRepas}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.xs + 2,
              vertical: Spacing.xxs + 1,
            ),
            decoration: BoxDecoration(
              color: methodColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
              border: Border.all(color: methodColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              isFace ? 'Visage' : 'QR',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: methodColor,
              ),
            ),
          ),
        );
      },
    );
  }
}
