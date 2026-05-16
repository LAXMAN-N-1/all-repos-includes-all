import 'api_base_url.dart';

/// Central API configuration for the delivery app.
/// All base URL and endpoint constants live here.
class ApiConfig {
  ApiConfig._();

  /// Base URL injected at build time via --dart-define=API_BASE_URL=...
  /// Defaults to Android emulator host (maps to localhost on dev machine).
  /// For iOS simulator use: http://127.0.0.1:8000/api/v1
  /// For physical device use: `http://YOUR_LAN_IP:8000/api/v1`
  static final String baseUrl = ApiBaseUrl.resolve();

  // ── Auth endpoints ────────────────────────────────────────────────────────
  static const String requestOtp = '/auth/register/request-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String login = '/auth/token'; // OAuth2 password flow
  static const String me = '/users/me';
  static const String logout = '/auth/logout';

  // ── Logistics endpoints ───────────────────────────────────────────────────
  static const String myAssignments = '/logistics/me/assignments';
  static const String driverDashboard = '/logistics/dashboard';
  static const String activeDeliveries = '/logistics/deliveries/active';
  static const String deliveryHistory = '/logistics/deliveries/history';
  static String orderStatus(int orderId) => '/logistics/orders/$orderId/status';
  static String orderPod(int orderId) => '/logistics/orders/$orderId/pod';
  static String driverStatus(int driverId) =>
      '/logistics/drivers/$driverId/status';
  static String driverAvailability(int driverId) =>
      '/logistics/drivers/$driverId/availability';

  // ── Wallet endpoints ──────────────────────────────────────────────────────
  static const String walletBalance = '/wallet/balance';
  static const String walletWithdraw = '/wallet/withdraw';
  static const String walletTransactions = '/wallet/transactions';

  // ── Notification endpoints ────────────────────────────────────────────────
  static const String notifications = '/notifications/';

  // ── Timeouts ──────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
