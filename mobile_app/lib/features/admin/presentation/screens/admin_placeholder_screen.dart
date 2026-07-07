import 'package:flutter/material.dart';

import '../../../../core/theme/spacing.dart';
import '../../domain/enums/admin_section.dart';

/// Placeholder screen shown when a section is not yet implemented.
class AdminPlaceholderScreen extends StatelessWidget {
  final AdminSection section;

  const AdminPlaceholderScreen({super.key, required this.section});

  // Per-section accent colors matching SectionCard palette
  static const _sectionColors = [
    Color(0xFF0D6E6E),
    Color(0xFF4B6587),
    Color(0xFF7B1FA2),
    Color(0xFF0277BD),
    Color(0xFF2E7D32),
    Color(0xFFE8683A),
    Color(0xFF6D4C41),
    Color(0xFF37474F),
  ];

  Color _color() {
    final index = AdminSection.values.indexOf(section);
    return index < _sectionColors.length ? _sectionColors[index] : const Color(0xFF0D6E6E);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _color();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon in gradient container
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(Spacing.radiusXl),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  section.icon,
                  size: Spacing.iconXl,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: Spacing.xl),
              Text(
                section.placeholderTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                section.placeholderDescription,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.xl),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Spacing.radiusFull),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.build_circle_outlined,
                      size: Spacing.iconXs + 2,
                      color: color,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      'En cours de développement',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
