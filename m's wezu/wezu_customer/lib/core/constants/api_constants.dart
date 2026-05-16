class ApiConstants {
  static String _normalizeBaseUrl(String value) =>
      value.trim().replaceAll(RegExp(r'/+$'), '');

  static String get _platformDefaultBaseUrl {
    // Production hosted backend.
    // Override at build time for local dev:
    //   flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8000
    return 'https://api3.powerfrill.com';
  }

  // Build-time API base URL (preferred), with local defaults for development.
  static String get baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (configured.trim().isNotEmpty) {
      return _normalizeBaseUrl(configured);
    }

    const legacy = String.fromEnvironment('API_ROOT_URL', defaultValue: '');
    if (legacy.trim().isNotEmpty) {
      return _normalizeBaseUrl(legacy);
    }

    return _platformDefaultBaseUrl;
  }

  static const String apiVersion = '/api/v1';
  static String get apiBaseUrl => '$baseUrl$apiVersion';

  // Customer-scoped prefix (canonical)
  static String get customerApiUrl => '$apiBaseUrl/customers';

  // Canonical auth introspection endpoint for Supabase-backed sessions.
  static String get authMe => '$apiBaseUrl/auth/me';

  // Auth Endpoints
  // Legacy login/register endpoints are removed in production (410).
  // Customer app authenticates with Supabase and then introspects via /auth/me.
  static String get login => '$customerApiUrl/auth/login';
  // OTP, refresh, logout, password, social — exist on /auth (auth.py)
  static String get registerRequestOtp =>
      '$apiBaseUrl/auth/register/request-otp';
  static String get registerVerifyOtp => '$apiBaseUrl/auth/register/verify-otp';
  static String get logout => '$apiBaseUrl/auth/logout';
  static String get refreshToken => '$apiBaseUrl/auth/refresh';
  static String get forgotPassword => '$apiBaseUrl/auth/forgot-password';
  static String get resetPassword => '$apiBaseUrl/auth/reset-password';
  static String get changePassword => '$apiBaseUrl/auth/change-password';
  static String get socialLogin => '$apiBaseUrl/auth/social-login';

  // User Endpoints (general)
  static String get userMe => '$apiBaseUrl/users/me';
  static String get userAvatar => '$apiBaseUrl/users/me/avatar';
  static String get userAddresses => '$apiBaseUrl/users/me/addresses';

  // Station Endpoints (general — registered at /api/v1/stations)
  static String get stations => '$apiBaseUrl/stations';
  static String get stationsNearby => '$apiBaseUrl/stations/nearby';
  static String get stationDetails => '$apiBaseUrl/stations'; // + /{id}

  // Swap Endpoints (registered at /api/v1/swaps)
  static String get swapStations => '$apiBaseUrl/swaps/stations';
  static String get swapPrice => '$apiBaseUrl/swaps/price'; // + ?station_id=X
  static String get swapInitiate => '$apiBaseUrl/swaps/initiate';
  static String swapConfirmPayment(int swapId) =>
      '$apiBaseUrl/swaps/$swapId/confirm-payment';

  // Battery Endpoints (general)
  static String get batteries => '$apiBaseUrl/batteries';
  static String get scanQr => '$apiBaseUrl/batteries/scan-qr';

  // Rental Endpoints (general — registered at /api/v1/rentals)
  static String get rentals => '$apiBaseUrl/rentals';
  static String get calculatePrice => '$apiBaseUrl/rentals/calculate-price';
  static String get initiateRental => '$apiBaseUrl/rentals';
  static String get confirmRental => '$apiBaseUrl/rentals/confirm'; // + /{id}
  static String get rentalsActive => '$apiBaseUrl/rentals/active';
  static String get rentalsHistory => '$apiBaseUrl/rentals/history';
  static String get returnRental => '$apiBaseUrl/rentals/return'; // + /{id}

  // Rental Action Endpoints
  static String get rentalExtend => '$apiBaseUrl/rentals'; // + /{id}/extend
  static String get rentalPause => '$apiBaseUrl/rentals'; // + /{id}/pause
  static String get rentalResume => '$apiBaseUrl/rentals'; // + /{id}/resume
  static String get rentalLateFees =>
      '$apiBaseUrl/rentals'; // + /{id}/late-fees
  static String get rentalWaiver =>
      '$apiBaseUrl/rentals'; // + /{id}/late-fees/waiver
  static String get rentalReportIssue =>
      '$apiBaseUrl/rentals'; // + /{id}/report-issue

  // Payment Endpoints (general)
  static String get paymentsInitiate => '$apiBaseUrl/wallet/top-ups';
  static String get paymentsVerify => '$apiBaseUrl/payments/verify';

  // Wallet Endpoints (general — registered at /api/v1/wallet)
  static String get wallet => '$apiBaseUrl/wallet';
  static String get walletLoad => '$apiBaseUrl/wallet/top-ups';
  static String get walletTransactions => '$apiBaseUrl/wallet/transactions';

  // Notification Endpoints
  static String get notifications => '$apiBaseUrl/notifications';

  // Support Endpoints
  static String get supportTickets => '$apiBaseUrl/support/tickets';
  static String get supportFaq => '$apiBaseUrl/support/faqs';

  // Biometric & 2FA Endpoints (on /auth — auth.py)
  static String get biometricRegister => '$apiBaseUrl/auth/biometric/register';
  static String get biometricLogin => '$apiBaseUrl/auth/biometric-login';
  static String get twoFAEnable => '$apiBaseUrl/auth/2fa/enable';
  static String get twoFAVerify => '$apiBaseUrl/auth/2fa/verify';
  static String get twoFADisable => '$apiBaseUrl/auth/2fa/disable';

  // Dashboard (customer-scoped)
  static String get dashboardStats => '$customerApiUrl/me/dashboard/stats';

  // Timeout — NeonDB (cloud PG) can take ~5-8s on cold start; 60s ensures
  // the first login always succeeds even on slow connections.
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 60);
}
