import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/storage.dart';

/// Auth state model.
@immutable
class AuthState {
  final String? accessToken;
  final String? refreshToken;
  final Map<String, dynamic>? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.accessToken, this.refreshToken, this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => accessToken != null;

  AuthState copyWith({String? accessToken, String? refreshToken, Map<String, dynamic>? user, bool? isLoading, String? error}) =>
      AuthState(
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  static const initial = AuthState();
}

/// Abstract auth notifier — extend this in your app to plug in real API calls.
///
/// ```dart
/// class MyAuthNotifier extends AuthNotifier {
///   @override
///   Future<AuthState> performLogin(String email, String password) async {
///     final response = await api.post('/auth/login', data: {'email': email, 'password': password});
///     return AuthState(accessToken: response['access_token'], user: response['user']);
///   }
/// }
/// ```
abstract class AuthNotifier extends StateNotifier<AuthState> {
  final SecureStorage _storage;

  static const _accessTokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';

  AuthNotifier({SecureStorage? storage})
      : _storage = storage ?? SecureStorage(),
        super(const AuthState());

  /// Override: perform login and return new state.
  Future<AuthState> performLogin(String email, String password);

  /// Override: perform token refresh and return new state.
  Future<AuthState> performRefresh(String refreshToken) async => const AuthState();

  /// Login with persistence.
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newState = await performLogin(email, password);
      if (newState.accessToken != null) {
        await _storage.write(_accessTokenKey, newState.accessToken!);
        if (newState.refreshToken != null) await _storage.write(_refreshTokenKey, newState.refreshToken!);
      }
      state = newState.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Logout and clear tokens.
  Future<void> logout() async {
    await _storage.delete(_accessTokenKey);
    await _storage.delete(_refreshTokenKey);
    state = const AuthState();
  }

  /// Restore session from secure storage.
  Future<void> restoreSession() async {
    final token = await _storage.read(_accessTokenKey);
    if (token != null) {
      state = state.copyWith(accessToken: token);
    }
  }

  /// Get current access token (for API interceptor).
  Future<String?> getToken() async => state.accessToken ?? await _storage.read(_accessTokenKey);
}

/// Route guard mixin for go_router redirect logic.
mixin AuthGuard {
  bool get isAuthenticated;

  /// Returns redirect path if not authenticated, null if authorized.
  String? guard(String currentPath, {String loginPath = '/login', List<String> publicPaths = const ['/login', '/register', '/forgot-password']}) {
    if (publicPaths.contains(currentPath)) return isAuthenticated ? '/' : null;
    return isAuthenticated ? null : loginPath;
  }
}
