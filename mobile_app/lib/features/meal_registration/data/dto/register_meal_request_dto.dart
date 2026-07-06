class RegisterMealRequestDto {
  final String? token;
  final String? userUuid;
  final String categorieUuid;

  const RegisterMealRequestDto({
    this.token,
    this.userUuid,
    required this.categorieUuid,
  });

  Map<String, dynamic> toJson() => {
        if (token != null) 'token': token,
        if (userUuid != null) 'utilisateur_uuid': userUuid,
        'categorie_uuid': categorieUuid,
      };
}
