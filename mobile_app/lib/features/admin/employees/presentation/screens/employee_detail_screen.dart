import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/spacing.dart';
import '../../../../admin/face_enrollment/presentation/providers/face_enrollment_provider.dart';
import '../../../../admin/face_enrollment/presentation/screens/face_enrollment_screen.dart';
import '../../domain/entities/employee.dart';
import '../providers/employee_provider.dart';
import '../widgets/employee_status_badge.dart';
import 'employee_form_screen.dart';

class EmployeeDetailScreen extends ConsumerWidget {
  final Employee employee;

  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(employee.fullName),
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
                        '${employee.prenom[0]}${employee.nom[0]}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    Text(
                      employee.fullName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        EmployeeStatusBadge(status: employee.statut),
                        const SizedBox(width: Spacing.sm),
                        EmployeeStatusBadge(status: employee.statutEnrolement),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.xxl),
              _DetailRow(label: 'Matricule', value: employee.matricule),
              _DetailRow(label: 'UUID', value: employee.uuid),
              _DetailRow(
                label: 'Date de création',
                value: _formatDate(employee.createdAt),
              ),
              _DetailRow(
                label: 'Dernière modification',
                value: _formatDate(employee.updatedAt),
              ),
              if (employee.dateEnrolement != null)
                _DetailRow(
                  label: 'Date d\'enrôlement',
                  value: _formatDate(employee.dateEnrolement!),
                ),
              if (employee.dateSuppression != null)
                _DetailRow(
                  label: 'Date de suppression',
                  value: _formatDate(employee.dateSuppression!),
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
              const SizedBox(height: Spacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openFaceEnrollment(context, ref),
                  icon: Icon(
                    employee.isEnrolled
                        ? Icons.face_rounded
                        : Icons.face_retouching_natural_rounded,
                  ),
                  label: Text(
                    employee.isEnrolled
                        ? 'Mettre à jour le visage'
                        : 'Enrôler le visage',
                  ),
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
      builder: (_) => EmployeeFormScreen(employee: employee),
    );
  }

  void _openFaceEnrollment(BuildContext context, WidgetRef ref) {
    ref.read(faceEnrollmentProvider.notifier).reset();
    Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FaceEnrollmentScreen(employee: employee),
      ),
    ).then((enrolled) {
      if (enrolled == true && context.mounted) {
        ref.read(employeeProvider.notifier).refresh();
      }
    });
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ${employee.fullName} ?',
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
                  .read(employeeProvider.notifier)
                  .deleteEmployee(employee.uuid);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Employé supprimé.')),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ref.read(employeeProvider).error ?? 'Erreur lors de la suppression.',
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

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} ${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
