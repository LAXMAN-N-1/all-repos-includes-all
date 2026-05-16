/// Centralized route path constants and named route definitions.
/// All route strings are defined here — screens and nav helpers reference
/// these constants instead of raw strings.
class AppRoutes {
  AppRoutes._();

  // ─── Route Names ──────────────────────────────────────────────────
  static const String splash = 'splash';
  static const String login = 'login';
  static const String dashboard = 'dashboard';
  static const String inventory = 'inventory';
  static const String inventoryDetail = 'battery-detail';
  static const String receiveStock = 'receive-stock';
  static const String orders = 'orders';
  static const String orderDetail = 'order-detail';
  static const String createOrder = 'create-order';
  static const String profile = 'profile';
  static const String settings = 'settings';
  static const String notifications = 'notifications';
  static const String fleet = 'fleet';
  static const String driverDetail = 'driver-detail';
  static const String editDriverProfile = 'edit-driver-profile';
  static const String addDriver = 'add-driver';
  static const String chat = 'chat';
  static const String activity = 'activity';
  static const String editProfile = 'edit-profile';

  // ─── Route Paths ──────────────────────────────────────────────────
  static const String splashPath = '/splash';
  static const String loginPath = '/login';
  static const String dashboardPath = '/dashboard';
  static const String inventoryPath = '/inventory';
  static const String inventoryDetailPath = '/inventory/:batteryId';
  static const String receiveStockPath = '/inventory/receive';
  static const String ordersPath = '/orders';
  static const String orderDetailPath = '/orders/:orderId';
  static const String createOrderPath = '/orders/new';
  static const String profilePath = '/profile';
  static const String settingsPath = '/settings';
  static const String notificationsPath = '/notifications';
  static const String fleetPath = '/fleet';
  static const String driverDetailPath = '/fleet/:driverId';
  static const String editDriverProfilePath = '/fleet/:driverId/edit';
  static const String addDriverPath = '/fleet/add';
  static const String chatPath = '/fleet/chat/:driverId';
  static const String activityPath = '/activity';
  static const String editProfilePath = '/profile/edit';

  // ─── Deep Link Paths ──────────────────────────────────────────────
  /// Build battery detail deep link.
  static String batteryDetailLink(String batteryId) => '/inventory/$batteryId';

  /// Build order detail deep link.
  static String orderDetailLink(String orderId) => '/orders/$orderId';

  /// Build driver detail deep link.
  static String driverDetailLink(String driverId) => '/fleet/$driverId';

  // ─── Route Guards ─────────────────────────────────────────────────
  /// Routes that don't require authentication.
  static const Set<String> publicRoutes = {splashPath, loginPath};

  /// Check if a path is public (no auth required).
  static bool isPublicRoute(String path) {
    return publicRoutes.any((route) => path.startsWith(route));
  }
}
