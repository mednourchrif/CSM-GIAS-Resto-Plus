import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/spacing.dart';
import '../../../../shared/widgets/animated_fade_in.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../meal_registration/domain/entities/meal_category.dart';
import '../../../meal_registration/presentation/providers/meal_registration_provider.dart';
import '../../domain/enums/meal_type.dart';
import '../providers/selection_providers.dart';
import '../widgets/administration_button.dart';
import '../widgets/home_header.dart';
import '../widgets/meal_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMeal = ref.watch(selectedMealProvider);
    final categoriesAsync = ref.watch(mealCategoriesProvider);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      body: SafeArea(
        child: isDesktop
            ? _buildDesktopLayout(context, ref, selectedMeal, categoriesAsync)
            : _buildPortraitLayout(context, ref, selectedMeal, categoriesAsync),
      ),
    );
  }

  // ─── Portrait / Mobile Layout ─────────────────────────────────────────────
  Widget _buildPortraitLayout(
    BuildContext context,
    WidgetRef ref,
    MealType? selectedMeal,
    AsyncValue<List<MealCategory>> categoriesAsync,
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
                        const AnimatedFadeIn(
                          delay: Duration(milliseconds: 0),
                          child: HomeHeader(),
                        ),
                        const SizedBox(height: Spacing.xxl),
                        AnimatedFadeIn(
                          delay: const Duration(milliseconds: 200),
                          child: _MealGrid(
                            categoriesAsync: categoriesAsync,
                            selectedMeal: selectedMeal,
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
                  Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  Theme.of(context).colorScheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Spacing.xxl),
                child: Column(
                  children: [
                    HomeHeader(),
                    SizedBox(height: Spacing.xl),
                    AdministrationButton(),
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
                      child: _MealGrid(
                        categoriesAsync: categoriesAsync,
                        selectedMeal: selectedMeal,
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
}

// ─── Meal Grid ────────────────────────────────────────────────────────────────

class _MealGrid extends ConsumerWidget {
  final AsyncValue<List<MealCategory>> categoriesAsync;
  final MealType? selectedMeal;

  const _MealGrid({
    required this.categoriesAsync,
    required this.selectedMeal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return categoriesAsync.when(
      data: (categories) => _buildGrid(context, ref, categories),
      loading: () => _buildSkeleton(context),
      error: (e, _) => ErrorState(
        message: 'Impossible de charger les catégories.',
        onRetry: () => ref.invalidate(mealCategoriesProvider),
      ),
    );
  }

  static const _meals = <(MealType, IconData, String)>[
    (MealType.plat, Icons.restaurant_rounded, 'Repas traditionnel'),
    (MealType.pizza, Icons.local_pizza_rounded, 'Pizza fraîche'),
    (MealType.sandwich, Icons.lunch_dining_rounded, 'Sandwich'),
  ];

  Widget _buildGrid(
    BuildContext context,
    WidgetRef ref,
    List<MealCategory> categories,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 520 ? 3 : 1;
        final spacing = Spacing.md;
        final cardWidth = crossAxisCount > 1
            ? (constraints.maxWidth - spacing * (crossAxisCount - 1)) / crossAxisCount
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
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth >= 520 ? 3 : 1;
      final spacing = Spacing.md;
      final cardWidth = crossAxisCount > 1
          ? (constraints.maxWidth - spacing * (crossAxisCount - 1)) / crossAxisCount
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
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ─── Meal Card Item ───────────────────────────────────────────────────────────

class _MealCardItem extends ConsumerWidget {
  final (MealType, IconData, String) meal;
  final List<MealCategory> categories;
  final MealType? selectedMeal;

  const _MealCardItem({
    required this.meal,
    required this.categories,
    required this.selectedMeal,
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
        onTap: () {
          ref.read(selectedMealProvider.notifier).state = type;
          final category = categories
              .where(
                  (c) => c.nom.toLowerCase() == type.name.toLowerCase())
              .firstOrNull;
          if (category != null) {
            ref.read(selectedCategoryUuidProvider.notifier).state =
                category.uuid;
          }
          context.push('/kiosk-camera');
        },
      ),
    );
  }
}


