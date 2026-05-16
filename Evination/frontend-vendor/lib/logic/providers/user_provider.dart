import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/services/user_service.dart';

final usersProvider = AsyncNotifierProvider<UsersNotifier, List<User>>(UsersNotifier.new);

class UsersNotifier extends AsyncNotifier<List<User>> {
  @override
  Future<List<User>> build() async {
    final userService = ref.watch(userServiceProvider);
    return userService.getUsers();
  }

  Future<void> createUser(Map<String, dynamic> userData) async {
    final userService = ref.read(userServiceProvider);
    try {
      final newUser = await userService.createUser(userData);
      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, newUser]);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<void> updateUser(int id, Map<String, dynamic> userData) async {
    final userService = ref.read(userServiceProvider);
    try {
      final updatedUser = await userService.updateUser(id, userData);
      final currentList = state.value ?? [];
      state = AsyncValue.data(
        currentList.map((u) => u.id == id ? updatedUser : u).toList(),
      );
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(int id) async {
    final userService = ref.read(userServiceProvider);
    try {
      await userService.deleteUser(id);
      // Optimistic update or reload
      final currentList = state.value ?? [];
      state = AsyncValue.data(currentList.where((u) => u.id != id).toList());
    } catch (e) {
      // Handle error, maybe show snackbar via a side effect provider or listener
      print(e);
      rethrow; 
    }
  }
}
