import 'package:flutter/material.dart';
import '../../../core/theme/spacing.dart';

/// Standardized error state widget.
///
/// Use this whenever an async operation fails and the content cannot be shown.
/// Provides icon, message, and retry button.
class ErrorState extends StatelessWidget {
  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorState({
    super.key,
    required this.message,
    this.retryLabel = 'Réessayer',
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: Spacing.iconXl,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                'Une erreur est survenue',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: Spacing.xl),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(retryLabel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
