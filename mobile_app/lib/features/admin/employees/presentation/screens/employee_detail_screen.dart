import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/spacing.dart';
import '../../../../../shared/widgets/app_dialog.dart';
import '../../../../../shared/widgets/detail_row.dart';
import '../../../../../shared/widgets/error_state.dart';
import '../../../../../shared/widgets/shimmer_loading.dart';
import '../../../../admin/face_enrollment/presentation/providers/face_enrollment_provider.dart';
import '../../../../admin/face_enrollment/presentation/screens/face_enrollment_screen.dart';
import '../../domain/entities/employee_detail.dart';
import '../providers/employee_provider.dart';
import '../widgets/employee_status_badge.dart';
import 'employee_form_screen.dart';

class EmployeeDetailScreen extends ConsumerWidget {
  final String uuid;

  const EmployeeDetailScreen({super.key, required this.uuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDetail = ref.watch(employeeDetailProvider(uuid));

    return asyncDetail.when(
      loading: () => _buildScaffold(context, const _LoadingBody()),
      error: (err, _) => _buildScaffold(
        context,
        ErrorState(
          message: err.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.invalidate(employeeDetailProvider(uuid)),
        ),
      ),
      data: (detail) => _buildScaffold(
        context,
        _DetailBody(detail: detail),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, Widget body) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails employé'),
      ),
      body: body,
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            const ShimmerCard(),
            const SizedBox(height: Spacing.md),
            const ShimmerCard(),
            const SizedBox(height: Spacing.md),
            const ShimmerCard(),
            const SizedBox(height: Spacing.md),
            const ShimmerCard(),
          ],
        ),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  final EmployeeDetail detail;

  const _DetailBody({required this.detail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emp = detail.employee;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeaderSection(employee: emp),
            const SizedBox(height: Spacing.lg),
            _PersonalInfoSection(employee: emp),
            const SizedBox(height: Spacing.lg),
            _TodayMealSection(detail: detail),
            const SizedBox(height: Spacing.lg),
            _IdentificationSection(detail: detail),
            const SizedBox(height: Spacing.lg),
            _MealHistorySection(detail: detail),
            const SizedBox(height: Spacing.lg),
            _AdminActionsSection(detail: detail),
            const SizedBox(height: Spacing.xxxl),
          ],
        ),
      ),
    );
  }
}

// ─── Header ─────────────────────────────────────────────────────────────────

class _HeaderSection extends StatelessWidget {
  final dynamic employee;

