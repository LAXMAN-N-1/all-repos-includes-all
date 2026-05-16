import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/providers.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/inventory/inventory_screen.dart';
import '../features/inventory/receive_stock/screens/receive_stock_screen.dart';
import '../features/inventory/battery_detail_screen.dart';
import '../models/order_model.dart';
import '../features/orders/orders_screen.dart';
import '../features/orders/create_order_screen.dart';
import '../features/orders/order_detail_screen.dart';
import '../features/orders/tracking_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/fleet/screens/fleet_screen.dart';
import '../features/fleet/screens/driver_detail_screen.dart';
import '../features/fleet/screens/edit_driver_profile_screen.dart';
import '../features/fleet/screens/add_driver_screen.dart';
import '../features/fleet/screens/chat_screen.dart';
import '../features/dashboard/screens/activity_screen.dart';
import '../features/settings/edit_profile_screen.dart'; // Added
import 'app_routes.dart';
import 'app_transitions.dart';
import '../widgets/app_bottom_nav.dart';

/// Application router with:
/// - Named routes for every screen
/// - Reactive auth guard via Riverpod
/// - Deep linking for battery and order details
/// - Parameterized sub-routes
/// - Per-route transition animations
///
/// Usage in main.dart:
/// ```dart
/// final container = ProviderScope(...);
/// // The router is created via a provider so it can access auth state.
/// ```

// ─── Router Provider ────────────────────────────────────────────────

