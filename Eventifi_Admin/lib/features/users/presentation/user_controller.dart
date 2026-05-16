import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:eventifi_admin/features/auth/domain/auth_models.dart';
import 'package:eventifi_admin/features/users/data/user_repository.dart';
import 'package:eventifi_admin/features/users/domain/user_models.dart';

part 'user_controller.g.dart';

@riverpod
class UserController extends _$UserController {
  @override
  FutureOr<List<User>> build() async {
    return _fetchUsers();
  }

  Future<List<User>> _fetchUsers() async {
    final repository = ref.read(userRepositoryProvider);
    return await repository.getUsers();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchUsers());
  }

  Future<void> createUser(CreateUserRequest request) async {
    final repository = ref.read(userRepositoryProvider);
    // Optimistic update or just refresh
    // For simplicity, we just refresh for now to ensure consistency
    await repository.createUser(request);
    ref.invalidateSelf();
  }

  Future<void> updateUser(int id, UpdateUserRequest request) async {
    final repository = ref.read(userRepositoryProvider);
    await repository.updateUser(id, request);
    ref.invalidateSelf();
  }

  Future<void> deleteUser(int id) async {
    final repository = ref.read(userRepositoryProvider);
    await repository.deleteUser(id);
    ref.invalidateSelf();
  }
}
