import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/spacing.dart';
import '../../../../../shared/widgets/detail_row.dart';
import '../../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/intern.dart';
import '../providers/intern_provider.dart';
import 'intern_form_screen.dart';

class InternDetailScreen extends ConsumerWidget {
  final Intern intern;

  const InternDetailScreen({super.key, required this.intern});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(intern.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Modifier',
            onPressed: () => _showEditDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded),
            tooltip: 'Supprimer',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        '${intern.prenom[0]}${intern.nom[0]}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    Text(
                      intern.fullName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    StatusBadge(status: intern.statut),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.xxl),
              DetailRow(label: 'Matricule', value: intern.matricule),
              DetailRow(label: 'UUID', value: intern.uuid),
              DetailRow(
                label: 'Début de stage',
                value: '${intern.dateDebutStage.day.toString().padLeft(2, '0')}/'
                    '${intern.dateDebutStage.month.toString().padLeft(2, '0')}/'
                    '${intern.dateDebutStage.year}',
              ),
              DetailRow(
                label: 'Fin de stage',
                value: '${intern.dateFinStage.day.toString().padLeft(2, '0')}/'
                    '${intern.dateFinStage.month.toString().padLeft(2, '0')}/'
                    '${intern.dateFinStage.year}',
              ),
              if (intern.createdAt != null)
                DetailRow(
                  label: 'Date de création',
                  value: _formatDateTime(intern.createdAt!),
                ),
              if (intern.updatedAt != null)
                DetailRow(
                  label: 'Dernière modification',
                  value: _formatDateTime(intern.updatedAt!),
                ),
              const SizedBox(height: Spacing.xxl),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _showEditDialog(context, ref),
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Modifier'),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmDelete(context, ref),
                      icon: const Icon(Icons.delete_rounded),
                      label: const Text('Supprimer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Génération de QR code à venir.')),
                    );
                  },
                  icon: const Icon(Icons.qr_code_rounded),
                  label: const Text('Générer un QR code'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => InternFormScreen(intern: intern),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ${intern.fullName} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await ref
                  .read(internProvider.notifier)
                  .deleteIntern(intern.uuid);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Stagiaire supprimé.')),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ref.read(internProvider).error ?? 'Erreur lors de la suppression.',
                      ),
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} ${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
