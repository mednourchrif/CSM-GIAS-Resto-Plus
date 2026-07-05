class RegisterMealRequestDto {
  final String token;
  final String categorieUuid;

  const RegisterMealRequestDto({
    required this.token,
    required this.categorieUuid,
  });

  Map<String, dynamic> toJson() => {
        'token': token,
        'categorie_uuid': categorieUuid,
      };
}
