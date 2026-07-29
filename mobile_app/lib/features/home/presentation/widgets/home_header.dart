import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../shared/widgets/brand_logo.dart';

class HomeHeader extends StatelessWidget {
  final String subtitle;
  final bool compact;

  const HomeHeader({
    super.key,
    this.subtitle = 'Présentez votre visage ou votre QR code',
    this.compact = false,
  });

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  String _formattedDate() {
    const months = [
      '',
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    const days = [
      '',
      'lundi',
      'mardi',
      'mercredi',
      'jeudi',
      'vendredi',
      'samedi',
      'dimanche',
    ];
    final now = DateTime.now();
    return '${days[now.weekday]} ${now.day} ${months[now.month]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final dense = compact || size.height < 620;
    final large = size.width >= Spacing.tabletBreakpoint;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BrandLogo(
            width: dense
                ? 150
                : large
                ? 210
                : 180,
            showRestoBadge: true,
          ),
          SizedBox(height: dense ? Spacing.md : Spacing.lg),
          Container(
            width: dense ? 96 : 132,
            height: 4,
            decoration: BoxDecoration(
              gradient: AppColors.brandRibbonGradient,
              borderRadius: BorderRadius.circular(Spacing.radiusFull),
            ),
          ),
          SizedBox(height: dense ? Spacing.md : Spacing.lg),
          Text(
            _greeting(),
            textAlign: TextAlign.center,
            style:
                (large
                        ? theme.textTheme.headlineMedium
                        : theme.textTheme.headlineSmall)
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                      letterSpacing: -0.4,
                    ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (!dense) ...[
            const SizedBox(height: Spacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.xs,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.65,
                ),
                borderRadius: BorderRadius.circular(Spacing.radiusFull),
              ),
              child: Text(
                _formattedDate(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
