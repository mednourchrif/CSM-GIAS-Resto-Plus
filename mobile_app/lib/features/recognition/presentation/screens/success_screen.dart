import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../home/presentation/providers/selection_providers.dart';
import '../../../meal_registration/presentation/providers/meal_registration_provider.dart';

class SuccessScreen extends ConsumerStatefulWidget {
  const SuccessScreen({super.key});

  @override
  ConsumerState<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends ConsumerState<SuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _checkController;
  late final AnimationController _contentController;
  late final AnimationController _countdownController;

  late final Animation<double> _checkScale;
  late final Animation<double> _ringExpand;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _countdown;

  static const _redirectDelay = AppDurations.successRedirect;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _contentController = AnimationController(
      vsync: this,
      duration: AppDurations.slow,
    );
    _countdownController = AnimationController(
      vsync: this,
      duration: _redirectDelay,
    );

    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: AppCurves.bounce),
    );
    _ringExpand = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: AppCurves.enter),
    );
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: AppCurves.enter),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 20),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: AppCurves.enter),
    );
    _countdown = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _countdownController, curve: Curves.linear),
    );

    _checkController.forward().then((_) => _contentController.forward());
    _countdownController.forward();

    Future.delayed(_redirectDelay, () {
      if (!mounted) return;
      ref.read(selectedMealProvider.notifier).state = null;
      ref.read(selectedCategoryUuidProvider.notifier).state = null;
      ref.read(selectedIdentificationProvider.notifier).state = null;
      ref.read(mealRegistrationResultProvider.notifier).state = null;
      context.go('/home');
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _contentController.dispose();
    _countdownController.dispose();
    super.dispose();
  }

  String _identificationLabel(String method) {
    switch (method.toLowerCase()) {
      case 'qr':
        return 'QR Code';
      case 'face':
      case 'reconnaissance faciale':
        return 'Reconnaissance faciale';
      default:
        return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final registration = ref.watch(mealRegistrationResultProvider);
    final userName = registration?.userName;
    final mealLabel = registration?.mealLabel;
    final method = registration?.identificationMethod;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.successContainer.withValues(alpha: 0.3),
              theme.colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.xl,
                vertical: Spacing.xl,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                    maxWidth: Spacing.maxContentWidthNarrow),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated check icon
                    AnimatedBuilder(
                      animation: _checkController,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Expanding ring
                            Transform.scale(
                              scale: _ringExpand.value * 1.4,
                              child: Opacity(
                                opacity: (1 - _ringExpand.value).clamp(0, 1),
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.success
                                          .withValues(alpha: 0.4),
                                      width: 3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Check icon
                            Transform.scale(
                              scale: _checkScale.value,
                              child: child,
                            ),
                          ],
                        );
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.successGlow,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: Spacing.xl),

                    // Content section
                    AnimatedBuilder(
                      animation: _contentController,
                      builder: (context, child) => FadeTransition(
                        opacity: _contentOpacity,
                        child: Transform.translate(
                          offset: _contentSlide.value,
                          child: child,
                        ),
                      ),
                      child: Column(
                        children: [
                          if (userName != null) ...[
                            Text(
                              'Bienvenue,',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: Spacing.xs),
                            Text(
                              userName,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.success,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: Spacing.lg),
                          ],

                          // Meal confirmation card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(Spacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.successContainer
                                  .withValues(alpha: 0.5),
                              borderRadius:
                                  BorderRadius.circular(Spacing.radiusLg),
                              border: Border.all(
                                color:
                                    AppColors.success.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.restaurant_menu_rounded,
                                  color: AppColors.success,
                                  size: Spacing.iconMd,
                                ),
                                const SizedBox(height: Spacing.xs),
                                Text(
                                  mealLabel != null
                                      ? 'Repas "$mealLabel" enregistré !'
                                      : 'Repas enregistré avec succès !',
                                  style:
                                      theme.textTheme.titleMedium?.copyWith(
                                    color: AppColors.onSuccessContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: Spacing.xs),
                                Text(
                                  'Bon appétit ! 🎉',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (method != null) ...[
                            const SizedBox(height: Spacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  method.toLowerCase() == 'qr'
                                      ? Icons.qr_code_rounded
                                      : Icons.face_rounded,
                                  size: Spacing.iconXs + 2,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: Spacing.xs),
                                Text(
                                  'Identifié via ${_identificationLabel(method)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: Spacing.xxl),

                    // Countdown indicator
                    AnimatedBuilder(
                      animation: _countdownController,
                      builder: (context, _) => Column(
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(Spacing.radiusFull),
                            child: LinearProgressIndicator(
                              value: _countdown.value,
                              minHeight: 4,
                              color: AppColors.success,
                              backgroundColor:
                                  AppColors.success.withValues(alpha: 0.15),
                            ),
                          ),
                          const SizedBox(height: Spacing.xs),
                          Text(
                            'Retour à l\'accueil...',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
