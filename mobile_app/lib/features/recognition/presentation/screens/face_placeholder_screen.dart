import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/spacing.dart';

class FacePlaceholderScreen extends StatelessWidget {
  const FacePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reconnaissance faciale')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.xl,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.face_rounded,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: Spacing.lg),
                Text(
                  'Reconnaissance faciale',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  'Cette fonctionnalité sera bientôt disponible.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.xxl),
                SizedBox(
                  width: 280,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => context.push('/processing'),
                    child: const Text('Continuer'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
