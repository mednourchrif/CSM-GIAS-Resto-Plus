import 'package:flutter/material.dart';

import '../../../../core/theme/spacing.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _iconController;
  late final Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: AppDurations.slowest,
    );
    _iconScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );
    _iconController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  String _formattedDate() {
    const months = [
      '', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    const days = [
      '', 'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi',
      'samedi', 'dimanche'
    ];
    final now = DateTime.now();
    final weekday = days[now.weekday];
    final month = months[now.month];
    return '$weekday ${now.day} $month ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLarge = MediaQuery.sizeOf(context).width >= Spacing.tabletBreakpoint;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated icon
        AnimatedBuilder(
          animation: _iconScale,
          builder: (context, child) => Transform.scale(
            scale: _iconScale.value,
            child: child,
          ),
          child: Container(
            width: isLarge ? 96 : 80,
            height: isLarge ? 96 : 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.75),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(Spacing.radiusXl),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.restaurant_menu_rounded,
              size: isLarge ? 48 : 40,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: Spacing.md),

        // Brand name
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'CSM-GIAS',
              style: (isLarge
                      ? theme.textTheme.headlineMedium
                      : theme.textTheme.titleLarge)
                  ?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: Spacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.xs + 2,
                vertical: 1,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(Spacing.radiusXs),
              ),
              child: Text(
                'Resto+',
                style: (isLarge
                        ? theme.textTheme.titleSmall
                        : theme.textTheme.labelLarge)
                    ?.copyWith(
                  color: theme.colorScheme.onSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: Spacing.xl),

        // Date
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.xs,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(Spacing.radiusFull),
          ),
          child: Text(
            _formattedDate(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),

        const SizedBox(height: Spacing.md),

        // Greeting
        Text(
          _greeting(),
          style: (isLarge
                  ? theme.textTheme.headlineMedium
                  : theme.textTheme.headlineSmall)
              ?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: Spacing.xs),

        Text(
          'Veuillez sélectionner votre repas',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
