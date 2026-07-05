import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/spacing.dart';
import '../../../home/presentation/providers/selection_providers.dart';
import '../../../meal_registration/presentation/providers/meal_registration_provider.dart';

class SuccessScreen extends ConsumerStatefulWidget {
  const SuccessScreen({super.key});

  @override
  ConsumerState<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends ConsumerState<SuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _opacityAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.8)),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
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
    _controller.dispose();
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
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.xl,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _scaleAnim,
                  builder: (context, child) => Transform.scale(
                    scale: _scaleAnim.value,
                    child: child,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 96,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                AnimatedBuilder(
                  animation: _opacityAnim,
                  builder: (context, child) => Opacity(
                    opacity: _opacityAnim.value,
                    child: child,
                  ),
                  child: Column(
                    children: [
                      if (userName != null) ...[
                        Text(
                          'Bienvenue,',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          userName,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: Spacing.lg),
                      ],
                      Text(
                        mealLabel != null
                            ? 'Votre repas "$mealLabel" a été enregistré avec succès.'
                            : 'Votre repas a été enregistré avec succès.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: Spacing.md),
                      Text(
                        'Bon appétit !',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (method != null) ...[
                        const SizedBox(height: Spacing.lg),
                        Text(
                          'Identification : ${_identificationLabel(method)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.xxl),
                AnimatedBuilder(
                  animation: _opacityAnim,
                  builder: (context, child) => Opacity(
                    opacity: _opacityAnim.value,
                    child: child,
                  ),
                  child: Text(
                    'Retour à l\'accueil...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
