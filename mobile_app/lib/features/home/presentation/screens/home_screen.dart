import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../shared/widgets/animated_fade_in.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../meal_registration/domain/entities/meal_category.dart';
import '../../../meal_registration/presentation/providers/meal_registration_provider.dart';
import '../../../identification/domain/entities/identification_grant.dart';
import '../../../identification/presentation/providers/identification_provider.dart';
import '../../../identification/presentation/providers/kiosk_flow_provider.dart';
import '../../domain/enums/meal_type.dart';
import '../providers/selection_providers.dart';
import '../widgets/administration_button.dart';
import '../widgets/home_header.dart';
import '../widgets/meal_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final IdentificationGrant? initialIdentificationGrant;

  const HomeScreen({super.key, this.initialIdentificationGrant});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  Timer? _grantExpiryTimer;
  String? _scheduledGrantToken;
  IdentificationGrant? _handoffGrant;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final grant = widget.initialIdentificationGrant;
    _handoffGrant = grant;
    if (grant?.token.trim().isNotEmpty == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(pendingIdentificationProvider.notifier).state = grant;
      });
    }
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final grant = widget.initialIdentificationGrant;
    if (grant != null &&
        grant.token.trim().isNotEmpty &&
        grant.token != _handoffGrant?.token) {
      _handoffGrant = grant;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(pendingIdentificationProvider.notifier).state = grant;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _grantExpiryTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      // `/home` is kept underneath `/kiosk-camera` in the navigation stack.
      // During a successful identification Android may briefly report the
      // app as paused while the camera surface is released. When this screen
      // was opened with a fresh route grant, preserve it for the meal-choice
      // handoff; the grant expiry timer still bounds its lifetime.
      if (_handoffGrant?.token.trim().isNotEmpty == true) {
        return;
      }
      ref.read(resetKioskFlowProvider)();
    }
  }

  void _scheduleGrantExpiry(IdentificationGrant? grant) {
    _grantExpiryTimer?.cancel();
    _scheduledGrantToken = grant?.token;
    // The API validates the proof when the meal is submitted. Do not use the
    // tablet clock here because clock skew can discard a fresh grant.
  }

  @override
  Widget build(BuildContext context) {
    final selectedMeal = ref.watch(selectedMealProvider);
    final categoriesAsync = ref.watch(mealCategoriesProvider);
    final pendingIdentification = ref.watch(pendingIdentificationProvider);
    // The route grant is the authoritative handoff from the camera screen.
    // Keep it locally so a transient camera lifecycle event cannot erase the
    // meal-selection screen while the provider state is being refreshed.
    final initialGrant = _handoffGrant ?? widget.initialIdentificationGrant;
    final activeIdentification =
        pendingIdentification?.token.trim().isNotEmpty == true
        ? pendingIdentification
        : initialGrant?.token.trim().isNotEmpty == true
        ? initialGrant
        : null;
    if (pendingIdentification != null && activeIdentification == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(pendingIdentificationProvider.notifier).state = null;
      });
    }
    _scheduleGrantExpiry(activeIdentification);
    final registrationState = ref.watch(mealRegistrationProvider);
    final offlineQueueCount = registrationState.offlineQueueCount;
    final viewport = MediaQuery.sizeOf(context);
    final useWideLayout =
        ResponsiveLayout.isDesktop(context) ||
        (viewport.width >= 700 && viewport.width > viewport.height);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: useWideLayout
                ? _buildDesktopLayout(
                    context,
                    ref,
                    selectedMeal,
                    categoriesAsync,
                    activeIdentification,
                    offlineQueueCount,
                  )
                : _buildPortraitLayout(
                    context,
                    ref,
                    selectedMeal,
                    categoriesAsync,
                    activeIdentification,
                    offlineQueueCount,
                  ),
          ),
          if (registrationState.isLoading) ...[
            const ModalBarrier(dismissible: false, color: Colors.black38),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }

  // ─── Portrait / Mobile Layout ─────────────────────────────────────────────
  Widget _buildPortraitLayout(
    BuildContext context,
    WidgetRef ref,
    MealType? selectedMeal,
    AsyncValue<List<MealCategory>> categoriesAsync,
    IdentificationGrant? pendingIdentification,
    int offlineQueueCount,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.lg,
                      vertical: Spacing.xl,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedFadeIn(
                          child: HomeHeader(
                            compact: constraints.maxHeight < 720,
                            subtitle: _buildHeaderSubtitle(
                              context,
                              pendingIdentification,
                              offlineQueueCount,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: constraints.maxHeight < 720
                              ? Spacing.lg
                              : Spacing.xxl,
                        ),
                        AnimatedFadeIn(
                          delay: const Duration(milliseconds: 200),
                          child: pendingIdentification == null
                              ? const _KioskStartPanel()
                              : _MealGrid(
                                  categoriesAsync: categoriesAsync,
                                  selectedMeal: selectedMeal,
                                  identificationGrant: pendingIdentification,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                Spacing.lg,
                0,
                Spacing.lg,
                Spacing.xl,
              ),
              child: AdministrationButton(),
            ),
          ],
        );
      },
    );
  }

  // ─── Desktop / Landscape Layout ───────────────────────────────────────────
  Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    MealType? selectedMeal,
    AsyncValue<List<MealCategory>> categoriesAsync,
    IdentificationGrant? pendingIdentification,
    int offlineQueueCount,
  ) {
    return Row(
      children: [
        // Left panel — header
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.55),
                  Theme.of(context).colorScheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Spacing.xl),
                child: Column(
                  children: [
                    HomeHeader(
                      compact: MediaQuery.sizeOf(context).height < 680,
                      subtitle: _buildHeaderSubtitle(
                        context,
                        pendingIdentification,
                        offlineQueueCount,
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),
                    const AdministrationButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Divider
        VerticalDivider(
          width: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        // Right panel — meal cards
        Expanded(
          flex: 3,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Spacing.xxl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedFadeIn(
                      child: pendingIdentification == null
                          ? const _KioskStartPanel()
                          : _MealGrid(
                              categoriesAsync: categoriesAsync,
                              selectedMeal: selectedMeal,
                              identificationGrant: pendingIdentification,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _buildHeaderSubtitle(
    BuildContext context,
    IdentificationGrant? pendingIdentification,
    int offlineQueueCount,
  ) {
    final strings = AppStrings.of(context);
    final base = pendingIdentification == null
        ? strings.faceOrQrPrompt
        : strings.chooseMealAfterIdentification;
    if (offlineQueueCount <= 0) return base;
    return '$base · ${strings.offlineQueueSubtitle(offlineQueueCount)}';
  }
}

// ─── Meal Grid ────────────────────────────────────────────────────────────────

class _MealGrid extends ConsumerWidget {
  final AsyncValue<List<MealCategory>> categoriesAsync;
  final MealType? selectedMeal;
  final IdentificationGrant identificationGrant;

  const _MealGrid({
    required this.categoriesAsync,
    required this.selectedMeal,
    required this.identificationGrant,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    return categoriesAsync.when(
      data: (categories) => _buildGrid(context, ref, categories),
      loading: () => _buildSkeleton(context),
      error: (e, _) => ErrorState(
        message: strings.loadingCategories,
        onRetry: () => ref.invalidate(mealCategoriesProvider),
      ),
    );
  }

  static const _meals = <(MealType, IconData, String)>[
    (MealType.plat, Icons.restaurant_rounded, ''),
    (MealType.pizza, Icons.local_pizza_rounded, ''),
    (MealType.sandwich, Icons.lunch_dining_rounded, ''),
  ];

  Widget _buildGrid(
    BuildContext context,
    WidgetRef ref,
    List<MealCategory> categories,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 520 ? 3 : 1;
        const spacing = Spacing.md;
        final cardWidth = crossAxisCount > 1
            ? (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
                  crossAxisCount
            : double.infinity;

        if (crossAxisCount == 1) {
          return Column(
            children: [
              for (final meal in _meals)
                Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.md),
                  child: _MealCardItem(
                    meal: meal,
                    categories: categories,
                    selectedMeal: selectedMeal,
                    identificationGrant: identificationGrant,
                  ),
                ),
            ],
          );
        }

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.center,
          children: [
            for (final meal in _meals)
              SizedBox(
                width: cardWidth,
                child: _MealCardItem(
                  meal: meal,
                  categories: categories,
                  selectedMeal: selectedMeal,
                  identificationGrant: identificationGrant,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 520 ? 3 : 1;
        const spacing = Spacing.md;
        final cardWidth = crossAxisCount > 1
            ? (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
                  crossAxisCount
            : double.infinity;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.center,
          children: List.generate(
            3,
            (i) => SizedBox(
              width: cardWidth,
              height: 160,
              child: Card(
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Meal Card Item ───────────────────────────────────────────────────────────

class _MealCardItem extends ConsumerWidget {
  final (MealType, IconData, String) meal;
  final List<MealCategory> categories;
  final MealType? selectedMeal;
  final IdentificationGrant identificationGrant;

  const _MealCardItem({
    required this.meal,
    required this.categories,
    required this.selectedMeal,
    required this.identificationGrant,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = meal.$1;
    return SizedBox(
      width: double.infinity,
      child: MealCard(
        type: type,
        icon: meal.$2,
        subtitle: meal.$3,
        isSelected: selectedMeal == type,
        onTap: () => _confirmAndRegister(context, ref, type),
      ),
    );
  }

  Future<void> _confirmAndRegister(
    BuildContext context,
    WidgetRef ref,
    MealType type,
  ) async {
    final strings = AppStrings.of(context);
    if (ref.read(kioskSubmissionLockedProvider)) return;
    ref.read(kioskSubmissionLockedProvider.notifier).state = true;

    try {
      final category = categories
          .where((c) => c.nom.toLowerCase() == type.name.toLowerCase())
          .firstOrNull;
      if (category == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(strings.unavailableCategory)));
        return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: Icon(meal.$2),
          title: Text(strings.confirmMeal(strings.mealLabel(type))),
          content: Text(strings.confirmMealWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(strings.confirm),
            ),
          ],
        ),
      );
      if (!context.mounted) return;
      if (confirmed != true) {
        ref.read(resetKioskFlowProvider)();
        GoRouter.maybeOf(context)?.go('/home');
        return;
      }
      ref.read(selectedMealProvider.notifier).state = type;
      ref.read(selectedCategoryUuidProvider.notifier).state = category.uuid;
      await ref
          .read(mealRegistrationProvider.notifier)
          .registerMeal(
            identificationToken: identificationGrant.token,
            categorieUuid: category.uuid,
            mealLabel: strings.mealLabel(type),
          );
      if (!context.mounted) return;
      final state = ref.read(mealRegistrationProvider);
      if (state.result != null) {
        context.go('/success');
        return;
      }

      final message = state.error ?? strings.retry;
      ref.read(resetKioskFlowProvider)();
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.error_outline_rounded),
          title: Text(strings.unavailableCategory),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(strings.confirm),
            ),
          ],
        ),
      );
    } finally {
      if (context.mounted) {
        ref.read(kioskSubmissionLockedProvider.notifier).state = false;
      }
    }
  }
}

class _KioskStartPanel extends StatelessWidget {
  const _KioskStartPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusXl),
          border: Border.all(color: theme.colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(Spacing.radiusLg),
                ),
                child: const Icon(
                  Icons.face_retouching_natural_rounded,
                  size: 38,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: Spacing.md),
              Text(
                strings.identifyYourself,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                strings.faceOrQrPrompt,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.push('/kiosk-camera'),
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: Text(strings.startIdentification),
                ),
              ),
              const SizedBox(height: Spacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.face_rounded,
                    size: Spacing.iconXs,
                    color: theme.colorScheme.tertiary,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(strings.faceLabel, style: theme.textTheme.labelMedium),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                    child: Text(
                      '•',
                      style: TextStyle(color: theme.colorScheme.outline),
                    ),
                  ),
                  Icon(
                    Icons.qr_code_2_rounded,
                    size: Spacing.iconXs,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(strings.qrLabel, style: theme.textTheme.labelMedium),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
