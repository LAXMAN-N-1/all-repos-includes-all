import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/role_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/vendor_registration_model.dart';

final authStateProvider = AsyncNotifierProvider<AuthNotifier, AuthResponse?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<AuthResponse?> {
  @override
  Future<AuthResponse?> build() async {
     return null; // Initial state: not logged in
  }

  Future<void> login(String email, String password) async {
    final authService = ref.read(authServiceProvider);
    state = const AsyncValue.loading();
    try {
      final response = await authService.login(email, password);
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
        email: 'vendor@evination.com', 
        username: 'vendor', 
        firstName: 'Vendor',
        lastName: 'User',
        isActive: true,
        organizationId: 1,
        branchId: 1,
        roleId: 3, // Vendor Role ID usually
        role: Role(
          id: 3, 
          name: 'Vendor', 
          code: 'VENDOR', 
          description: 'Vendor Access',
        ),
      ), // Mock user
    ));
  }

  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);
    await authService.logout();
    state = const AsyncValue.data(null);
  }

  Future<void> registerVendor(VendorRegistrationModel data) async {
    final authService = ref.read(authServiceProvider);
    state = const AsyncValue.loading();
    try {
      await authService.register(data);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      // Rethrow to let UI handle if needed, or rely on state.hasError
      rethrow; 
    }
  }
}
