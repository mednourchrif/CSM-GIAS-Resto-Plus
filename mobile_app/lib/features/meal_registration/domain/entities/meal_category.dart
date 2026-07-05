class MealCategory {
  final String uuid;
  final String nom;
  final String? description;

  const MealCategory({
    required this.uuid,
    required this.nom,
    this.description,
  });
}
