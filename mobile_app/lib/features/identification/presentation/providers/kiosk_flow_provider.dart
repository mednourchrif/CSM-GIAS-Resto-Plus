import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/presentation/providers/selection_providers.dart';
import '../../../meal_registration/presentation/providers/meal_registration_provider.dart';
import 'identification_provider.dart';

/// Prevents overlapping confirmation dialogs and duplicate submissions.
final kioskSubmissionLockedProvider = StateProvider<bool>((ref) => false);

/// Clears the values from any previous meal choice while preserving the fresh
/// identification grant that should lead to category selection.
final resetKioskMealSelectionProvider = Provider<void Function()>((ref) {
  return () {
    ref.read(kioskSubmissionLockedProvider.notifier).state = false;
    ref.read(selectedMealProvider.notifier).state = null;
    ref.read(selectedCategoryUuidProvider.notifier).state = null;
    ref.read(mealRegistrationProvider.notifier).reset();
  };
});

/// Clears every in-memory value that belongs to one kiosk interaction.
///
/// Identification grants are intentionally never persisted, so a process
/// restart also starts from a clean session.
final resetKioskFlowProvider = Provider<void Function()>((ref) {
  return () {
    ref.read(resetKioskMealSelectionProvider)();
    ref.read(pendingIdentificationProvider.notifier).state = null;
  };
});
