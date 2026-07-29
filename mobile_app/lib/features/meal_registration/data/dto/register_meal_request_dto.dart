class RegisterMealRequestDto {
  final String identificationToken;
  final String categorieUuid;

  const RegisterMealRequestDto({
    required this.identificationToken,
    required this.categorieUuid,
  });

  Map<String, dynamic> toJson() => {
    'identification_token': identificationToken,
    'categorie_uuid': categorieUuid,
  };
}
