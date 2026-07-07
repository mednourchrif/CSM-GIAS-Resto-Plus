import 'package:flutter/material.dart';
import '../../../core/theme/spacing.dart';

/// Standardized application dialog.
///
/// Wraps [AlertDialog] with consistent padding, max-width constraint,
/// optional loading overlay, and design system styling.
class AppDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;
  final bool isLoading;
  final IconData? titleIcon;
  final Color? titleIconColor;

  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.isLoading = false,
    this.titleIcon,
    this.titleIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.lg,
            Spacing.lg,
            Spacing.sm,
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.sm,
            Spacing.lg,
            Spacing.md,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            Spacing.md,
            0,
            Spacing.md,
            Spacing.md,
          ),
          title: Row(
            children: [
              if (titleIcon != null) ...[
                Container(
                  padding: const EdgeInsets.all(Spacing.xs),
                  decoration: BoxDecoration(
                    color: (titleIconColor ?? theme.colorScheme.primary)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(Spacing.radiusSm),
                  ),
                  child: Icon(
                    titleIcon,
                    size: Spacing.iconSm,
                    color: titleIconColor ?? theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
              ],
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Spacing.maxContentWidthNarrow),
            child: content,
          ),
          actions: actions,
        ),
        if (isLoading)
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(Spacing.radiusXl),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Shows a danger confirmation dialog with a red action button.
Future<bool?> showConfirmDangerDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirmer',
  String cancelLabel = 'Annuler',
  IconData icon = Icons.warning_amber_rounded,
}) {
  final theme = Theme.of(context);
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AppDialog(
      title: title,
      titleIcon: icon,
      titleIconColor: theme.colorScheme.error,
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}

/// Shows a success confirmation dialog.
Future<void> showSuccessDialog({
  required BuildContext context,
  required String title,
  required String message,
  String closeLabel = 'Fermer',
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AppDialog(
      title: title,
      titleIcon: Icons.check_circle_rounded,
      titleIconColor: const Color(0xFF1B8A1B),
      content: Text(message),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(closeLabel),
        ),
      ],
    ),
  );
}
