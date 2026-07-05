import 'token_dto.dart';
import 'user_dto.dart';

class LoginResponseDto {
  final TokenDto token;
  final UserDto admin;

  const LoginResponseDto({required this.token, required this.admin});

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      token: TokenDto.fromJson(json['token'] as Map<String, dynamic>),
      admin: UserDto.fromJson(json['admin'] as Map<String, dynamic>),
    );
  }
}
