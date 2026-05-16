import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_base_url.dart';
import '../models/withdrawal_model.dart';

/// Low-level HTTP service for wallet operations.
/// Replace [_baseUrl] with your real server URL (or inject via env/config).
class WalletService {
  /// Uses the same backend as the rest of the app.
  /// Override with:
  /// --dart-define=API_BASE_URL=http://YOUR_HOST:8000/api/v1
  static final String _baseUrl = ApiBaseUrl.resolve();
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  WalletService({http.Client? client}) : _client = client ?? http.Client();

  /// POST /wallet/withdraw
  ///
  /// Maps every failure mode to a typed [WithdrawalResponse] so the UI never
  /// has to parse raw exceptions or HTTP codes.
  Future<WithdrawalResponse> withdraw({
    required WithdrawalRequest request,
    required String authToken,
  }) async {
    final uri = Uri.parse('$_baseUrl/wallet/withdraw');

    try {
      final httpResponse = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
              'Accept': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(_timeout);

      return _handleResponse(httpResponse);
    } on TimeoutException {
      return WithdrawalResponse.timeoutError();
    } on SocketException {
      // No internet / DNS failure
      return WithdrawalResponse.networkError();
    } on http.ClientException {
      return WithdrawalResponse.networkError();
    } catch (e) {
      return WithdrawalResponse.unknownError(e);
    }
  }

  /// Maps an HTTP response to a typed [WithdrawalResponse].
  WithdrawalResponse _handleResponse(http.Response response) {
    final body = _tryDecode(response.body);
    final statusCode = response.statusCode;

    switch (statusCode) {
      // ── Success ────────────────────────────────────────────────────────────
      case 200:
      case 201:
        if (body != null) return WithdrawalResponse.fromJson(body);
        return WithdrawalResponse.ok(
          transactionId: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
          remainingBalance: 0,
        );

      // ── Client errors ──────────────────────────────────────────────────────
      case 400:
        // Generic bad request — surface server message
        final msg =
            _extractMessage(body) ??
            'Invalid request. Please check your details.';
        return WithdrawalResponse(
          success: false,
          message: msg,
          errorType: WithdrawalErrorType.validation,
        );

      case 401:
      case 403:
        return WithdrawalResponse.unauthorizedError();

      case 402:
        // Some APIs return 402 for insufficient funds
        return WithdrawalResponse.insufficientBalanceError();

      case 422:
        // Unprocessable entity — field-level validation errors
        final msg =
            _extractMessage(body) ??
            'Validation failed. Please check your inputs.';
        final fieldErrors = _extractFieldErrors(body);
        return WithdrawalResponse.validationError(
          message: msg,
          fieldErrors: fieldErrors,
        );

      case 429:
        return WithdrawalResponse.rateLimitedError();

      // ── Server errors ──────────────────────────────────────────────────────
      case 500:
      case 502:
      case 503:
      case 504:
        return WithdrawalResponse.serverError(
          statusCode,
          _extractMessage(body),
        );

      default:
        return WithdrawalResponse.serverError(
          statusCode,
          _extractMessage(body),
        );
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String? _extractMessage(Map<String, dynamic>? body) =>
      body?['message'] as String?;

  /// Extracts `{ field: message }` from common API error shapes:
  /// `{ "errors": { "amount": ["Too large"] } }` or
  /// `{ "errors": { "amount": "Too large" } }`.
  Map<String, String> _extractFieldErrors(Map<String, dynamic>? body) {
    final errors = body?['errors'];
    if (errors == null || errors is! Map) return {};
    final result = <String, String>{};
    errors.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        result[key.toString()] = value.first.toString();
      } else if (value is String) {
        result[key.toString()] = value;
      }
    });
    return result;
  }

  Map<String, dynamic>? _tryDecode(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// GET /wallet/balance
  ///
  /// Returns the server-authoritative wallet balance after a successful
  /// withdrawal, or null on network/parse failure (caller degrades gracefully).
  Future<double?> fetchWalletBalance(String authToken) async {
    final uri = Uri.parse('$_baseUrl/wallet/balance');
    try {
      final response = await _client
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $authToken',
              'Accept': 'application/json',
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final body = _tryDecode(response.body);
        final raw = body?['balance'] ?? body?['data']?['balance'];
        if (raw != null) return (raw as num).toDouble();
      }
      return null;
    } on TimeoutException {
      return null;
    } on SocketException {
      return null;
    } catch (_) {
      return null;
    }
  }

  void dispose() => _client.close();

  /// GET https://ifsc.razorpay.com/{ifsc}
  /// Returns the bank name string if found, null otherwise.
  /// This is a free, no-key-required public API.
  Future<String?> lookupBankName(String ifsc) async {
    if (ifsc.isEmpty) return null;
    try {
      final uri = Uri.parse('https://ifsc.razorpay.com/$ifsc');
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final body = _tryDecode(response.body);
        return body?['BANK'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
