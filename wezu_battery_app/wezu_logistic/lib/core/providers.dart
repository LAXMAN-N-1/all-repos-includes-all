import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api/api_client.dart';
import '../services/api/interceptors/auth_interceptor.dart';
import '../services/storage_service.dart';

export '../features/auth/providers/auth_providers.dart';

/// Central provider definitions for dependency injection.
/// All service and repository providers live here for discoverability.
///
/// Feature-specific providers should be defined in their own feature
/// directory: `lib/features/<feature>/providers/`

// ─── Services ───────────────────────────────────────────────────────

/// Provides the configured ApiClient instance.
final apiClientProvider = Provider<ApiClient>((ref) {
  final authInterceptor = AuthInterceptor(
    ref.watch(storageServiceProvider),
    onUnauthenticated: () {
      // Trigger logout state
      ref.read(isAuthenticatedProvider.notifier).state = false;
      ref.read(authTokenProvider.notifier).state = null;
      ref.read(storageServiceProvider).clearTokens();
    },
  );
  
  return ApiClient(
    authInterceptor: authInterceptor,
    enableLogging: true,
    useMocks: false, // Set to false for real API
  );
});

/// Provides the singleton storage service instance.
/// Must be overridden with the initialized instance during app startup.
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService.instance;
});

// ─── Auth State ─────────────────────────────────────────────────────

/// Tracks whether the user is currently authenticated.
/// Feature providers can watch this to react to auth changes.
final isAuthenticatedProvider = StateProvider<bool>((ref) {
  return false;
});

/// Holds the current auth token, if any.
final authTokenProvider = StateProvider<String?>((ref) {
  return null;
});
