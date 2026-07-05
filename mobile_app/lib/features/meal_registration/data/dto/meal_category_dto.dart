import '../../domain/entities/meal_category.dart';

class MealCategoryDto {
  final String uuid;
  final String nom;
  final String? description;

  const MealCategoryDto({
    required this.uuid,
    required this.nom,
    this.description,
  });

  factory MealCategoryDto.fromJson(Map<String, dynamic> json) {
    return MealCategoryDto(
      uuid: json['uuid'] as String,
      nom: json['nom'] as String,
      description: json['description'] as String?,
    );
  }

  MealCategory toDomain() => MealCategory(
        uuid: uuid,
        nom: nom,
        description: description,
      );
}
