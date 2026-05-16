import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/branch_model.dart';
import '../../data/services/branch_service.dart';

final branchesProvider = AsyncNotifierProvider<BranchesNotifier, List<Branch>>(BranchesNotifier.new);

class BranchesNotifier extends AsyncNotifier<List<Branch>> {
  @override
  Future<List<Branch>> build() async {
    final branchService = ref.watch(branchServiceProvider);
    return branchService.getBranches();
  }
  Future<void> addBranch(Map<String, dynamic> data) async {
    final service = ref.read(branchServiceProvider);
    await service.createBranch(data);
    ref.invalidateSelf(); // Refresh list
  }

  Future<void> editBranch(int id, Map<String, dynamic> data) async {
    final service = ref.read(branchServiceProvider);
    await service.updateBranch(id, data);
    ref.invalidateSelf();
  }

  Future<void> removeBranch(int id) async {
    final service = ref.read(branchServiceProvider);
    await service.deleteBranch(id);
    ref.invalidateSelf();
  }
}
