import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/role_model.dart';
import '../../data/services/auth_service.dart';

final authStateProvider = AsyncNotifierProvider<AuthNotifier, AuthResponse?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<AuthResponse?> {
  @override
  Future<AuthResponse?> build() async {
     return null; // Initial state: not logged in
  }

  Future<void> login(String username, String password) async {
    final authService = ref.read(authServiceProvider);
    state = const AsyncValue.loading();
    try {
      final response = await authService.login(username, password);
      state = AsyncValue.data(response);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loginDemo() async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 500));
    state = AsyncValue.data(AuthResponse(
      accessToken: 'demo_token',
      tokenType: 'Bearer',
      menus: [],
      rights: [],
      permissions: [],
      user: User(
        id: 1, 
        email: 'admin@evination.com', 
        username: 'admin', 
        firstName: 'Admin',
        lastName: 'User',
        isActive: true,
        organizationId: 1,
        branchId: 1,
        roleId: 1,
        role: Role(
          id: 1, 
          name: 'Super Admin', 
          code: 'SUPERADMIN', 
          description: 'Full Access',
        ),
      ), // Mock user
    ));
  }

  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);
    await authService.logout();
    state = const AsyncValue.data(null);
  }
}