  const _HeaderSection({required this.employee});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = '${employee.prenom.isNotEmpty ? employee.prenom[0] : '?'}'
        '${employee.nom.isNotEmpty ? employee.nom[0] : '?'}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                initials,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
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
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              employee.uuid,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
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
            const SizedBox(height: Spacing.sm),
            Text(
              'Employé',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Personal Information ───────────────────────────────────────────────────

class _PersonalInfoSection extends StatelessWidget {
  final dynamic employee;

  const _PersonalInfoSection({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_rounded, size: Spacing.iconSm, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: Spacing.sm),
                Text(
                  'Informations personnelles',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            DetailRow(label: 'Nom', value: employee.nom),
            DetailRow(label: 'Prénom', value: employee.prenom),
            DetailRow(label: 'Email', value: employee.email ?? 'Non renseigné'),
            DetailRow(label: 'Matricule', value: employee.matricule),
            DetailRow(label: 'Date de création', value: _formatDate(employee.createdAt)),
            DetailRow(label: 'Dernière modification', value: _formatDate(employee.updatedAt)),
          ],
        ),
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

// ─── Today's Meal ───────────────────────────────────────────────────────────

class _TodayMealSection extends ConsumerWidget {
  final EmployeeDetail detail;

  const _TodayMealSection({required this.detail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hasMeal = detail.hasTodayMeal;
    final meal = detail.todayMeal;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant_rounded, size: Spacing.iconSm, color: theme.colorScheme.primary),
                const SizedBox(width: Spacing.sm),
                Text(
                  'Repas du jour',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Icon(
                  hasMeal ? Icons.check_circle_rounded : Icons.schedule_rounded,
                  size: Spacing.iconSm,
                  color: hasMeal ? const Color(0xFF1B8A1B) : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  detail.mealStatus,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: hasMeal ? const Color(0xFF1B8A1B) : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (hasMeal && meal != null) ...[
              const SizedBox(height: Spacing.sm),
              DetailRow(label: 'Catégorie', value: meal.categorieNom),
              DetailRow(label: 'Méthode', value: _methodLabel(meal.typeIdentification)),
              DetailRow(label: 'Heure', value: _formatTime(meal.heureRepas)),
            ],
          ],
        ),
      ),
    );
  }

  String _methodLabel(String method) {
    return switch (method.toUpperCase()) {
      'FACE' => 'Reconnaissance faciale',
      'QR' => 'QR Code',
      _ => method,
    };
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ─── Identification Methods ─────────────────────────────────────────────────

class _IdentificationSection extends ConsumerWidget {
  final EmployeeDetail detail;

  const _IdentificationSection({required this.detail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final emp = detail.employee;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.fingerprint_rounded, size: Spacing.iconSm, color: theme.colorScheme.primary),
            const SizedBox(width: Spacing.sm),
            Text(
              'Identification',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: Spacing.md),
        _IdMethodCard(
          icon: Icons.qr_code_rounded,
          title: 'QR Code',
          statusLabel: detail.qrGenerated ? 'Généré' : 'Non généré',
          statusColor: detail.qrGenerated ? const Color(0xFF1B8A1B) : theme.colorScheme.onSurfaceVariant,
          actions: [
            _disabledAction('Voir', Icons.visibility_rounded),
            _disabledAction('Télécharger', Icons.download_rounded),
            _disabledAction('Imprimer', Icons.print_rounded),
            _disabledAction('Régénérer', Icons.refresh_rounded),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        _IdMethodCard(
          icon: Icons.face_rounded,
          title: 'Reconnaissance faciale',
          statusLabel: detail.faceEnrolled ? 'Enrolé' : 'Non enrolé',
          statusColor: detail.faceEnrolled ? const Color(0xFF1B8A1B) : theme.colorScheme.onSurfaceVariant,
          actions: [
            if (detail.faceEnrolled)
              _enabledAction('Ré-enrôler', Icons.face_retouching_natural_rounded, () {
                ref.read(faceEnrollmentProvider.notifier).reset();
                Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => FaceEnrollmentScreen(
                      employee: emp,
                    ),
                  ),
                ).then((enrolled) {
                  if (enrolled == true && context.mounted) {
                    ref.invalidate(employeeDetailProvider(detail.employee.uuid));
                    ref.read(employeeProvider.notifier).refresh();
                  }
                });
              })
            else
              _enabledAction('Enrôler', Icons.face_retouching_natural_rounded, () {
                ref.read(faceEnrollmentProvider.notifier).reset();
                Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => FaceEnrollmentScreen(
                      employee: emp,
                    ),
                  ),
                ).then((enrolled) {
                  if (enrolled == true && context.mounted) {
                    ref.invalidate(employeeDetailProvider(detail.employee.uuid));
                    ref.read(employeeProvider.notifier).refresh();
                  }
                });
              }),
            if (detail.faceEnrolled)
              _enabledAction('Supprimer', Icons.delete_rounded, () async {
                final confirmed = await showConfirmDangerDialog(
                  context: context,
                  title: 'Supprimer le visage',
                  message: 'Êtes-vous sûr de vouloir supprimer la reconnaissance faciale de ${emp.fullName} ?',
                  confirmLabel: 'Supprimer',
                );
                if (confirmed == true && context.mounted) {
                  ref.invalidate(employeeDetailProvider(detail.employee.uuid));
                  ref.read(employeeProvider.notifier).refresh();
                }
              }),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        _IdMethodCard(
          icon: Icons.fingerprint_rounded,
          title: 'Empreinte digitale',
          statusLabel: 'Bientôt disponible',
          statusColor: theme.colorScheme.onSurfaceVariant,
          actions: [
            _disabledAction('Enrôler', Icons.fingerprint),
            _disabledAction('Supprimer', Icons.delete_rounded),
          ],
          showComingSoon: true,
        ),
      ],
    );
  }

  OutlinedButton _disabledAction(String label, IconData icon) {
    return OutlinedButton.icon(
      onPressed: null,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
        minimumSize: Size.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  OutlinedButton _enabledAction(String label, IconData icon, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
        minimumSize: Size.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _IdMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String statusLabel;
  final Color statusColor;
  final List<Widget> actions;
  final bool showComingSoon;

  const _IdMethodCard({
    required this.icon,
    required this.title,
    required this.statusLabel,
    required this.statusColor,
    required this.actions,
    this.showComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: Spacing.iconSm, color: theme.colorScheme.primary),
                const SizedBox(width: Spacing.sm),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xxs),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(Spacing.radiusSm),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            if (showComingSoon) ...[
              const SizedBox(height: Spacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.construction_rounded, size: 14, color: theme.colorScheme.onTertiaryContainer),
                    const SizedBox(width: Spacing.xxs + 1),
                    Text(
                      'Module en cours de développement',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: Spacing.sm),
            Wrap(
              spacing: Spacing.xs,
              runSpacing: Spacing.xs,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Meal History ───────────────────────────────────────────────────────────

class _MealHistorySection extends ConsumerWidget {
  final EmployeeDetail detail;

  const _MealHistorySection({required this.detail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final meals = detail.lastMeals;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history_rounded, size: Spacing.iconSm, color: theme.colorScheme.primary),
                const SizedBox(width: Spacing.sm),
                Text(
                  'Derniers repas',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            if (meals.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: Spacing.sm),
                    Text(
                      'Aucun repas enregistré.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              ...meals.map((meal) => Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.sm),
                    child: _MealHistoryCard(meal: meal),
                  )),
            ],
            const SizedBox(height: Spacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Historique complet à venir.')),
                  );
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('Voir l\'historique complet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealHistoryCard extends StatelessWidget {
  final dynamic meal;

  const _MealHistoryCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final methodLabel = switch (meal.typeIdentification.toUpperCase()) {
      'FACE' => 'Reconnaissance faciale',
      'QR' => 'QR Code',
      _ => meal.typeIdentification,
    };

    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
      ),
      child: Row(
        children: [
          Icon(Icons.restaurant_rounded, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.categorieNom,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatDate(meal.dateRepas)} à ${_formatTime(meal.heureRepas)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            methodLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ─── Admin Actions ──────────────────────────────────────────────────────────

class _AdminActionsSection extends ConsumerWidget {
  final EmployeeDetail detail;

  const _AdminActionsSection({required this.detail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final emp = detail.employee;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.admin_panel_settings_rounded, size: Spacing.iconSm, color: theme.colorScheme.primary),
            const SizedBox(width: Spacing.sm),
            Text(
              'Actions',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: Spacing.md),
        FilledButton.icon(
          onPressed: () => _showEditDialog(context, ref),
          icon: const Icon(Icons.edit_rounded),
          label: const Text('Modifier l\'employé'),
        ),
        const SizedBox(height: Spacing.sm),
        if (emp.isActive)
          OutlinedButton.icon(
            onPressed: () => _confirmDeactivate(context, ref),
            icon: const Icon(Icons.pause_circle_rounded),
            label: const Text('Désactiver l\'employé'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.warning,
            ),
          )
        else
          OutlinedButton.icon(
            onPressed: () => _confirmActivate(context, ref),
            icon: const Icon(Icons.check_circle_rounded),
            label: const Text('Activer l\'employé'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1B8A1B),
            ),
          ),
        const SizedBox(height: Spacing.sm),
        OutlinedButton.icon(
          onPressed: () => _confirmDelete(context, ref),
          icon: const Icon(Icons.delete_rounded),
          label: const Text('Supprimer l\'employé'),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
          ),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => EmployeeFormScreen(employee: detail.employee),
    ).then((_) {
      if (context.mounted) {
        ref.invalidate(employeeDetailProvider(detail.employee.uuid));
      }
    });
  }

  void _confirmDeactivate(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDangerDialog(
      context: context,
      title: 'Désactiver l\'employé',
      message: 'Êtes-vous sûr de vouloir désactiver ${detail.employee.fullName} ?',
      confirmLabel: 'Désactiver',
    );
    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(employeeProvider.notifier)
          .updateEmployee(detail.employee.uuid, statut: 'INACTIF');
      if (success && context.mounted) {
        ref.invalidate(employeeDetailProvider(detail.employee.uuid));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employé désactivé.')),
        );
      }
    }
  }

  void _confirmActivate(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDangerDialog(
      context: context,
      title: 'Activer l\'employé',
      message: 'Êtes-vous sûr de vouloir activer ${detail.employee.fullName} ?',
      confirmLabel: 'Activer',
    );
    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(employeeProvider.notifier)
          .updateEmployee(detail.employee.uuid, statut: 'ACTIF');
      if (success && context.mounted) {
        ref.invalidate(employeeDetailProvider(detail.employee.uuid));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employé activé.')),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDangerDialog(
      context: context,
      title: 'Supprimer l\'employé',
      message: 'Êtes-vous sûr de vouloir supprimer ${detail.employee.fullName} ?\n\nCette action est réversible.',
      confirmLabel: 'Supprimer',
    );
    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(employeeProvider.notifier)
          .deleteEmployee(detail.employee.uuid);
      if (success && context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employé supprimé.')),
        );
      }
    }
  }
}
