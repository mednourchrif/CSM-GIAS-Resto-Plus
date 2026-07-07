import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/spacing.dart';
import '../../../../features/home/presentation/providers/selection_providers.dart';
import '../../domain/enums/identification_method.dart';

class IdentificationMethodScreen extends ConsumerWidget {
  const IdentificationMethodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMethod = ref.watch(selectedIdentificationProvider);
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.sizeOf(context).width >= Spacing.tabletBreakpoint;

    return Scaffold(
      appBar: AppBar(title: const Text('Mode d\'identification')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Spacing.maxContentWidthMedium),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: Spacing.xl,
              ),
              child: Column(
                children: [
                  const Spacer(),
                  // Title
                  Text(
                    'Comment souhaitez-vous\nvous identifier ?',
                    style: (isDesktop
                            ? theme.textTheme.headlineSmall
                            : theme.textTheme.titleLarge)
                        ?.copyWith(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    'Choisissez votre méthode d\'identification préférée',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Spacing.xxl),

                  // Method cards — side by side on wide screens
                  if (isDesktop)
                    Row(
                      children: [
                        Expanded(
                          child: _MethodCard(
                            method: IdentificationMethod.face,
                            icon: Icons.face_rounded,
                            isSelected:
                                selectedMethod == IdentificationMethod.face,
                          ),
                        ),
                        const SizedBox(width: Spacing.md),
                        Expanded(
                          child: _MethodCard(
                            method: IdentificationMethod.qr,
                            icon: Icons.qr_code_scanner_rounded,
                            isSelected:
                                selectedMethod == IdentificationMethod.qr,
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _MethodCard(
                      method: IdentificationMethod.face,
                      icon: Icons.face_rounded,
                      isSelected:
                          selectedMethod == IdentificationMethod.face,
                    ),
                    const SizedBox(height: Spacing.md),
                    _MethodCard(
                      method: IdentificationMethod.qr,
                      icon: Icons.qr_code_scanner_rounded,
                      isSelected:
                          selectedMethod == IdentificationMethod.qr,
                    ),
                  ],

                  const Spacer(),

                  // Continue button
                  SizedBox(
                    width: 300,
                    height: Spacing.minTouchTarget + 4,
                    child: FilledButton.icon(
                      onPressed: selectedMethod != null
                          ? () {
                              final route =
                                  selectedMethod == IdentificationMethod.face
                                      ? '/face'
                                      : '/qr';
                              context.push(route);
                            }
                          : null,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Continuer'),
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Method Card ─────────────────────────────────────────────────────────────

class _MethodCard extends ConsumerWidget {
  final IdentificationMethod method;
  final IconData icon;
  final bool isSelected;

  const _MethodCard({
    required this.method,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.sizeOf(context).width >= Spacing.tabletBreakpoint;

    return AnimatedScale(
      scale: isSelected ? 1.02 : 1.0,
      duration: AppDurations.fast,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusLg),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(Spacing.radiusLg),
          child: InkWell(
            onTap: () {
              ref.read(selectedIdentificationProvider.notifier).state = method;
            },
            borderRadius: BorderRadius.circular(Spacing.radiusLg),
            splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            highlightColor: theme.colorScheme.primary.withValues(alpha: 0.05),
            child: Semantics(
              button: true,
              label: method.label,
              selected: isSelected,
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? Spacing.xl : Spacing.lg),
                child: isDesktop
                    ? _buildVertical(theme)
                    : _buildHorizontal(theme),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVertical(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _iconContainer(theme, size: 64),
        const SizedBox(height: Spacing.md),
        Text(
          method.label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Spacing.xxs),
        Text(
          method.subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        if (isSelected) ...[
          const SizedBox(height: Spacing.md),
          Icon(Icons.check_circle_rounded,
              color: theme.colorScheme.primary, size: Spacing.iconSm),
        ],
      ],
    );
  }

  Widget _buildHorizontal(ThemeData theme) {
    return Row(
      children: [
        _iconContainer(theme, size: 52),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                method.label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: Spacing.xxs),
              Text(
                method.subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (isSelected)
          Padding(
            padding: const EdgeInsets.only(left: Spacing.sm),
            child: Icon(Icons.check_circle_rounded,
                color: theme.colorScheme.primary),
          ),
      ],
    );
  }

  Widget _iconContainer(ThemeData theme, {required double size}) {
    return AnimatedContainer(
      duration: AppDurations.fast,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
      ),
      child: Icon(
        icon,
        size: size * 0.55,
        color: isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.primary,
      ),
    );
  }
}
