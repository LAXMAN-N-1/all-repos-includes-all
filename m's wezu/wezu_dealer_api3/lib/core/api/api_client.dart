import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiConstants {
  static const String _defaultRootUrl = 'https://api3.powerfrill.com';
  static const String accessTokenStorageKey = 'api3_access_token';
  static const String refreshTokenStorageKey = 'api3_refresh_token';

  // Dynamic API config from .env:
  // - API_ROOT_URL (host only)
  // - API_VERSION_PATH (defaults to /api/v1)
  // - API_BASE_URL (optional full override)
  static String _trimTrailingSlash(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  static String get baseUrl {
    const raw =
        String.fromEnvironment('API_ROOT_URL', defaultValue: _defaultRootUrl);
    return _trimTrailingSlash(raw.isEmpty ? _defaultRootUrl : raw);
  }

  static String get apiVersionPath {
    const raw =
        String.fromEnvironment('API_VERSION_PATH', defaultValue: '/api/v1');
    if (raw.isEmpty) return '/api/v1';
    return raw.startsWith('/') ? raw : '/$raw';
  }

  static String get apiBaseUrl {
    const fullOverride = String.fromEnvironment('API_BASE_URL');
    if (fullOverride.isNotEmpty) {
      return _trimTrailingSlash(fullOverride);
    }
    return _trimTrailingSlash('$baseUrl$apiVersionPath');
  }

  // ── Supabase Auth ──────────────────────────────────────
  static String get supabaseUrl {
    const raw = String.fromEnvironment('SUPABASE_URL');
    return _trimTrailingSlash(raw);
  }

  static String get supabaseAnonKey {
    return const String.fromEnvironment('SUPABASE_ANON_KEY');
  }

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static String get supabaseAuthBaseUrl => '$supabaseUrl/auth/v1';
  static String get supabasePasswordLogin =>
      '$supabaseAuthBaseUrl/token?grant_type=password';
  static String get supabaseRefreshToken =>
      '$supabaseAuthBaseUrl/token?grant_type=refresh_token';
  static String get supabaseSignup => '$supabaseAuthBaseUrl/signup';
  static String get supabaseUser => '$supabaseAuthBaseUrl/user';

  static Map<String, String> supabaseHeaders({String? accessToken}) {
    final headers = <String, String>{
      'apikey': supabaseAnonKey,
      'Content-Type': 'application/json',
    };
    final token = accessToken?.trim();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ── Auth ────────────────────────────────────────────────
  static String get login => supabasePasswordLogin;
  static String get register => supabaseSignup;
  static String get refresh => supabaseRefreshToken;
  static String get authMe => '$apiBaseUrl/auth/me';
  static String get logout => '$apiBaseUrl/auth/logout';
  static String get logoutAll => '$apiBaseUrl/auth/logout-all';
  static String get registrationStatus =>
      '$apiBaseUrl/dealers/registration-status';
  static String get changePassword => supabaseUser;

  // ── Dashboard ──────────────────────────────────────────
  static String get dashboard => '$apiBaseUrl/dealers/me/dashboard';
  static String get alerts => '$apiBaseUrl/dealers/me/alerts';
  static String get activity => '$apiBaseUrl/dealers/me/activity';

  // ── Stations ───────────────────────────────────────────
  static String get stations => '$apiBaseUrl/dealers/stations';
  static String get dealerStats => '$apiBaseUrl/dealers/stations/stats';
  static String get dealerBatteries => '$apiBaseUrl/dealers/stations/batteries';
  static String get dealerActiveRentals =>
      '$apiBaseUrl/dealers/stations/rentals/active';
  static String get dealerReviews => '$apiBaseUrl/dealers/stations/reviews';
  static String get dealerSwapsList =>
      '$apiBaseUrl/dealers/stations/swaps/list';
  // Station-scoped (append /{stationId}/activity or /transactions)
  static String get dealerStationBase => '$apiBaseUrl/dealers/stations';
  static String get deliveries => '$apiBaseUrl/deliveries';

  // ── Inventory ──────────────────────────────────────────
  static String get inventory => '$apiBaseUrl/dealers/me/inventory';
  static String get inventoryMetrics =>
      '$apiBaseUrl/dealers/me/inventory/metrics';
  static String get inventoryHealthAnalytics =>
      '$apiBaseUrl/dealers/me/inventory/health-analytics';
  static String get inventoryModels =>
      '$apiBaseUrl/dealers/me/inventory/models';
  static String get batteries => '$apiBaseUrl/batteries';
  static String get stockRequests => '$apiBaseUrl/dealers/me/stock-requests';
  static String get batteryRequests => '$apiBaseUrl/dealers/battery-requests';
  static String get dealerWarehouses => '$apiBaseUrl/dealers/me/warehouses';

  // ── Sales & Revenue ────────────────────────────────────
  static String get transactions =>
      '$apiBaseUrl/dealers/me/dashboard/transactions';
  static String get dealerLedgerTransactions =>
      '$apiBaseUrl/dealers/me/transactions';
  static String dealerTransactionDetail(String txnId) =>
      '$dealerLedgerTransactions/$txnId';
  static String get commissions => '$apiBaseUrl/dealers/me/commissions';
  static String get dealerSettlements => '$apiBaseUrl/dealers/settlements';
  static String get dealerBankAccount => '$apiBaseUrl/dealers/me/bank-account';
  static String get commissionSummary => '$apiBaseUrl/dealers/me/commissions';
  static String settlementPdf(int id) =>
      '$apiBaseUrl/dealers/me/commissions/$id/settlement-pdf';

  // ── Customers ──────────────────────────────────────────
  static String get customers => '$apiBaseUrl/dealers/me/customers';

  // ── Support Tickets ────────────────────────────────────
  static String get tickets => '$apiBaseUrl/dealers/me/tickets';
  static String ticketDetail(int id) => '$tickets/$id';
  static String ticketReply(int id) => '$tickets/$id/reply';
  static String ticketClose(int id) => '$tickets/$id/close';

  // ── Documents ──────────────────────────────────────────
  static String get documents => '$apiBaseUrl/dealers/me/dashboard/documents';
  static String get documentUpload => '$apiBaseUrl/dealers/me/documents/upload';
  static String get documentFileUpload => '$apiBaseUrl/utils/upload';

  // ── Campaigns ──────────────────────────────────────────
  static String get campaigns => '$apiBaseUrl/dealers/me/campaigns';
  static String get coupons => '$apiBaseUrl/dealers/me/campaigns/coupons';

  // ── Analytics ──────────────────────────────────────────
  static String get analyticsOverview =>
      '$apiBaseUrl/analytics/dealer/overview';
  static String get analyticsTrends =>
      '$apiBaseUrl/dealers/me/analytics/trends';
  static String get analyticsPeakHours =>
      '$apiBaseUrl/dealers/me/analytics/peak-hours';
  static String get analyticsStations =>
      '$apiBaseUrl/dealers/me/analytics/stations';

  // ── Notifications ──────────────────────────────────────
  static String get notifications =>
      '$apiBaseUrl/dealers/me/settings/notifications';
  static String get notificationPrefs =>
      '$apiBaseUrl/dealers/me/settings/notification-preferences';

  // ── Onboarding ─────────────────────────────────────────
  static String get onboardingStatus =>
      '$apiBaseUrl/dealers/me/onboarding/status';

  // ── Settings & Profile ─────────────────────────────────
  static String get dealerProfile => '$apiBaseUrl/dealers/me/settings/profile';
  static String get updateProfile =>
      '$apiBaseUrl/dealers/me/settings/profile'; // PATCH method

  // ── Roles & Users ──────────────────────────────────────
  static String get roles => '$apiBaseUrl/rbac/roles';
  static String get permissions => '$apiBaseUrl/rbac/permissions/modules';
  static String get rolesMatrix => '$apiBaseUrl/rbac/matrix';
  static const String roleAuditLog = '/audit-log'; // Suffix — stays const
  static String get dealerUsers => '$apiBaseUrl/dealers/me/team';
  static String get dealerUsersStats => '$apiBaseUrl/dealers/me/team/stats';
  static String get dealerUsersCheckEmail =>
      '$apiBaseUrl/dealers/me/team/check-email';
  static String get dealerUsersBulk => '$apiBaseUrl/dealers/me/team/bulk';

  // ── Auth Extended ──────────────────────────────────────
  static String get validateInvite =>
      '$apiBaseUrl/dealers/auth/validate-invite';
  static String get activateAccount => '$apiBaseUrl/dealers/auth/activate';
  static String get forceChangePassword =>
      '$apiBaseUrl/dealers/auth/force-change-password';

  // ── Extra Settings & Sessions ──────────────────────────
  static String get stationDefaults =>
      '$apiBaseUrl/dealers/me/settings/station-defaults';
  static String get inventoryRules =>
      '$apiBaseUrl/dealers/me/settings/inventory-rules';
  static String get holidayCalendar =>
      '$apiBaseUrl/dealers/me/settings/holiday-calendar';
  static String get rentalSettings =>
      '$apiBaseUrl/dealers/me/settings/rental-settings';
  static String get sessions => '$apiBaseUrl/users/me/login-history';
  static String get revokeSession => '$apiBaseUrl/users/me/sessions';
  static String get kycStatus => onboardingStatus;
}

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      // Per-attempt timeout: 20s connect, 30s receive.
      // The retry interceptor below will attempt up to 3 times total,
      // so worst-case total wait is ~3×20s = ~60s before giving up.
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    ),
  );

  dio.interceptors.addAll([
    // ── Retry interceptor (must be first so retries also get auth token) ──
    // Retries connection/timeout errors up to 2 extra times with backoff.
    // This handles cold-start delays on the backend (Render/Railway sleep).
    _RetryInterceptor(dio: dio, maxRetries: 2),

    // ── Auth interceptor ────────────────────────────────────────────────
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) {
            options.headers['Authorization'] = 'Bearer ${session.accessToken}';
          }
        } catch (_) {}
        return handler.next(options);
      },
      onError: (e, handler) async {
        final statusCode = e.response?.statusCode;
        final alreadyRetried = e.requestOptions.extra['api3_retried'] == true;
        if (statusCode == 401 &&
            !alreadyRetried &&
            ApiConstants.hasSupabaseConfig) {
          try {
            final refreshed =
                await Supabase.instance.client.auth.refreshSession();
            final newToken = refreshed.session?.accessToken;
            if (newToken != null && newToken.isNotEmpty) {
              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              e.requestOptions.extra['api3_retried'] = true;
              final retryResponse = await dio.fetch(e.requestOptions);
              return handler.resolve(retryResponse);
            }
          } catch (_) {}
        }
        return handler.next(e);
      },
    ),

    PrettyDioLogger(
      requestHeader: false,
      requestBody: false,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ),
  ]);

  return dio;
});

