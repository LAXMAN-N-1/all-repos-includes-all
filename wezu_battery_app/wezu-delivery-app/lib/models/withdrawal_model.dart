/// Categorises every possible failure mode for a withdrawal request.
enum WithdrawalErrorType {
  /// No internet / DNS failure / connection refused.
  network,

  /// Request timed out (server took too long).
  timeout,

  /// Server returned HTTP 401 / 403 — not authorised.
  unauthorized,

  /// Server returned HTTP 422 — field-level validation errors.
  validation,

  /// The requested amount exceeds the available wallet balance.
  insufficientBalance,

  /// HTTP 429 — too many requests.
  rateLimited,

  /// Any other non-2xx server response.
  serverError,

  /// An error we didn't anticipate.
  unknown,
}

// ─── Request ─────────────────────────────────────────────────────────────────

/// Request model sent to POST /wallet/withdraw
class WithdrawalRequest {
  final double amount;
  final String paymentMode; // 'bank' or 'upi'

  final String? accountNumber;
  final String? accountHolderName;
  final String? bankName;
  final String? ifscCode;
  final String? upiId;

  const WithdrawalRequest({
    required this.amount,
    required this.paymentMode,
    this.accountNumber,
    this.accountHolderName,
    this.bankName,
    this.ifscCode,
    this.upiId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'amount': amount,
      'payment_mode': paymentMode,
    };
    if (paymentMode == 'bank') {
      json['account_number'] = accountNumber;
      json['account_holder_name'] = accountHolderName;
      json['bank_name'] = bankName;
      json['ifsc_code'] = ifscCode;
    } else {
      json['upi_id'] = upiId;
    }
    return json;
  }
}

// ─── Response ────────────────────────────────────────────────────────────────

/// Response model received from POST /wallet/withdraw.
class WithdrawalResponse {
  final bool success;
  final String message;
  final String? transactionId;
  final double? remainingBalance;

  /// Populated on [WithdrawalErrorType.validation] — maps field name → error.
  final Map<String, String> fieldErrors;

  /// Categorised error type (null when [success] is true).
  final WithdrawalErrorType? errorType;

  const WithdrawalResponse({
    required this.success,
    required this.message,
    this.transactionId,
    this.remainingBalance,
    this.fieldErrors = const {},
    this.errorType,
  });

  // ── Factories ──────────────────────────────────────────────────────────────

  factory WithdrawalResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawalResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? 'Unknown error',
      transactionId: json['transaction_id'] as String?,
      remainingBalance: (json['remaining_balance'] as num?)?.toDouble(),
    );
  }

  factory WithdrawalResponse.ok({
    required String transactionId,
    required double remainingBalance,
  }) {
    return WithdrawalResponse(
      success: true,
      message: 'Withdrawal initiated successfully.',
      transactionId: transactionId,
      remainingBalance: remainingBalance,
    );
  }

  factory WithdrawalResponse.networkError() {
    return const WithdrawalResponse(
      success: false,
      message:
          'No internet connection. Please check your network and try again.',
      errorType: WithdrawalErrorType.network,
    );
  }

  factory WithdrawalResponse.timeoutError() {
    return const WithdrawalResponse(
      success: false,
      message: 'The request timed out. Please try again.',
      errorType: WithdrawalErrorType.timeout,
    );
  }

  factory WithdrawalResponse.unauthorizedError() {
    return const WithdrawalResponse(
      success: false,
      message: 'Session expired. Please log in again.',
      errorType: WithdrawalErrorType.unauthorized,
    );
  }

  factory WithdrawalResponse.rateLimitedError() {
    return const WithdrawalResponse(
      success: false,
      message: 'Too many requests. Please wait a moment and try again.',
      errorType: WithdrawalErrorType.rateLimited,
    );
  }

  factory WithdrawalResponse.insufficientBalanceError() {
    return const WithdrawalResponse(
      success: false,
      message: 'Insufficient wallet balance for this withdrawal.',
      errorType: WithdrawalErrorType.insufficientBalance,
    );
  }

  /// For HTTP 422 with optional `errors` map: `{ "field": "message" }`.
  factory WithdrawalResponse.validationError({
    required String message,
    Map<String, String> fieldErrors = const {},
  }) {
    return WithdrawalResponse(
      success: false,
      message: message,
      fieldErrors: fieldErrors,
      errorType: WithdrawalErrorType.validation,
    );
  }

  factory WithdrawalResponse.serverError(int statusCode, String? serverMsg) {
    return WithdrawalResponse(
      success: false,
      message:
          serverMsg ?? 'Server error (HTTP $statusCode). Please try again.',
      errorType: WithdrawalErrorType.serverError,
    );
  }

  factory WithdrawalResponse.unknownError(Object e) {
    return WithdrawalResponse(
      success: false,
      message: 'An unexpected error occurred: $e',
      errorType: WithdrawalErrorType.unknown,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  bool get isNetworkError => errorType == WithdrawalErrorType.network;
  bool get isTimeoutError => errorType == WithdrawalErrorType.timeout;
  bool get isValidationError => errorType == WithdrawalErrorType.validation;
  bool get isInsufficientBalance =>
      errorType == WithdrawalErrorType.insufficientBalance;
  bool get isRetryable =>
      errorType == WithdrawalErrorType.network ||
      errorType == WithdrawalErrorType.timeout ||
      errorType == WithdrawalErrorType.serverError;
}
