import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/theme/app_shadows.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textController = AnimationController(
      vsync: this,
      duration: AppDurations.slow,
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: AppCurves.emphasized),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: AppCurves.enter),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: AppCurves.enter),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 16),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: AppCurves.enter),
    );

    _logoController.forward().then((_) {
      _textController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.surfaceDark,
                    AppColors.primaryContainerDark.withValues(alpha: 0.3),
                  ]
                : [
                    AppColors.surfaceLight,
                    AppColors.primaryContainer.withValues(alpha: 0.4),
                  ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) => Transform.scale(
                  scale: _logoScale.value,
                  child: Opacity(
                    opacity: _logoOpacity.value,
                    child: child,
                  ),
                ),
                child: Container(
                  width: 100,
                  height: 100,
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
                    boxShadow: AppShadows.primaryGlow,
                  ),
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    size: 52,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: Spacing.xl),

              // Text group
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) => Opacity(
                  opacity: _textOpacity.value,
                  child: Transform.translate(
                    offset: _textSlide.value,
                    child: child,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'CSM-GIAS',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: Spacing.xxs),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Resto',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.xs,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary,
                            borderRadius:
                                BorderRadius.circular(Spacing.radiusXs),
                          ),
                          child: Text(
                            '+',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onSecondary,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      'Système de gestion du restaurant',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Spacing.xxxl),

              // Loading indicator
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) => Opacity(
                  opacity: _textOpacity.value,
                  child: child,
                ),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.primary,
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.15),
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
