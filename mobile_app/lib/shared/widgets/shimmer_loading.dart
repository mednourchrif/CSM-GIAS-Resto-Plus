import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';

/// Shimmer loading placeholder widgets.
///
/// Use these instead of `CircularProgressIndicator` for content that will
/// eventually populate a known layout.
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = Spacing.radiusSm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase,
      highlightColor:
          isDark ? AppColors.shimmerHighlightDark : AppColors.shimmerHighlight,
      period: AppDurations.shimmerCycle,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// A shimmer placeholder shaped like a card.
class ShimmerCard extends StatelessWidget {
  final double height;

  const ShimmerCard({super.key, this.height = 80});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase,
      highlightColor:
          isDark ? AppColors.shimmerHighlightDark : AppColors.shimmerHighlight,
      period: AppDurations.shimmerCycle,
      child: Container(
        height: height,
        margin: const EdgeInsets.only(bottom: Spacing.sm),
        decoration: BoxDecoration(
          color: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
        ),
        padding: const EdgeInsets.all(Spacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Spacing.radiusMd),
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Spacing.radiusXs),
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Container(
                    height: 12,
                    width: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Spacing.radiusXs),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A vertical list of shimmer card placeholders.
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const ShimmerList({super.key, this.itemCount = 6, this.itemHeight = 80});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (_, __) => ShimmerCard(height: itemHeight),
    );
  }
}

/// A shimmer placeholder shaped like a data table for desktop layouts.
class ShimmerDataTable extends StatelessWidget {
  final int rowCount;

  const ShimmerDataTable({super.key, this.rowCount = 8});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase,
      highlightColor:
          isDark ? AppColors.shimmerHighlightDark : AppColors.shimmerHighlight,
      period: AppDurations.shimmerCycle,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          children: [
            // Header
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(Spacing.radiusMd),
                ),
              ),
            ),
            // Rows
            for (int i = 0; i < rowCount; i++)
              Container(
                height: 52,
                margin: const EdgeInsets.only(top: 1),
                color: Colors.white.withValues(alpha: i.isEven ? 1.0 : 0.7),
              ),
          ],
        ),
      ),
    );
  }
}

/// A shimmer placeholder for stat cards in the dashboard.
class ShimmerStatGrid extends StatelessWidget {
  final int count;

  const ShimmerStatGrid({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase,
      highlightColor:
          isDark ? AppColors.shimmerHighlightDark : AppColors.shimmerHighlight,
      period: AppDurations.shimmerCycle,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 900 ? 5 : 3;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.6,
              crossAxisSpacing: Spacing.sm,
              mainAxisSpacing: Spacing.sm,
            ),
            itemCount: count,
            itemBuilder: (_, __) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Spacing.radiusMd),
              ),
            ),
          );
        },
      ),
    );
  }
}
