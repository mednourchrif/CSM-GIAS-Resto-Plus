import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../shared/widgets/brand_logo.dart';
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
                    ? [AppColors.primaryContainerDark, AppColors.surfaceDark]
                    : [AppColors.primary, AppColors.brandBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: -80,
                  bottom: -100,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.brandYellow.withValues(alpha: 0.35),
                        width: 22,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(Spacing.xxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const BrandLogo(width: 260, showRestoBadge: true),
                        const SizedBox(height: Spacing.xl),
                        Text(
                          'Administration du restaurant',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: Spacing.sm),
                        Text(
                          'Pilotez les repas, les accès et les rapports depuis un espace unifié.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right panel — form
        Expanded(child: _buildFormPanel(context, ref, authState)),
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
                const Center(
                  child: BrandLogo(width: 190, showRestoBadge: true),
                ),
                const SizedBox(height: Spacing.xl),
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
