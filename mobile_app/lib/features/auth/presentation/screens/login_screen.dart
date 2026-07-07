import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_form.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      body: isDesktop
          ? _buildDesktopLayout(context, ref, authState)
          : _buildMobileLayout(context, ref, authState),
    );
  }

  // ─── Desktop — Split Layout ───────────────────────────────────────────────
  Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    dynamic authState,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        // Left panel — brand illustration
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        AppColors.primaryContainerDark,
                        AppColors.surfaceDark,
                      ]
                    : [
                        AppColors.primary,
                        AppColors.primaryContainer,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(Spacing.radiusXl),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    size: 52,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: Spacing.xl),
                Text(
                  'CSM-GIAS',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  'Resto+',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: Spacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.lg,
                    vertical: Spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(Spacing.radiusFull),
                  ),
                  child: Text(
                    'Système de gestion du restaurant',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right panel — form
        Expanded(
          child: _buildFormPanel(context, ref, authState),
        ),
      ],
    );
  }

  // ─── Mobile Layout ────────────────────────────────────────────────────────
  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    dynamic authState,
  ) {
    return SafeArea(child: _buildFormPanel(context, ref, authState));
  }

  // ─── Form Panel ───────────────────────────────────────────────────────────
  Widget _buildFormPanel(
    BuildContext context,
    WidgetRef ref,
    dynamic authState,
  ) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon header (mobile only — desktop has panel)
              if (!ResponsiveLayout.isDesktop(context)) ...[
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(Spacing.radiusXl),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu_rounded,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  'CSM-GIAS Resto+',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: Spacing.xxl),
              ],

              // Title
              Text(
                'Connexion Administration',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Connectez-vous pour accéder au panneau d\'administration.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.xl),

              // Form card
              Card(
                elevation: Spacing.elevationMd,
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.xl),
                  child: LoginForm(
                    error: authState.error,
                    isLoading: authState.isLoading,
                    onSubmit: (email, password) {
                      ref
                          .read(authStateProvider.notifier)
                          .login(email: email, password: password);
                    },
                  ),
                ),
              ),

              const SizedBox(height: Spacing.lg),

              // Back to kiosk
              Center(
                child: TextButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Retour à l\'accueil kiosque'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
