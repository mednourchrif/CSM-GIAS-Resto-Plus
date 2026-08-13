import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../shared/widgets/brand_logo.dart';
import '../../domain/enums/admin_section.dart';

/// Scrollable administration sidebar that remains safe on landscape tablets.
class AdminNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool extended;

  const AdminNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.extended = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final width = extended ? 210.0 : 76.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceContainerDark
            : const Color(0xFFF0F4F8),
        border: Border(
          right: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              extended ? Spacing.md : Spacing.sm,
              Spacing.sm,
              extended ? Spacing.md : Spacing.sm,
              Spacing.xs,
            ),
            child: Container(
              height: extended ? 54 : 44,
              width: double.infinity,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Spacing.radiusLg),
                border: Border.all(color: theme.colorScheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const FittedBox(
                child: BrandLogo(width: 128, framed: false),
              ),
            ),
          ),
          if (extended)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.xs),
              child: Text(
                '${strings.administration} Resto+',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                Spacing.xs,
                Spacing.xs,
                Spacing.xs,
                Spacing.sm,
              ),
              children: [
                _RailDestination(
                  icon: Icons.dashboard_rounded,
                  label: strings.dashboard,
                  selected: selectedIndex == 0,
                  extended: extended,
                  onTap: () => onDestinationSelected(0),
                ),
                const SizedBox(height: Spacing.xs),
                for (int index = 0; index < AdminSection.values.length; index++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: _RailDestination(
                      icon: AdminSection.values[index].icon,
                      label: strings.adminSectionLabel(
                        AdminSection.values[index].name,
                      ),
                      selected: selectedIndex == index + 1,
                      extended: extended,
                      onTap: () => onDestinationSelected(index + 1),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RailDestination extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool extended;
  final VoidCallback onTap;

  const _RailDestination({
    required this.icon,
    required this.label,
    required this.selected,
    required this.extended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = selected
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;
    final content = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Spacing.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        constraints: const BoxConstraints(minHeight: 48),
        padding: EdgeInsets.symmetric(
          horizontal: extended ? Spacing.md : Spacing.sm,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
        ),
        child: Row(
          mainAxisAlignment: extended
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Icon(icon, color: foreground, size: Spacing.iconSm),
            if (extended) ...[
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: foreground,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
    return extended ? content : Tooltip(message: label, child: content);
  }
}
