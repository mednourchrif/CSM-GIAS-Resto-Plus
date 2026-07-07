import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/spacing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../admin/employees/presentation/screens/employee_list_screen.dart';
import '../../../admin/interns/presentation/screens/intern_list_screen.dart';
import '../../../admin/meals/presentation/screens/meal_history_list_screen.dart';
import '../../../admin/qr/presentation/screens/qr_list_screen.dart';
import '../../../admin/visitors/presentation/screens/visitor_list_screen.dart';
import '../../domain/enums/admin_section.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/admin_navigation_rail.dart';
import '../widgets/section_card.dart';
import 'admin_placeholder_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = -1;

  void _onDestinationSelected(int index) {
    setState(() => _selectedIndex = index);
    Navigator.of(context).maybePop();
  }

  void _onLogout() async {
    await ref.read(authStateProvider.notifier).logout();
    if (!mounted) return;
    context.go('/login');
  }

  bool get _isOnDashboard => _selectedIndex == -1;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final isMobile = screenWidth < 600;

    final adminName = authState.user?.fullName ?? 'Administrateur';
    final sections = AdminSection.values;

    Widget body;
    if (_isOnDashboard) {
      body = _buildDashboardGrid(theme, sections);
    } else if (_selectedIndex == 0) {
      body = const EmployeeListScreen();
    } else if (_selectedIndex == 1) {
      body = const InternListScreen();
    } else if (_selectedIndex == 2) {
      body = const VisitorListScreen();
    } else if (_selectedIndex == 3) {
      body = const QrListScreen();
    } else if (_selectedIndex == 5) {
      body = const MealHistoryListScreen();
    } else {
      body = AdminPlaceholderScreen(section: sections[_selectedIndex]);
    }

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _isOnDashboard ? 'Tableau de bord' : sections[_selectedIndex].label,
          ),
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
        body: body,
      );
    }

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
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.lg,
                      vertical: Spacing.sm,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: theme.dividerColor,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_rounded,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: Spacing.sm),
                        Text(
                          adminName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        FilledButton.tonalIcon(
                          onPressed: _onLogout,
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: const Text('Déconnexion'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: isDesktop
                        ? Padding(
                            padding: const EdgeInsets.all(Spacing.lg),
                            child: body,
                          )
                        : body,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardGrid(ThemeData theme, List<AdminSection> sections) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth >= 1200
        ? 4
        : screenWidth >= 900
            ? 3
            : screenWidth >= 600
                ? 3
                : 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth -
                Spacing.md * (crossAxisCount - 1)) /
            crossAxisCount;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Administration',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  'Gérez les employés, les repas et les paramètres du restaurant.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                Expanded(
                  child: Center(
                    child: Wrap(
                      spacing: Spacing.md,
                      runSpacing: Spacing.md,
                      alignment: WrapAlignment.center,
                      children: [
                        for (int i = 0; i < sections.length; i++)
                          SizedBox(
                            width: cardWidth.clamp(160, 280),
                            height: cardWidth.clamp(120, 200),
                            child: SectionCard(
                              section: sections[i],
                              onTap: () =>
                                  setState(() => _selectedIndex = i),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
