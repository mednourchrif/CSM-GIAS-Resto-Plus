import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/enums/meal_type.dart';
import '../../../identification/domain/enums/identification_method.dart';

final selectedMealProvider = StateProvider<MealType?>((ref) => null);

final selectedCategoryUuidProvider = StateProvider<String?>((ref) => null);

final selectedIdentificationProvider =
    StateProvider<IdentificationMethod?>((ref) => null);
