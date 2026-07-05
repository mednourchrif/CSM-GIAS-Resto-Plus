enum MealType {
  plat,
  pizza,
  sandwich;

  String get label {
    switch (this) {
      case MealType.plat:
        return 'Plat';
      case MealType.pizza:
        return 'Pizza';
      case MealType.sandwich:
        return 'Sandwich';
    }
  }
}
