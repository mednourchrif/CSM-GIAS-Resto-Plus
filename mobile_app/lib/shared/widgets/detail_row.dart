import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/core/theme/spacing.dart';

/// A label/value row used in detail screens.
///
/// Supports clipboard copy for UUID-like fields via [copyable].
class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool copyable;
  final Widget? trailing;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.copyable = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 148,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (copyable)
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$label copié'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(Spacing.radiusXs),
              child: Padding(
                padding: const EdgeInsets.all(Spacing.xxs),
                child: Icon(
                  Icons.copy_rounded,
                  size: Spacing.iconXs,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
