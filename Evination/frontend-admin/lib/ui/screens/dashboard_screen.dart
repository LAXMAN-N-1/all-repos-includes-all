import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/providers/auth_provider.dart';
import 'package:admin_panel/theme/app_theme.dart';
import 'dashboard/dashboard_views.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // authStateProvider returns AsyncValue<AuthResponse?>
    // We need to access .value to get the data
    final user = ref.watch(authStateProvider).value?.user;
    final roleCode = user?.role?.code ?? 'SUPERADMIN'; // Default for dev if needed
    
    // Switch Dashboard based on Role Code
    switch (roleCode) {
      case 'SUPERADMIN':
        return const SuperAdminDashboard();
      case 'EVENT_MANAGER':
        return const EventManagerDashboard();
      case 'VENDOR_COORDINATOR':
        return const VendorCoordinatorDashboard();
      case 'FINANCE_MANAGER':
        return const FinanceManagerDashboard();
      default:
        // Fallback or Unknown Role
        return const Center(child: Text('Unknown Role Dashboard'));
    }
  }
}
