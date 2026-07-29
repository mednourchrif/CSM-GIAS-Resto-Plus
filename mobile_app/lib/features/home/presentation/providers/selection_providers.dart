import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/enums/meal_type.dart';

final selectedMealProvider = StateProvider<MealType?>((ref) => null);

final selectedCategoryUuidProvider = StateProvider<String?>((ref) => null);
