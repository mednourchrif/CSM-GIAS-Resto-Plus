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

    return Scaffold(
      appBar: AppBar(title: const Text('Choix du mode d\'identification')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.xl,
            ),
            child: Column(
              children: [
                const Spacer(),
                Text(
                  'Comment souhaitez-vous vous identifier ?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.xxl),
                _MethodCard(
                  method: IdentificationMethod.face,
                  icon: Icons.face_rounded,
                  isSelected: selectedMethod == IdentificationMethod.face,
                ),
                const SizedBox(height: Spacing.md),
                _MethodCard(
                  method: IdentificationMethod.qr,
                  icon: Icons.qr_code_scanner_rounded,
                  isSelected: selectedMethod == IdentificationMethod.qr,
                ),
                const Spacer(),
                SizedBox(
                  width: 280,
                  height: 52,
                  child: FilledButton(
                    onPressed:
                        selectedMethod != null
                            ? () {
                              final route = selectedMethod == IdentificationMethod.face
                                  ? '/face'
                                  : '/qr';
                              context.push(route);
                            }
                            : null,
                    child: const Text('Continuer'),
                  ),
                ),
                const SizedBox(height: Spacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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

    final bgColor = isSelected
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surface;
    final borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;
    final elevation = isSelected ? 4.0 : 2.0;

    return AnimatedScale(
      scale: isSelected ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: elevation,
          color: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.radiusLg),
            side: BorderSide(color: borderColor, width: isSelected ? 2 : 1),
          ),
          child: InkWell(
            onTap: () {
              ref.read(selectedIdentificationProvider.notifier).state = method;
            },
            borderRadius: BorderRadius.circular(Spacing.radiusLg),
            hoverColor: theme.colorScheme.primaryContainer.withAlpha(60),
            child: Semantics(
              button: true,
              label: method.label,
              selected: isSelected,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: Spacing.xl,
                  horizontal: Spacing.lg,
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 40, color: theme.colorScheme.primary),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            method.label,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: Spacing.xxs),
                          Text(
                            method.subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle_rounded,
                        color: theme.colorScheme.primary,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
