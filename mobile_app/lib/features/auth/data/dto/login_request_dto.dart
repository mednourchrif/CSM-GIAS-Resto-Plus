class LoginRequestDto {
  final String email;
  final String motDePasse;

  const LoginRequestDto({
    required this.email,
    required this.motDePasse,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'mot_de_passe': motDePasse,
      };
}
