import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;
  int _currentStep = 0;

  static const _steps = [
    (Icons.face_rounded, 'Analyse du visage'),
    (Icons.search_rounded, 'Identification en cours'),
    (Icons.restaurant_menu_rounded, 'Enregistrement du repas'),
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Advance steps visually
    _advanceStep();

    // Auto-navigate after 2 s (unchanged business logic)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.pushReplacement('/success');
    });
  }

  void _advanceStep() {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _currentStep = 1);
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _currentStep = 2);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: Spacing.maxContentWidthNarrow),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.xl,
                vertical: Spacing.xxl,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Pulsing icon
                  AnimatedBuilder(
                    animation: _pulseScale,
                    builder: (context, child) => Transform.scale(
                      scale: _pulseScale.value,
                      child: child,
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
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                theme.colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.restaurant_menu_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: Spacing.xxl),

                  Text(
                    'Traitement en cours...',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: Spacing.xl),

                  // Step indicators
                  Column(
                    children: [
                      for (int i = 0; i < _steps.length; i++)
                        _StepItem(
                          icon: _steps[i].$1,
                          label: _steps[i].$2,
                          state: i < _currentStep
                              ? _StepState.done
                              : i == _currentStep
                                  ? _StepState.active
                                  : _StepState.pending,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Step State ───────────────────────────────────────────────────────────────

enum _StepState { pending, active, done }

class _StepItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final _StepState state;

  const _StepItem({
    required this.icon,
    required this.label,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = state == _StepState.active;
    final isDone = state == _StepState.done;

    final color = isDone
        ? AppColors.success
        : isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.35);

    return AnimatedContainer(
      duration: AppDurations.normal,
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        border: Border.all(
          color: isActive
              ? theme.colorScheme.primary.withValues(alpha: 0.4)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: AppDurations.fast,
            child: isDone
                ? Icon(Icons.check_circle_rounded,
                    key: const ValueKey('done'),
                    size: Spacing.iconSm,
                    color: color)
                : isActive
                    ? SizedBox(
                        key: const ValueKey('active'),
                        width: Spacing.iconSm,
                        height: Spacing.iconSm,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: color,
                        ),
                      )
                    : Icon(icon,
                        key: const ValueKey('pending'),
                        size: Spacing.iconSm,
                        color: color),
          ),
          const SizedBox(width: Spacing.sm),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
