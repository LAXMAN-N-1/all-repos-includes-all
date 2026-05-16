import 'package:eventifi_admin/core/storage/storage_service.dart';
import 'package:eventifi_admin/features/auth/data/auth_repository.dart';
import 'package:eventifi_admin/features/auth/domain/auth_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<LoginResponse?> build() {
    return null; 
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.login(username, password);
      
      // Save token
      await ref.read(storageServiceProvider).saveToken(response.accessToken);
      
      state = AsyncValue.data(response);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await ref.read(storageServiceProvider).clearAuth();
    state = const AsyncValue.data(null);
  }
}
