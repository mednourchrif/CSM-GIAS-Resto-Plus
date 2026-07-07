import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';
import '../providers/settings_state.dart';
import '../widgets/database_status_card.dart';
import '../widgets/maintenance_section.dart';
import '../widgets/settings_group_card.dart';
import '../widgets/version_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    ref.listen(settingsProvider, (previous, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(settingsProvider.notifier).clearSuccessMessage();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(settingsProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        actions: [
          if (state.hasUnsavedChanges)
            TextButton.icon(
              onPressed: state.isSaving ? null : () => ref.read(settingsProvider.notifier).saveChanges(),
              icon: state.isSaving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save_rounded),
              label: Text(state.isSaving ? 'Enregistrement…' : 'Enregistrer'),
            ),
        ],
      ),
      body: _buildBody(context, theme, state, ref),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme, SettingsState state, WidgetRef ref) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.settings == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(state.error!, style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => ref.read(settingsProvider.notifier).loadSettings(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.settings == null) {
      return const Center(child: Text('Aucun paramètre disponible.'));
    }

    final settings = state.settings!;

    return RefreshIndicator(
      onRefresh: () => ref.read(settingsProvider.notifier).loadSettings(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (state.hasUnsavedChanges)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: theme.colorScheme.onTertiaryContainer, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Modifications non enregistrées',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onTertiaryContainer),
                    ),
                  ),
                ],
              ),
            ),
          ...settings.groups.map((group) {
            if (group.category == 'maintenance') {
              return MaintenanceSection(
                group: group,
                onReset: () => ref.read(settingsProvider.notifier).resetToDefaults(),
                isResetting: state.isResetting,
              );
            }
            return SettingsGroupCard(
              group: group,
              pendingChanges: state.pendingChanges,
              onChanged: (key, value) => ref.read(settingsProvider.notifier).updateValue(key, value),
            );
          }),
          const SizedBox(height: 8),
          VersionCard(version: state.version, onTap: () => ref.read(settingsProvider.notifier).loadVersion()),
          const SizedBox(height: 8),
          DatabaseStatusCard(
            databaseStatus: state.databaseStatus,
            onTap: () => ref.read(settingsProvider.notifier).loadDatabaseStatus(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
