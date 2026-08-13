import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../shared/widgets/brand_logo.dart';

class HomeHeader extends StatelessWidget {
  final String subtitle;
  final bool compact;

  const HomeHeader({super.key, this.subtitle = '', this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);
    final size = MediaQuery.sizeOf(context);
    final dense = compact || size.height < 620;
    final large = size.width >= Spacing.tabletBreakpoint;
    final headerSubtitle = subtitle.isEmpty ? strings.faceOrQrPrompt : subtitle;

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
            strings.greeting(DateTime.now()),
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
            headerSubtitle,
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
                strings.formattedDate(DateTime.now()),
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
