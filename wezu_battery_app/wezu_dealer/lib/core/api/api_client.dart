import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiConstants {
  static String _normalizeBaseUrl(String value) =>
      value.trim().replaceAll(RegExp(r'/+$'), '');

  // Build-time API endpoint (preferred), with localhost fallback for local dev.
  static String get baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (configured.trim().isNotEmpty) {
      return _normalizeBaseUrl(configured);
    }

    const legacy = String.fromEnvironment('API_ROOT_URL', defaultValue: '');
    if (legacy.trim().isNotEmpty) {
      return _normalizeBaseUrl(legacy);
    }

    return 'http://127.0.0.1:8000';
  }
  static const String apiVersion = '/api/v1';
  static String get apiBaseUrl => '$baseUrl$apiVersion';

  // ── Auth ────────────────────────────────────────────────
  static String get login => '$apiBaseUrl/dealer/auth/login';
  static String get register => '$apiBaseUrl/dealer/auth/register';
  static String get refresh => '$apiBaseUrl/dealer/auth/refresh';
  static String get registrationStatus =>
      '$apiBaseUrl/dealer/auth/register/status';
  static String get changePassword => '$apiBaseUrl/dealer/auth/change-password';

  // ── Dashboard ──────────────────────────────────────────
  static String get dashboard => '$apiBaseUrl/dealer/portal/dashboard';
  static String get alerts => '$apiBaseUrl/dealer/portal/alerts';
  static String get activity => '$apiBaseUrl/dealer/portal/activity';

  // ── Stations ───────────────────────────────────────────
  static String get stations => '$apiBaseUrl/dealer-stations';
  static String get dealerStats => '$apiBaseUrl/dealer-stations/stats';
  static String get dealerBatteries => '$apiBaseUrl/dealer-stations/batteries';
  static String get dealerActiveRentals =>
      '$apiBaseUrl/dealer-stations/rentals/active';
  static String get dealerReviews => '$apiBaseUrl/dealer-stations/reviews';
  static String get dealerSwapsList => '$apiBaseUrl/dealer-stations/swaps/list';
  // Station-scoped (append /{stationId}/activity or /transactions)
  static String get dealerStationBase => '$apiBaseUrl/dealer-stations';

  // ── Inventory ──────────────────────────────────────────
  static String get inventory => '$apiBaseUrl/dealer/portal/inventory';
  static String get inventoryMetrics =>
      '$apiBaseUrl/dealer/portal/inventory/metrics';
  static String get inventoryHealthAnalytics =>
      '$apiBaseUrl/dealer/portal/inventory/health-analytics';
  static String get inventoryModels =>
      '$apiBaseUrl/dealer/portal/inventory/models';
  static String get batteries => '$apiBaseUrl/batteries';

  // ── Sales & Revenue ────────────────────────────────────
  static String get transactions => '$apiBaseUrl/dealer/portal/transactions';
  static String get commissions => '$apiBaseUrl/dealers/me/commissions';
  static String get dealerSettlements => '$apiBaseUrl/dealers/settlements';
  static String get dealerBankAccount => '$apiBaseUrl/dealers/me/bank-account';
  static String get commissionSummary =>
      '$apiBaseUrl/dealer/analytics/commission-summary';
  static String settlementPdf(int id) =>
      '$apiBaseUrl/dealers/me/commissions/$id/settlement-pdf';

  // ── Customers ──────────────────────────────────────────
  static String get customers => '$apiBaseUrl/dealer/portal/customers';

  // ── Support Tickets ────────────────────────────────────
  static String get tickets => '$apiBaseUrl/dealer/portal/tickets';
  static String ticketDetail(int id) => '$tickets/$id';
  static String ticketReply(int id) => '$tickets/$id/reply';
  static String ticketClose(int id) => '$tickets/$id/close';

  // ── Documents ──────────────────────────────────────────
  static String get documents => '$apiBaseUrl/dealer/portal/documents';
  static String get documentUpload =>
      '$apiBaseUrl/dealer/portal/documents/upload';
  static String get documentFileUpload =>
      '$apiBaseUrl/dealer/portal/documents/upload-file';

  // ── Campaigns ──────────────────────────────────────────
  static String get campaigns => '$apiBaseUrl/dealer/portal/campaigns';
  static String get coupons => '$apiBaseUrl/dealer/campaigns/coupons';

  // ── Analytics ──────────────────────────────────────────
  static String get analyticsOverview =>
      '$apiBaseUrl/analytics/dealer/overview';
  static String get analyticsTrends => '$apiBaseUrl/dealer/analytics/trends';
  static String get analyticsPeakHours =>
      '$apiBaseUrl/dealer/analytics/peak-hours';
  static String get analyticsStations =>
      '$apiBaseUrl/dealer/analytics/stations';

  // ── Notifications ──────────────────────────────────────
  static String get notifications =>
      '$apiBaseUrl/dealer/portal/settings/notifications';
  static String get notificationPrefs =>
      '$apiBaseUrl/dealer/portal/settings/notification-preferences';

  // ── Onboarding ─────────────────────────────────────────
  static String get onboardingStatus => '$apiBaseUrl/dealer/onboarding/status';

  // ── Settings & Profile ─────────────────────────────────
  static String get dealerProfile =>
      '$apiBaseUrl/dealer/portal/settings/profile';
  static String get updateProfile =>
      '$apiBaseUrl/dealer/portal/settings/profile'; // PATCH method

  // ── Roles & Users ──────────────────────────────────────
  static String get roles => '$apiBaseUrl/dealer/portal/roles';
  static String get permissions =>
      '$apiBaseUrl/dealer/portal/roles/permissions/modules';
  static String get rolesMatrix => '$apiBaseUrl/dealer/portal/roles/matrix';
  static const String roleAuditLog = '/audit-log'; // Suffix — stays const
  static String get dealerUsers => '$apiBaseUrl/dealer/portal/users';
  static String get dealerUsersStats => '$apiBaseUrl/dealer/portal/users/stats';
  static String get dealerUsersCheckEmail =>
      '$apiBaseUrl/dealer/portal/users/check-email';
  static String get dealerUsersBulk => '$apiBaseUrl/dealer/portal/users/bulk';

  // ── Auth Extended ──────────────────────────────────────
  static String get validateInvite => '$apiBaseUrl/dealer/auth/validate-invite';
  static String get activateAccount => '$apiBaseUrl/dealer/auth/activate';
  static String get forceChangePassword =>
      '$apiBaseUrl/dealer/auth/force-change-password';

  // ── Extra Settings & Sessions ──────────────────────────
  static String get stationDefaults =>
      '$apiBaseUrl/dealer/portal/settings/station-defaults';
  static String get inventoryRules =>
      '$apiBaseUrl/dealer/portal/settings/inventory-rules';
  static String get holidayCalendar =>
      '$apiBaseUrl/dealer/portal/settings/holiday-calendar';
  static String get rentalSettings =>
      '$apiBaseUrl/dealer/portal/settings/rental-settings';
  static String get sessions => '$apiBaseUrl/sessions/list';
  static String get revokeSession => '$apiBaseUrl/sessions/revoke';
  static String get logoutAll => '$apiBaseUrl/auth/logout-all';
  static String get kycStatus => '$apiBaseUrl/dealer/onboarding/my-status';
}

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    ),
  );

  dio.interceptors.addAll([
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ),
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final storage = ref.read(secureStorageProvider);
        final token = await storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          final storage = ref.read(secureStorageProvider);
          final refreshToken = await storage.read(key: 'refresh_token');

          if (refreshToken != null) {
            try {
              final response = await Dio().post(
                ApiConstants.refresh,
                data: {'refresh_token': refreshToken},
              );

              final newAccessToken = response.data['access_token'];
              final newRefreshToken = response.data['refresh_token'];

              await storage.write(key: 'access_token', value: newAccessToken);
              await storage.write(key: 'refresh_token', value: newRefreshToken);

              e.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';
              final retryResponse = await dio.fetch(e.requestOptions);
              return handler.resolve(retryResponse);
            } catch (_) {
              await storage.deleteAll();
            }
          }
        }
        return handler.next(e);
      },
    ),
  ]);

  return dio;
});
