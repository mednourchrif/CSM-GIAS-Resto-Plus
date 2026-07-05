import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/spacing.dart';
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

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.lg,
                          vertical: Spacing.xl,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const HomeHeader(),
                            const SizedBox(height: Spacing.xxl),
                            categoriesAsync.when(
                              data: (categories) => _MealGrid(
                                categories: categories,
                                selectedMeal: selectedMeal,
                              ),
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (_, _) => const Center(
                                child: Text(
                                  'Impossible de charger les catégories.',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                            const SizedBox(height: Spacing.lg),
                            _ContinueButton(selectedMeal: selectedMeal),
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
        ),
      ),
    );
  }
}

class _MealGrid extends ConsumerWidget {
  final List<MealCategory> categories;
  final MealType? selectedMeal;

  const _MealGrid({required this.categories, required this.selectedMeal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = <(MealType, IconData, String)>[
      (MealType.plat, Icons.restaurant, 'Repas traditionnel'),
      (MealType.pizza, Icons.local_pizza, 'Pizza'),
      (MealType.sandwich, Icons.lunch_dining, 'Sandwich'),
    ];

    return ResponsiveLayout(
      mobile: _buildList(meals, Axis.vertical, ref),
      tablet: _buildGrid(meals, 2, ref),
      desktop: Center(
        child: SizedBox(
          width: 900,
          child: _buildGrid(meals, 3, ref),
        ),
      ),
    );
  }

  Widget _buildList(
    List<(MealType, IconData, String)> meals,
    Axis direction,
    WidgetRef ref,
  ) {
    return Flex(
      direction: direction,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final meal in meals)
          Padding(
            padding: EdgeInsets.only(
              bottom: direction == Axis.vertical ? Spacing.md : 0,
              right: direction == Axis.horizontal ? Spacing.md : 0,
            ),
            child: _MealCardItem(
              meal: meal,
              categories: categories,
              selectedMeal: selectedMeal,
            ),
          ),
      ],
    );
  }

  Widget _buildGrid(
    List<(MealType, IconData, String)> meals,
    int crossAxisCount,
    WidgetRef ref,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - Spacing.md * (crossAxisCount - 1)) / crossAxisCount;
        return Wrap(
          spacing: Spacing.md,
          runSpacing: Spacing.md,
          alignment: WrapAlignment.center,
          children: [
            for (final meal in meals)
              SizedBox(
                width: crossAxisCount == 3 ? cardWidth : 280,
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
}

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
          final category = categories.where((c) => c.nom.toLowerCase() == type.name.toLowerCase()).firstOrNull;
          if (category != null) {
            ref.read(selectedCategoryUuidProvider.notifier).state = category.uuid;
          }
        },
      ),
    );
  }
}

class _ContinueButton extends ConsumerWidget {
  final MealType? selectedMeal;

  const _ContinueButton({required this.selectedMeal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 280,
      height: 52,
      child: FilledButton(
        onPressed:
            selectedMeal != null
                ? () {
                  ref.read(selectedMealProvider.notifier).state = selectedMeal;
                  context.push('/identification-method');
                }
                : null,
        child: const Text('Continuer'),
      ),
    );
  }
}
