import 'package:flutter/material.dart';
import '../../../../../core/localization/app_strings.dart';

import '../../domain/entities/setting.dart';

class MaintenanceSection extends StatelessWidget {
  final SettingsGroup group;
  final VoidCallback onReset;
  final bool isResetting;
  final Future<void> Function({
    required String password,
    required String confirmation,
    required bool purgeAuditLogs,
  })? onPurge;
  final bool isPurging;

  const MaintenanceSection({
    super.key,
    required this.group,
    required this.onReset,
    this.isResetting = false,
    this.onPurge,
    this.isPurging = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.build_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  strings.settingsGroupLabel(group.category, group.label),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _ActionTile(
              icon: Icons.restart_alt_rounded,
              title: strings.resetSettings,
              subtitle: strings.restoreDefaults,
              loading: isResetting,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(strings.reset),
                    content: Text(strings.resetConfirmation),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(strings.cancel),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          onReset();
                        },
                        child: Text(strings.reset),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(height: 8),
            _ActionTile(
              icon: Icons.delete_sweep_rounded,
              title: strings.clearCache,
              subtitle: strings.clearTemporaryFiles,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(strings.cacheCleared),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            if (onPurge != null) ...[
              const Divider(height: 8),
              _ActionTile(
                icon: Icons.delete_forever_rounded,
                iconColor: theme.colorScheme.error,
                title: strings.purgeDatabase,
                subtitle: strings.purgeDatabaseSubtitle,
                loading: isPurging,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => _PurgeDatabaseDialog(
                      onConfirm: (password, confirmation, purgeAuditLogs) {
                        onPurge!(
                          password: password,
                          confirmation: confirmation,
                          purgeAuditLogs: purgeAuditLogs,
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PurgeDatabaseDialog extends StatefulWidget {
  final void Function(
    String password,
    String confirmation,
    bool purgeAuditLogs,
  ) onConfirm;

  const _PurgeDatabaseDialog({required this.onConfirm});

  @override
  State<_PurgeDatabaseDialog> createState() => _PurgeDatabaseDialogState();
}

class _PurgeDatabaseDialogState extends State<_PurgeDatabaseDialog> {
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _purgeAuditLogs = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _confirmationController.text.trim() == 'PURGER' &&
      _passwordController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          Expanded(child: Text(strings.purgeDialogTitle)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
              ),
              child: Text(
                strings.purgeDialogWarning,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: _purgeAuditLogs,
              title: Text(strings.purgeIncludeAuditLogsLabel),
              onChanged: (val) {
                setState(() {
                  _purgeAuditLogs = val ?? false;
                });
              },
            ),
            const SizedBox(height: 12),
            Text(
              strings.purgeTypeConfirmInstruction,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _confirmationController,
              decoration: const InputDecoration(
                hintText: 'PURGER',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Text(
              strings.purgePasswordLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: _isValid
              ? () {
                  final pwd = _passwordController.text;
                  final conf = _confirmationController.text.trim();
                  final purgeLogs = _purgeAuditLogs;
                  Navigator.of(context).pop();
                  widget.onConfirm(pwd, conf, purgeLogs);
                }
              : null,
          child: Text(strings.purgeConfirmButton),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final bool loading;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    this.iconColor,
    required this.title,
    required this.subtitle,
    this.loading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: iconColor ?? Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (loading)
              const Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
