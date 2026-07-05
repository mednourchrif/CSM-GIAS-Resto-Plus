import '../../../../shared/models/result.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Result<User>> login({
    required String email,
    required String password,
  });
  Future<Result<User>> restoreSession();
  Future<void> saveSession({required String token, required User user});
  Future<void> clearSession();
  Future<String?> getStoredToken();
}
