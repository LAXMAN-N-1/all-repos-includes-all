import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';

/// Type-safe navigation helpers that wrap GoRouter.
/// Use these instead of raw `context.go()` / `context.push()` calls.
///
/// ```dart
/// AppNavigator.toDashboard(context);
/// AppNavigator.toBatteryDetail(context, batteryId: 'BAT-001');
/// AppNavigator.back(context);
/// ```
class AppNavigator {
  AppNavigator._();

  // ─── Core Navigation ──────────────────────────────────────────────

  /// Navigate back. Returns false if there's nothing to pop.
  static bool back(BuildContext context) {
    if (GoRouter.of(context).canPop()) {
      GoRouter.of(context).pop();
      return true;
    }
    return false;
  }

  /// Navigate back with a result value.
  static void backWithResult<T>(BuildContext context, T result) {
    GoRouter.of(context).pop(result);
  }

  // ─── Auth Routes ──────────────────────────────────────────────────

  /// Navigate to login (replaces stack).
  static void toLogin(BuildContext context) {
    context.go(AppRoutes.loginPath);
  }

  /// Navigate to splash (replaces stack).
  static void toSplash(BuildContext context) {
    context.go(AppRoutes.splashPath);
  }

  // ─── Main Tab Routes ──────────────────────────────────────────────

  /// Navigate to dashboard tab.
  static void toDashboard(BuildContext context) {
    context.go(AppRoutes.dashboardPath);
  }

  /// Navigate to inventory tab.
  static void toInventory(BuildContext context) {
    context.go(AppRoutes.inventoryPath);
  }

  /// Navigate to orders tab.
  static void toOrders(BuildContext context) {
    context.go(AppRoutes.ordersPath);
  }

  // ─── Detail Routes ────────────────────────────────────────────────

  /// Navigate to receive stock.
  static void toReceiveStock(BuildContext context) {
    context.goNamed(AppRoutes.receiveStock);
  }

  /// Navigate to battery detail.
  static void toBatteryDetail(
    BuildContext context, {
    required String batteryId,
  }) {
    context.goNamed(
      AppRoutes.inventoryDetail,
      pathParameters: {'batteryId': batteryId},
    );
  }

  /// Navigate to order detail.
  static void toOrderDetail(BuildContext context, {required String orderId}) {
    context.goNamed(
      AppRoutes.orderDetail,
      pathParameters: {'orderId': orderId},
    );
  }

  /// Navigate to driver detail.
  static void toDriverDetail(BuildContext context, {required String driverId}) {
    context.goNamed(
      AppRoutes.driverDetail,
      pathParameters: {'driverId': driverId},
    );
  }

  /// Navigate to edit driver profile.
  static Future<T?> toEditDriverProfile<T>(
    BuildContext context, {
    required String driverId,
  }) {
    return context.pushNamed<T>(
      AppRoutes.editDriverProfile,
      pathParameters: {'driverId': driverId},
    );
  }

  /// Navigate to create order.
  static void toCreateOrder(BuildContext context) {
    context.goNamed(AppRoutes.createOrder);
  }

  // ─── Global Routes ────────────────────────────────────────────────

  /// Navigate to profile.
  static void toProfile(BuildContext context) {
    context.goNamed(AppRoutes.profile);
  }

  /// Navigate to settings.
  static void toSettings(BuildContext context) {
    context.goNamed(AppRoutes.settings);
  }

  /// Navigate to notifications.
  static void toNotifications(BuildContext context) {
    context.goNamed(AppRoutes.notifications);
  }

  /// Navigate to activity.
  static void toActivity(BuildContext context) {
    context.goNamed(AppRoutes.activity);
  }

  /// Navigate to edit profile.
  static void toEditProfile(BuildContext context) {
    context.goNamed(AppRoutes.editProfile);
  }

  // ─── Utility ──────────────────────────────────────────────────────

  /// Get the current route location.
  static String currentLocation(BuildContext context) {
    return GoRouterState.of(context).matchedLocation;
  }

  /// Check if a specific route name is active.
  static bool isActive(BuildContext context, String routePath) {
    return GoRouterState.of(context).matchedLocation.startsWith(routePath);
  }
}
