import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/role_model.dart';
import '../../data/services/role_service.dart';

final rolesProvider = AsyncNotifierProvider<RolesNotifier, List<Role>>(RolesNotifier.new);

class RolesNotifier extends AsyncNotifier<List<Role>> {
  @override
  Future<List<Role>> build() async {
    final roleService = ref.watch(roleServiceProvider);
    return roleService.getRoles();
  }
  Future<void> addRole(Map<String, dynamic> data) async {
    final service = ref.read(roleServiceProvider);
    await service.createRole(data);
    ref.invalidateSelf();
  }

  Future<void> editRole(int id, Map<String, dynamic> data) async {
    final service = ref.read(roleServiceProvider);
    await service.updateRole(id, data);
    ref.invalidateSelf();
  }

  Future<void> removeRole(int id) async {
    final service = ref.read(roleServiceProvider);
    await service.deleteRole(id);
    ref.invalidateSelf();
  }
}
