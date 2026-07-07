import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';

/// Standardized status badge with icon prefix and design system colors.
///
/// Pass [customLabels] to override the defaults.
class StatusBadge extends StatelessWidget {
  final String status;
  final Map<String, _StatusConfig>? customLabels;

  const StatusBadge({super.key, required this.status, this.customLabels});

  @override
  Widget build(BuildContext context) {
    final labels = customLabels ?? _defaultLabels;
    final config = labels.entries.firstWhere(
      (e) => e.key == status.toUpperCase(),
      orElse: () => const MapEntry('_default', _StatusConfig(
        label: 'Inconnu',
        color: Colors.grey,
        icon: Icons.help_outline_rounded,
      )),
    );

    final color = config.value.color;
    final label = config.value.label;
    final icon = config.value.icon;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: AppTypography.badgeLabel.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _StatusConfig {
  final String label;
  final Color color;
  final IconData? icon;

  const _StatusConfig({
    required this.label,
    required this.color,
    this.icon,
  });
}

const Map<String, _StatusConfig> _defaultLabels = {
  'ACTIF': _StatusConfig(
    label: 'Actif',
    color: AppColors.success,
    icon: Icons.check_circle_rounded,
  ),
  'INACTIF': _StatusConfig(
    label: 'Inactif',
    color: AppColors.warning,
    icon: Icons.pause_circle_rounded,
  ),
  'SUPPRIME': _StatusConfig(
    label: 'Supprimé',
    color: AppColors.error,
    icon: Icons.cancel_rounded,
  ),
  '_default': _StatusConfig(
    label: 'Inconnu',
    color: Colors.grey,
    icon: Icons.help_outline_rounded,
  ),
};

// Convenience import — expose AppTypography from colors file location
class AppTypography {
  static TextStyle get badgeLabel => const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        height: 1.2,
      );
}
