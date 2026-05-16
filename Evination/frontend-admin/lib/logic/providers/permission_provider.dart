import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../../data/models/auth_response_model.dart';

final permissionProvider = Provider<PermissionHelper>((ref) {
  final authState = ref.watch(authStateProvider);
  return PermissionHelper(authState.asData?.value);
});

class PermissionHelper {
  final AuthResponse? _authResponse;

  PermissionHelper(this._authResponse);

  bool hasPermission(String permissionCode) {
    if (_authResponse == null) return false;
    // Super admin check? Assuming if role is SUPERADMIN it bypasses, 
    // but the backend sends specific permissions too. 
    // Let's stick to the list of permissions returned by backend.
    
    // Check if permissions list contains the code
    return _authResponse!.permissions.contains(permissionCode);
  }

  bool canViewMenu(String menuCode) {
    // Logic to check if user has access to a specific menu
    // This depends on how rights are structured or if menus are just filtered list
    return _authResponse?.menus.any((m) => m.code == menuCode) ?? false;
  }
}