/// GoRouter provider — uses refreshListenable for auth changes.
final routerProvider = Provider<GoRouter>((ref) {
  // Create a listenable that notifies when auth state changes
  final authStateListenable = ValueNotifier<bool>(
    ref.read(isAuthenticatedProvider),
  );

  ref.listen<bool>(isAuthenticatedProvider, (_, next) {
    authStateListenable.value = next;
  });

  return GoRouter(
    navigatorKey: AppRouter._rootNavigatorKey,
    initialLocation: AppRoutes.splashPath,
    debugLogDiagnostics: true,
    refreshListenable: authStateListenable,

    // ─── Reactive Auth Guard ──────────────────────────────────────
    redirect: (context, state) {
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      final location = state.matchedLocation;

      // Allow splash to handle its own routing
      if (location == AppRoutes.splashPath) return null;

      // Unauthenticated → force to login (unless already there)
      if (!isAuthenticated && !AppRoutes.isPublicRoute(location)) {
        return AppRoutes.loginPath;
      }

      // Authenticated user hitting login → redirect to dashboard
      if (isAuthenticated && location == AppRoutes.loginPath) {
        return AppRoutes.dashboardPath;
      }

      return null;
    },

    // ─── Routes ───────────────────────────────────────────────────
    routes: [
      // Splash — no transition, instant
      GoRoute(
        name: AppRoutes.splash,
        path: AppRoutes.splashPath,
        pageBuilder: (context, state) =>
            AppTransitions.none(state: state, child: const SplashScreen()),
      ),

      // Login — scale fade entrance
      GoRoute(
        name: AppRoutes.login,
        path: AppRoutes.loginPath,
        pageBuilder: (context, state) =>
            AppTransitions.scaleFade(state: state, child: const LoginScreen()),
      ),

      // ─── Authenticated Shell (Bottom Navigation) ────────────────
      ShellRoute(
        navigatorKey: AppRouter._shellNavigatorKey,
        builder: (context, state, child) => _ScaffoldWithNavBar(child: child),
        routes: [
          // Dashboard
          GoRoute(
            name: AppRoutes.dashboard,
            path: AppRoutes.dashboardPath,
            pageBuilder: (context, state) => AppTransitions.fade(
              state: state,
              child: const DashboardScreen(),
            ),
            routes: [
              // ─── Global Routes nested under Dashboard ────────────────
              // This ensures they have a back stack to Dashboard
              GoRoute(
                parentNavigatorKey: AppRouter._rootNavigatorKey,
                name: AppRoutes.profile,
                path: 'profile', // /dashboard/profile
                pageBuilder: (context, state) => AppTransitions.slideUp(
                  state: state,
                  child: const _ProfilePlaceholder(),
                ),
                routes: [
                  GoRoute(
                    parentNavigatorKey: AppRouter._rootNavigatorKey,
                    name: AppRoutes.editProfile,
                    path: 'edit', // /dashboard/profile/edit
                    pageBuilder: (context, state) => AppTransitions.slideUp(
                      state: state,
                      child: const EditProfileScreen(),
                    ),
                  ),
                ],
              ),

              GoRoute(
                parentNavigatorKey: AppRouter._rootNavigatorKey,
                name: AppRoutes.settings,
                path: 'settings', // /dashboard/settings
                pageBuilder: (context, state) => AppTransitions.slideRight(
                  state: state,
                  child: const SettingsScreen(),
                ),
              ),

              GoRoute(
                parentNavigatorKey: AppRouter._rootNavigatorKey,
                name: AppRoutes.notifications,
                path: 'notifications', // /dashboard/notifications
                pageBuilder: (context, state) => AppTransitions.slideRight(
                  state: state,
                  child: const _NotificationsPlaceholder(),
                ),
              ),

              GoRoute(
                parentNavigatorKey: AppRouter._rootNavigatorKey,
                name: AppRoutes.activity,
                path: 'activity', // /dashboard/activity
                pageBuilder: (context, state) => AppTransitions.slideUp(
                  state: state,
                  child: const ActivityScreen(),
                ),
              ),
            ],
          ),

          // Inventory
          GoRoute(
            name: AppRoutes.inventory,
            path: AppRoutes.inventoryPath,
            pageBuilder: (context, state) => AppTransitions.fade(
              state: state,
              child: const InventoryScreen(),
            ),
            routes: [
              // Receive Stock
              GoRoute(
                parentNavigatorKey: AppRouter._rootNavigatorKey,
                name: AppRoutes.receiveStock,
                path: 'receive', // /inventory/receive
                pageBuilder: (context, state) => AppTransitions.slideUp(
                  state: state,
                  child: const ReceiveStockScreen(),
                ),
              ),
              // Battery Detail
              GoRoute(
                parentNavigatorKey: AppRouter._rootNavigatorKey,
                name: AppRoutes.inventoryDetail,
                path: ':batteryId', // /inventory/:batteryId
                pageBuilder: (context, state) {
                  final batteryId = state.pathParameters['batteryId']!;
                  return AppTransitions.slideRight(
                    state: state,
                    child: BatteryDetailScreen(batteryId: batteryId),
                  );
                },
              ),
            ],
          ),

          // Orders
          GoRoute(
            name: AppRoutes.orders,
            path: AppRoutes.ordersPath,
            pageBuilder: (context, state) =>
                AppTransitions.fade(state: state, child: const OrdersScreen()),
            routes: [
              // Create Order
              GoRoute(
                parentNavigatorKey: AppRouter._rootNavigatorKey,
                name: AppRoutes.createOrder,
                path: 'new', // /orders/new
                pageBuilder: (context, state) => AppTransitions.slideUp(
                  state: state,
                  child: const CreateOrderScreen(),
                ),
              ),
              // Order Detail
              GoRoute(
                parentNavigatorKey: AppRouter._rootNavigatorKey,
                name: AppRoutes.orderDetail,
                path: ':orderId', // /orders/:orderId
                pageBuilder: (context, state) {
                  final orderId = state.pathParameters['orderId']!;
                  return AppTransitions.slideRight(
                    state: state,
                    child: OrderDetailScreen(orderId: orderId),
                  );
                },
                routes: [
                  // Live Tracking (Nested under Order Detail or just Orders? URL is /orders/:orderId/track)
                  // Let's nest it under :orderId for cleanliness
                  GoRoute(
                    parentNavigatorKey: AppRouter._rootNavigatorKey,
                    name: 'orderTracking',
                    path: 'track', // /orders/:orderId/track
                    pageBuilder: (context, state) {
                      final order = state.extra as OrderModel;
                      return AppTransitions.slideUp(
                        state: state,
                        child: TrackingScreen(order: order),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // Fleet
          GoRoute(
            name: AppRoutes.fleet,
            path: AppRoutes.fleetPath,
            pageBuilder: (context, state) =>
                AppTransitions.fade(state: state, child: const FleetScreen()),
            routes: [
              // Add Driver
              GoRoute(
                parentNavigatorKey: AppRouter._rootNavigatorKey,
                name: AppRoutes.addDriver,
                path:
                    'add', // /fleet/add (AppRoutes.addDriverPath is /fleet/add)
                pageBuilder: (context, state) => AppTransitions.slideUp(
                  state: state,
                  child: const AddDriverScreen(),
                ),
              ),
              // Driver Detail
              GoRoute(
                parentNavigatorKey: AppRouter._rootNavigatorKey,
                name: AppRoutes.driverDetail,
                path: ':driverId', // /fleet/:driverId
                pageBuilder: (context, state) {
                  final driverId = state.pathParameters['driverId']!;
                  return AppTransitions.slideRight(
                    state: state,
                    child: DriverDetailScreen(driverId: driverId),
                  );
                },
                routes: [
                  GoRoute(
                    parentNavigatorKey: AppRouter._rootNavigatorKey,
                    name: AppRoutes.editDriverProfile,
                    path: 'edit', // /fleet/:driverId/edit
                    pageBuilder: (context, state) {
                      final driverId = state.pathParameters['driverId']!;
                      return AppTransitions.slideUp(
                        state: state,
                        child: EditDriverProfileScreen(driverId: driverId),
                      );
                    },
                  ),
                ],
              ),
              // Chat
              GoRoute(
                parentNavigatorKey: AppRouter._rootNavigatorKey,
                name: AppRoutes.chat,
                path: 'chat/:driverId', // /fleet/chat/:driverId
                pageBuilder: (context, state) {
                  final driverId = state.pathParameters['driverId']!;
                  return AppTransitions.slideUp(
                    state: state,
                    child: ChatScreen(driverId: driverId),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],

    // ─── Error Page ─────────────────────────────────────────────────
    errorPageBuilder: (context, state) => AppTransitions.fade(
      state: state,
      child: _ErrorPage(error: state.error),
    ),
  );
});

/// Static keys — must live outside the provider for stability.
class AppRouter {
  AppRouter._();
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();
}

// ═══════════════════════════════════════════════════════════════════
// Bottom Navigation Shell
// ═══════════════════════════════════════════════════════════════════

class _ScaffoldWithNavBar extends StatelessWidget {
  const _ScaffoldWithNavBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    // Determine if we are on the root dashboard tab.
    // If we are, we allow the back gesture to exit the app (canPop = true).
    // Otherwise, we trap the gesture (canPop = false) and route to dashboard.
    final selectedIndex = _calculateSelectedIndex(context);
    final isAtRootDashboard = selectedIndex == 0;

    return PopScope(
      canPop: isAtRootDashboard,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // If we didn't pop (meaning we manually caught it), go to Dashboard
        context.goNamed(AppRoutes.dashboard);
      },
      child: Scaffold(
        body: Stack(
          children: [
            child,
            // Bottom gradient: fades content into bottom nav
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 32,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [bgColor.withValues(alpha: 0), bgColor],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: _calculateSelectedIndex(context),
          onTap: (index) => _onItemTapped(index, context),
          badges: const {2: 3, 3: 5},
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.dashboardPath)) return 0;
    if (location.startsWith(AppRoutes.inventoryPath)) return 1;
    if (location.startsWith(AppRoutes.ordersPath)) return 2;
    if (location.startsWith(AppRoutes.fleetPath)) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.goNamed(AppRoutes.dashboard);
        break;
      case 1:
        context.goNamed(AppRoutes.inventory);
        break;
      case 2:
        context.goNamed(AppRoutes.orders);
        break;
      case 3:
        context.goNamed(AppRoutes.fleet);
        break;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// Placeholder Screens (to be replaced with real implementations)
// ═══════════════════════════════════════════════════════════════════

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile Screen')),
    );
  }
}

class _NotificationsPlaceholder extends StatelessWidget {
  const _NotificationsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(child: Text('Notifications Screen')),
    );
  }
}

// ─── Error Page ─────────────────────────────────────────────────────

class _ErrorPage extends StatelessWidget {
  const _ErrorPage({this.error});
  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'The page you requested could not be found.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.goNamed(AppRoutes.dashboard),
              icon: const Icon(Icons.home_rounded),
              label: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
