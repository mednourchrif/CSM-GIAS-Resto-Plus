import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/spacing.dart';
import '../../../../../shared/widgets/empty_state.dart';
import '../../../../../shared/widgets/error_state.dart';
import '../../../employees/domain/entities/employee.dart';
import '../../../employees/presentation/providers/employee_provider.dart';
import '../providers/face_enrollment_provider.dart';
import 'face_enrollment_screen.dart';

/// Entry point for managing employee biometric enrollment.
///
/// Enrollment remains attached to an employee record, while this directory
/// gives the dedicated “Visages” administration section a complete workflow.
class FaceEnrollmentDirectoryScreen extends ConsumerStatefulWidget {
  const FaceEnrollmentDirectoryScreen({super.key});

  @override
  ConsumerState<FaceEnrollmentDirectoryScreen> createState() =>
      _FaceEnrollmentDirectoryScreenState();
}

class _FaceEnrollmentDirectoryScreenState
    extends ConsumerState<FaceEnrollmentDirectoryScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(employeeProvider.notifier).refresh());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => ref.read(employeeProvider.notifier).search(query.trim()),
    );
  }

  Future<void> _openEnrollment(Employee employee) async {
    ref.read(faceEnrollmentProvider.notifier).reset();
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => FaceEnrollmentScreen(employee: employee),
      ),
    );
    if (mounted) {
      await ref.read(employeeProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeeProvider);

    return RefreshIndicator(
      onRefresh: ref.read(employeeProvider.notifier).refresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: SearchBar(
                controller: _searchController,
                hintText: 'Rechercher un employé',
                leading: const Icon(Icons.search_rounded),
                trailing: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      tooltip: 'Effacer',
                      onPressed: () {
                        _searchController.clear();
                        _onSearch('');
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear_rounded),
                    ),
                ],
                onChanged: (value) {
                  _onSearch(value);
                  setState(() {});
                },
              ),
            ),
          ),
          if (state.isLoading && state.employees.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.error != null && state.employees.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: ErrorState(
                message: state.error!,
                onRetry: ref.read(employeeProvider.notifier).refresh,
              ),
            )
          else if (state.employees.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.face_retouching_off_rounded,
                title: 'Aucun employé trouvé',
                subtitle:
                    'Ajoutez d’abord un employé avant d’enregistrer son visage.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.md,
                0,
                Spacing.md,
                Spacing.xl,
              ),
              sliver: SliverList.separated(
                itemCount: state.employees.length,
                separatorBuilder: (_, _) => const SizedBox(height: Spacing.sm),
                itemBuilder: (context, index) {
                  final employee = state.employees[index];
                  return _EnrollmentTile(
                    employee: employee,
                    onTap: () => _openEnrollment(employee),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _EnrollmentTile extends StatelessWidget {
  final Employee employee;
  final VoidCallback onTap;

  const _EnrollmentTile({required this.employee, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enrolled = employee.isEnrolled;

    return Card(
      child: ListTile(
        minTileHeight: 76,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            '${employee.prenom[0]}${employee.nom[0]}',
            style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
          ),
        ),
        title: Text(
          employee.fullName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(employee.matricule),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              avatar: Icon(
                enrolled
                    ? Icons.verified_user_rounded
                    : Icons.warning_amber_rounded,
                size: 16,
              ),
              label: Text(enrolled ? 'Enrôlé' : 'À enrôler'),
            ),
            const SizedBox(width: Spacing.xs),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
        onTap: employee.isActive ? onTap : null,
      ),
    );
  }
}
