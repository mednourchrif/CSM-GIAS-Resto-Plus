import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';

class BrandLogo extends StatelessWidget {
  final double width;
  final bool framed;
  final bool showRestoBadge;

  const BrandLogo({
    super.key,
    this.width = 210,
    this.framed = true,
    this.showRestoBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final logo = Semantics(
      image: true,
      label: 'CSM-GIAS Ingrédients',
      child: Image.asset(
        'assets/branding/csm-gias.png',
        width: width,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (framed)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Spacing.radiusLg),
              border: Border.all(color: const Color(0xFFDDE6ED)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: logo,
          )
        else
          logo,
        if (showRestoBadge) ...[
          const SizedBox(height: Spacing.sm),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.warmGradient,
              borderRadius: BorderRadius.circular(Spacing.radiusFull),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.xs,
              ),
              child: Text(
                'RESTO+',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
