import '../../../../shared/models/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RestoreSessionUseCase {
  final AuthRepository _repository;

  RestoreSessionUseCase(this._repository);

  Future<bool> hasSession() async {
    final token = await _repository.getStoredToken();
    return token != null && token.isNotEmpty;
  }

  Future<Result<User>> call() {
    return _repository.restoreSession();
  }
}
