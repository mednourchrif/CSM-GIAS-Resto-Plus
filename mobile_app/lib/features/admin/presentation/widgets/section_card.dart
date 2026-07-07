import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../domain/enums/admin_section.dart';

/// Section card for the admin dashboard grid.
///
/// Shows a gradient icon container, section label, and description on hover.
class SectionCard extends StatefulWidget {
  final AdminSection section;
  final VoidCallback onTap;

  const SectionCard({
    super.key,
    required this.section,
    required this.onTap,
  });

  @override
  State<SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<SectionCard> {
  bool _isHovered = false;

  // Color palette for each section icon
  static const _sectionColors = [
    Color(0xFF0D6E6E), // employees — primary teal
    Color(0xFF4B6587), // interns — slate blue
    Color(0xFF7B1FA2), // visitors — purple
    Color(0xFF0277BD), // qr codes — info blue
    Color(0xFF2E7D32), // face — success green
    Color(0xFFE8683A), // meals — secondary orange
    Color(0xFF6D4C41), // statistics — warm brown
    Color(0xFF37474F), // settings — blue grey
  ];

  Color get _cardColor {
    final index = AdminSection.values.indexOf(widget.section);
    return index < _sectionColors.length
        ? _sectionColors[index]
        : AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _cardColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(Spacing.radiusLg),
          border: Border.all(
            color: _isHovered
                ? color.withValues(alpha: 0.4)
                : theme.colorScheme.outlineVariant,
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(Spacing.radiusLg),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(Spacing.radiusLg),
            splashColor: color.withValues(alpha: 0.08),
            highlightColor: color.withValues(alpha: 0.04),
            child: Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Gradient icon container
                  AnimatedContainer(
                    duration: AppDurations.fast,
                    width: _isHovered ? 56 : 52,
                    height: _isHovered ? 56 : 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color,
                          color.withValues(alpha: 0.65),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(Spacing.radiusMd),
                      boxShadow: _isHovered
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Icon(
                      widget.section.icon,
                      size: Spacing.iconMd,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm + 4),
                  Text(
                    widget.section.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _isHovered ? color : theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Spacing.xxs),
                  AnimatedOpacity(
                    duration: AppDurations.fast,
                    opacity: _isHovered ? 1.0 : 0.0,
                    child: Text(
                      'Ouvrir →',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
