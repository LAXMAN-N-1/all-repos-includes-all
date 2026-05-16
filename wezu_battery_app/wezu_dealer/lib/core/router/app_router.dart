import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

// Shell
import '../widgets/dealer_shell.dart';

// Auth
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';

// Feature screens
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/stations/screens/stations_screen.dart';
import '../../features/stations/screens/station_detail_screen.dart';
import '../../features/stations/screens/battery_list_screen.dart';
import '../../features/stations/screens/active_rentals_screen.dart';
import '../../features/stations/screens/swap_visualization_screen.dart';
import '../../features/stations/screens/ratings_screen.dart';
import '../../features/inventory/screens/inventory_screen.dart';
import '../../features/sales/screens/sales_screen.dart';
import '../../features/customers/screens/customers_screen.dart';
import '../../features/tickets/screens/tickets_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/documents/screens/documents_screen.dart';
import '../../features/campaigns/screens/campaigns_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/roles/screens/roles_list_screen.dart';
import '../../features/roles/screens/role_detail_screen.dart';
import '../../features/roles/screens/permissions_matrix_screen.dart';
import '../../features/roles/screens/users_list_screen.dart';
import '../../features/roles/screens/invite_user_screen.dart';
import '../../features/roles/screens/user_detail_screen.dart';
import '../../features/auth/screens/my_account_screen.dart';
import '../../features/auth/screens/activate_account_screen.dart';
import '../../features/auth/screens/force_change_password_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ValueNotifier<int>(0);
  ref
    ..onDispose(refreshListenable.dispose)
    ..listen<AuthState>(
      authProvider,
      (_, __) => refreshListenable.value++,
    );

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final location = state.uri.path;

      final isLogin = location == '/login';
      final isRegister = location == '/register';
      final isActivate = location.startsWith('/activate/');
      final isForceChangePassword = location == '/force-change-password';

      final isPublicRoute = isLogin || isRegister || isActivate;

      if (!authState.isAuthenticated) {
        if (isPublicRoute) return null;
        return '/login';
      }

      if (authState.mustChangePassword) {
        if (!isForceChangePassword) return '/force-change-password';
        return null;
      }

      if (isPublicRoute || isForceChangePassword) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      // ── Public / Pre-auth routes ──
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // ── Activation & Force Password (Pre-auth, outside shell) ──
      GoRoute(
        path: '/activate/:token',
        name: 'activate-account',
        builder: (context, state) => ActivateAccountScreen(
          token: state.pathParameters['token']!,
        ),
      ),
      GoRoute(
        path: '/force-change-password',
        name: 'force-change-password',
        builder: (context, state) => const ForceChangePasswordScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ── Authenticated Shell ──
      ShellRoute(
        builder: (context, state, child) => DealerShell(child: child),
        routes: [
          // M1 — Dashboard
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),

          // M2 — Stations (with sub-routes)
          GoRoute(
            path: '/stations',
            name: 'stations',
            builder: (context, state) => const StationsScreen(),
            routes: [
              // Dealer-wide sub-screens
              GoRoute(
                path: 'batteries',
                name: 'dealer-batteries',
                builder: (context, state) => const BatteryListScreen(),
              ),
              GoRoute(
                path: 'rentals',
                name: 'dealer-rentals',
                builder: (context, state) => const ActiveRentalsScreen(),
              ),
              GoRoute(
                path: 'swaps',
                name: 'dealer-swaps',
                builder: (context, state) => const SwapVisualizationScreen(),
              ),
              GoRoute(
                path: 'ratings',
                name: 'dealer-ratings',
                builder: (context, state) => const RatingsScreen(),
              ),
              // Station-scoped routes
              GoRoute(
                path: ':stationId',
                name: 'station-detail',
                builder: (context, state) => StationDetailScreen(
                  stationId: state.pathParameters['stationId']!,
                ),
                routes: [
                  GoRoute(
                    path: 'batteries',
                    name: 'station-batteries',
                    builder: (context, state) => BatteryListScreen(
                      stationId: state.pathParameters['stationId'],
                    ),
                  ),
                  GoRoute(
                    path: 'swaps',
                    name: 'station-swaps',
                    builder: (context, state) => SwapVisualizationScreen(
                      stationId: state.pathParameters['stationId'],
                    ),
                  ),
                  GoRoute(
                    path: 'ratings',
                    name: 'station-ratings',
                    builder: (context, state) => RatingsScreen(
                      stationId: state.pathParameters['stationId'],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // M3 — Inventory
          GoRoute(
            path: '/inventory',
            name: 'inventory',
            builder: (context, state) => const InventoryScreen(),
          ),

          // M4 — Sales & Revenue
          GoRoute(
            path: '/sales',
            name: 'sales',
            builder: (context, state) => const SalesScreen(),
          ),

          // M5 — Customers
          GoRoute(
            path: '/customers',
            name: 'customers',
            builder: (context, state) => const CustomersScreen(),
          ),

          // M6 — Support Tickets
          GoRoute(
            path: '/tickets',
            name: 'tickets',
            builder: (context, state) => const TicketsScreen(),
          ),

          // M7 — Documents
          GoRoute(
            path: '/documents',
            name: 'documents',
            builder: (context, state) => const DocumentsScreen(),
          ),

          // M8 — Campaigns
          GoRoute(
            path: '/campaigns',
            name: 'campaigns',
            builder: (context, state) => const CampaignsScreen(),
          ),

          // M9 — Analytics
          GoRoute(
            path: '/analytics',
            name: 'analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),

          // M10 — Notifications
          GoRoute(
            path: '/notifications',
            name: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),

          // M11 — Settings
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/my-account',
            name: 'my-account',
            builder: (context, state) => const MyAccountScreen(),
          ),

          // M12 — Roles & Permissions
          GoRoute(
            path: '/roles',
            name: 'roles',
            builder: (context, state) => const RolesListScreen(),
            routes: [
              GoRoute(
                path: 'edit/:roleId',
                name: 'roles-detail',
                builder: (context, state) =>
                    RoleDetailScreen(roleId: state.pathParameters['roleId']!),
              ),
              GoRoute(
                path: 'permissions',
                name: 'permissions-matrix',
                builder: (context, state) => const PermissionsMatrixScreen(),
              ),
              GoRoute(
                path: 'users',
                name: 'role-users',
                builder: (context, state) => const UsersListScreen(),
              ),
              GoRoute(
                path: 'users/invite',
                name: 'invite-user',
                builder: (context, state) => const InviteUserScreen(),
              ),
              GoRoute(
                path: 'users/:userId',
                name: 'user-detail',
                builder: (context, state) =>
                    UserDetailScreen(userId: state.pathParameters['userId']!),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
