import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/signup_usecase.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import '../app/app_provider.dart';
import '../../../data/models/user/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final UserModel? user;

  AuthState({required this.status, this.errorMessage, this.user});

  AuthState.initial() : status = AuthStatus.initial, errorMessage = null, user = null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final SignupUseCase _signupUseCase;
  final IAuthRepository _authRepository;

  AuthNotifier(this._loginUseCase, this._signupUseCase, this._authRepository) : super(AuthState.initial()) {
    checkStatus();
  }

  Future<void> checkStatus() async {
    final loggedIn = await _authRepository.isLoggedIn();
    if (loggedIn) {
      final user = await _authRepository.getUser();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } else {
      state = AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String username, String password) async {
    state = AuthState(status: AuthStatus.loading);
    try {
      await _loginUseCase.execute(username, password);
      final user = await _authRepository.getUser();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = AuthState(status: AuthStatus.loading);
    try {
      await _signupUseCase.execute(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
      );
      final user = await _authRepository.getUser();
      state = AuthState(status: AuthStatus.authenticated, user: user); 
    } catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final signupUseCase = ref.watch(signupUseCaseProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  return AuthNotifier(loginUseCase, signupUseCase, authRepo);
});
