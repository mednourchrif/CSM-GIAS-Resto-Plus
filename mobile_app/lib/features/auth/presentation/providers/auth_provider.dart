import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers.dart';
import '../../data/datasources/auth_interceptor.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/restore_session_usecase.dart';
import 'auth_state.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSource(dio: apiClient.dio);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    storageService: storageService,
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final restoreSessionUseCaseProvider = Provider<RestoreSessionUseCase>((ref) {
  return RestoreSessionUseCase(ref.watch(authRepositoryProvider));
});

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  AuthInterceptor? _interceptor;

  @override
  AuthState build() {
    _setupAuthInterceptor();
    _syncTokenToInterceptor();
    _restoreSession();
    return const AuthState(isLoading: true);
  }

  void _setupAuthInterceptor() {
    final apiClient = ref.read(apiClientProvider);

    _interceptor = AuthInterceptor(
      onUnauthorized: () => _handleUnauthorized(),
    );

    apiClient.addInterceptor(_interceptor!);

    ref.onDispose(() {
      if (_interceptor != null) {
        apiClient.removeInterceptor(_interceptor!);
      }
    });
  }

  Future<void> _syncTokenToInterceptor() async {
    final token = await ref.read(authRepositoryProvider).getStoredToken();
    _interceptor?.updateToken(token);
  }

  void _handleUnauthorized() {
    final current = state;
    if (current.isAuthenticated) {
      ref.read(authRepositoryProvider).clearSession();
      _interceptor?.updateToken(null);
      state = const AuthState();
    }
  }

  Future<void> _restoreSession() async {
    final restoreUseCase = ref.read(restoreSessionUseCaseProvider);
    final result = await restoreUseCase();

    result.when(
      success: (user) {
        state = AuthState(user: user);
      },
      failure: (_) {
        state = const AuthState();
      },
    );
    _syncTokenToInterceptor();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final loginUseCase = ref.read(loginUseCaseProvider);
    final result = await loginUseCase(email: email, password: password);

    result.when(
      success: (user) {
        state = AuthState(user: user);
      },
      failure: (failure) {
        state = AuthState(error: failure.message);
      },
    );
    _syncTokenToInterceptor();
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).clearSession();
    _interceptor?.updateToken(null);
    state = const AuthState();
  }
}
