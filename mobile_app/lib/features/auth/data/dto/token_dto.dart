class TokenDto {
  final String accessToken;
  final String tokenType;
  final int expiresIn;

  const TokenDto({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory TokenDto.fromJson(Map<String, dynamic> json) {
    return TokenDto(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: json['expires_in'] as int,
    );
  }
}
