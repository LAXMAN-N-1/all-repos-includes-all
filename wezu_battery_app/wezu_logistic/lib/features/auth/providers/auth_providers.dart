import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/base_notifier.dart';
import '../../../core/providers.dart';
import '../../../core/result.dart';
import '../../../models/user_model.dart';
import '../../notifications/providers/notifications_providers.dart';
import '../repository/auth_repository.dart';

/// Provides the auth repository instance.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    api: ref.read(apiClientProvider),
    storage: ref.read(storageServiceProvider),
  );
});

/// Manages the auth state for the entire app.
final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncState<UserModel>>((ref) {
      return AuthNotifier(ref.read(authRepositoryProvider), ref);
    });

/// Convenient provider to access the current user directly.
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authStateProvider).dataOrNull;
});

/// Auth notifier — extends BaseNotifier for consistent loading/error patterns.
class AuthNotifier extends BaseNotifier<UserModel> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier(this._repository, this._ref);

  Future<void> login({required String email, required String password}) async {
    await execute(() => _repository.login(email: email, password: password));

    // Sync global auth state if login succeeded
    if (currentData != null) {
      _ref.read(isAuthenticatedProvider.notifier).state = true;
      unawaited(_ref.read(pushTokenSyncServiceProvider).syncRegisteredToken());
    }
  }

  Future<void> logout() async {
    await _ref.read(pushTokenSyncServiceProvider).unregisterStoredToken();
    await _repository.logout();
    reset();
    _ref.read(isAuthenticatedProvider.notifier).state = false;
    _ref.read(authTokenProvider.notifier).state = null;
  }

  Future<void> restoreSession() async {
    await execute(() => _repository.restoreSession());

    final data = currentData;
    if (data != null) {
      _ref.read(isAuthenticatedProvider.notifier).state = true;
      unawaited(_ref.read(pushTokenSyncServiceProvider).syncRegisteredToken());
    } else {
      _ref.read(isAuthenticatedProvider.notifier).state = false;
    }
  }

  Future<void> restoreSessionWithProgress({
    SessionRestoreProgressCallback? onProgress,
  }) async {
    await execute(() => _repository.restoreSession(onProgress: onProgress));

    final data = currentData;
    if (data != null) {
      _ref.read(isAuthenticatedProvider.notifier).state = true;
      unawaited(_ref.read(pushTokenSyncServiceProvider).syncRegisteredToken());
    } else {
      _ref.read(isAuthenticatedProvider.notifier).state = false;
    }
  }
}
