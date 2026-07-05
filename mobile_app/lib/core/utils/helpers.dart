import 'package:flutter/material.dart';
import '../theme/spacing.dart';

abstract final class AppHelpers {
  static void showSnackBar(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  static SizedBox get verticalSpacingXs => const SizedBox(height: Spacing.xs);
  static SizedBox get verticalSpacingSm => const SizedBox(height: Spacing.sm);
  static SizedBox get verticalSpacingMd => const SizedBox(height: Spacing.md);
  static SizedBox get verticalSpacingLg => const SizedBox(height: Spacing.lg);
  static SizedBox get verticalSpacingXl => const SizedBox(height: Spacing.xl);

  static SizedBox get horizontalSpacingXs => const SizedBox(width: Spacing.xs);
  static SizedBox get horizontalSpacingSm => const SizedBox(width: Spacing.sm);
  static SizedBox get horizontalSpacingMd => const SizedBox(width: Spacing.md);
  static SizedBox get horizontalSpacingLg => const SizedBox(width: Spacing.lg);

  static EdgeInsets get screenPadding => const EdgeInsets.all(Spacing.md);

  static EdgeInsets get cardPadding => const EdgeInsets.all(Spacing.md);

  static EdgeInsets formFieldPadding(
    BuildContext context, {
    double bottom = Spacing.sm,
  }) {
    return EdgeInsets.only(bottom: bottom);
  }
}