/// Automatically retries requests that fail due to connection/timeout errors.
/// The backend may need 30-60s to wake up from a cold start (free-tier hosting).
/// Strategy: attempt 1 → wait 5s → attempt 2 → wait 10s → attempt 3 → give up.
class _RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  static const _retryKey = '_retry_count';

  static const _retryableTypes = {
    DioExceptionType.connectionTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.connectionError,
  };

  const _RetryInterceptor({required this.dio, this.maxRetries = 2});

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final isRetryable = _retryableTypes.contains(err.type) ||
        (err.response == null && err.type == DioExceptionType.unknown);
    if (!isRetryable) return handler.next(err);

    final retryCount = (err.requestOptions.extra[_retryKey] as int?) ?? 0;
    if (retryCount >= maxRetries) return handler.next(err);

    // Exponential back-off: 5s, 10s
    final delaySeconds = (retryCount + 1) * 5;
    await Future.delayed(Duration(seconds: delaySeconds));

    final options = err.requestOptions;
    options.extra[_retryKey] = retryCount + 1;

    try {
      // Re-inject fresh Supabase token before retrying
      try {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }
      } catch (_) {}

      final response = await dio.fetch(options);
      return handler.resolve(response);
    } on DioException catch (retryErr) {
      return handler.next(retryErr);
    }
  }
}
