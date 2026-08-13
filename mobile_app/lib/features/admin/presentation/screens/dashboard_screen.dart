import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/spacing.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../identification/presentation/providers/kiosk_flow_provider.dart';
import '../../../admin/employees/presentation/screens/employee_list_screen.dart';
import '../../../admin/face_enrollment/presentation/screens/face_enrollment_directory_screen.dart';
import '../../../admin/reports/presentation/screens/report_screen.dart';
import '../../domain/enums/admin_section.dart';
import '../../../admin/interns/presentation/screens/intern_list_screen.dart';
import '../../../admin/meals/presentation/screens/meal_history_list_screen.dart';
import '../../../receipts/presentation/screens/receipt_list_screen.dart';
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

  String _currentTitle(BuildContext context) {
    final strings = AppStrings.of(context);
    if (_isOnDashboard) return strings.dashboard;
    return strings.adminSectionLabel(AdminSection.values[_selectedIndex].name);
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
      AdminSection.receipts => const ReceiptListScreen(),
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
    final contentMaxWidth = screenWidth >= 1440 ? 1440.0 : 1280.0;
    final strings = AppStrings.of(context);

    final adminName = authState.user?.fullName ?? strings.administrator;

    if (!isDesktop) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_currentTitle(context)),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: strings.logout,
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
      backgroundColor: theme.colorScheme.surface,
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
                    margin: const EdgeInsets.fromLTRB(
                      Spacing.lg,
                      Spacing.md,
                      Spacing.lg,
                      Spacing.sm,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.lg,
                      vertical: Spacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(Spacing.radiusXl),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!_isOnDashboard) ...[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () =>
                                          setState(() => _selectedIndex = -1),
                                      borderRadius: BorderRadius.circular(
                                        Spacing.radiusXs,
                                      ),
                                      child: Text(
                                        strings.dashboard,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w600,
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
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: Spacing.xs),
                              ],
                              Text(
                                _currentTitle(context),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: Spacing.xs),
                              Text(
                                strings.management,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: Spacing.md),
                        if (screenWidth >= 1100)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.md,
                              vertical: Spacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withValues(alpha: 0.42),
                              borderRadius: BorderRadius.circular(
                                Spacing.radiusFull,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.account_circle_rounded,
                                  size: Spacing.iconSm,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: Spacing.xs),
                                Text(
                                  adminName,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: Spacing.md),
                        FilledButton.tonal(
                          onPressed: _onLogout,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.md,
                              vertical: Spacing.xs,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.logout_rounded, size: 16),
                              const SizedBox(width: Spacing.xs),
                              Text(strings.logout),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Body ─────────────────────────────────────────────────
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentMaxWidth),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            Spacing.lg,
                            Spacing.sm,
                            Spacing.lg,
                            Spacing.lg,
                          ),
                          child: _body,
                        ),
                      ),
                    ),
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
