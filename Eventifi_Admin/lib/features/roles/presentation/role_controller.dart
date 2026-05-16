import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:eventifi_admin/features/roles/data/role_repository.dart';
import 'package:eventifi_admin/features/roles/domain/role_models.dart';

part 'role_controller.g.dart';

@riverpod
class RoleController extends _$RoleController {
  @override
  FutureOr<List<Role>> build() async {
    return _fetchRoles();
  }

  Future<List<Role>> _fetchRoles() async {
    final repository = ref.read(roleRepositoryProvider);
    return await repository.getRoles();
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchRoles());
  }

  Future<void> createRole(CreateRoleRequest request) async {
    final repository = ref.read(roleRepositoryProvider);
    await repository.createRole(request);
    ref.invalidateSelf();
  }
  
  Future<void> updateRole(int id, CreateRoleRequest request) async {
      final repository = ref.read(roleRepositoryProvider);
      await repository.updateRole(id, request);
      ref.invalidateSelf();
  }

  Future<void> deleteRole(int id) async {
    final repository = ref.read(roleRepositoryProvider);
    await repository.deleteRole(id);
    ref.invalidateSelf();
  }
}
