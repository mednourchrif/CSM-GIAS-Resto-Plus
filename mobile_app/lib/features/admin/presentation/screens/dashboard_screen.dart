import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/spacing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../identification/presentation/providers/kiosk_flow_provider.dart';
import '../../../admin/employees/presentation/screens/employee_list_screen.dart';
import '../../../admin/face_enrollment/presentation/screens/face_enrollment_directory_screen.dart';
import '../../../admin/reports/presentation/screens/report_screen.dart';
import '../../domain/enums/admin_section.dart';
import '../../../admin/interns/presentation/screens/intern_list_screen.dart';
import '../../../admin/meals/presentation/screens/meal_history_list_screen.dart';
import '../../../admin/qr/presentation/screens/qr_list_screen.dart';
import '../../../admin/statistics/presentation/screens/statistics_dashboard_screen.dart';
import '../../../admin/settings/presentation/screens/settings_screen.dart';
import '../../../admin/users/presentation/screens/user_list_screen.dart';
import '../../../admin/visitors/presentation/screens/visitor_list_screen.dart';
import '../../audit/presentation/screens/audit_log_list_screen.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/admin_navigation_rail.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = -1;

  void _onDestinationSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _onLogout() async {
    ref.read(resetKioskFlowProvider)();
    await ref.read(authStateProvider.notifier).logout();
    if (!mounted) return;
    context.go('/login');
  }

  bool get _isOnDashboard => _selectedIndex == -1;

  String get _currentTitle {
    if (_isOnDashboard) return 'Tableau de bord';
    return AdminSection.values[_selectedIndex].label;
  }

  Widget get _body {
    if (_isOnDashboard) {
      return StatisticsDashboardScreen(
        onSectionTap: (index) => setState(() => _selectedIndex = index),
      );
    }
    return switch (AdminSection.values[_selectedIndex]) {
      AdminSection.employees => const EmployeeListScreen(),
      AdminSection.interns => const InternListScreen(),
      AdminSection.visitors => const VisitorListScreen(),
      AdminSection.qrCodes => const QrListScreen(),
      AdminSection.faceEnrollment => const FaceEnrollmentDirectoryScreen(),
      AdminSection.mealHistory => const MealHistoryListScreen(),
      AdminSection.statistics => const StatisticsDashboardScreen(),
      AdminSection.reports => const ReportScreen(),
      AdminSection.users => const UserListScreen(),
      AdminSection.settings => const SettingsScreen(),
      AdminSection.audit => const AuditLogListScreen(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= Spacing.tabletBreakpoint;

    final adminName = authState.user?.fullName ?? 'Administrateur';

    if (!isDesktop) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_currentTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Déconnexion',
              onPressed: _onLogout,
            ),
          ],
        ),
        drawer: AdminDrawer(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onDestinationSelected,
          onLogout: _onLogout,
        ),
        body: _body,
      );
    }

    // ── Tablet / Desktop layout with navigation rail ─────────────────────────
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminNavigationRail(
              selectedIndex: _selectedIndex + 1,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index - 1);
              },
              extended: screenWidth >= Spacing.desktopBreakpoint,
            ),

            Expanded(
              child: Column(
                children: [
                  // ── Top bar ──────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.lg,
                      vertical: Spacing.sm + 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Breadcrumb
                        if (!_isOnDashboard) ...[
                          InkWell(
                            onTap: () => setState(() => _selectedIndex = -1),
                            borderRadius: BorderRadius.circular(
                              Spacing.radiusXs,
                            ),
                            child: Text(
                              'Tableau de bord',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.xs,
                            ),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              size: Spacing.iconXs + 2,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        Expanded(
                          child: Text(
                            _currentTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Admin info
                        Icon(
                          Icons.account_circle_rounded,
                          size: Spacing.iconSm,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: Spacing.xs),
                        Text(
                          adminName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: Spacing.md),
                        FilledButton.tonal(
                          onPressed: _onLogout,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 36),
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.md,
                              vertical: Spacing.xs,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.logout_rounded, size: 16),
                              SizedBox(width: Spacing.xs),
                              Text('Déconnexion'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Body ─────────────────────────────────────────────────
                  Expanded(
                    child: isDesktop
                        ? Padding(
                            padding: const EdgeInsets.all(Spacing.lg),
                            child: _body,
                          )
                        : _body,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
