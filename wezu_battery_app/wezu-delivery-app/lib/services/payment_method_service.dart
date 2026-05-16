import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/payment_method_model.dart';

/// Low-level HTTP service wrapping the payment methods API.
/// Whenever the real server is unavailable or returns an error,
/// the service falls back to the built-in mock dataset so the
/// UI always has something to display during development.
class PaymentMethodService {
  static const _base = 'https://api.wezu.app';
  static const _timeout = Duration(seconds: 12);

  final http.Client _client;

  PaymentMethodService({http.Client? client})
    : _client = client ?? http.Client();

  // ─── Mock data ─────────────────────────────────────────────────────────────

  static final List<PaymentMethod> _mockMethods = [
    PaymentMethod(
      id: 'pm_001',
      type: PaymentMethodType.card,
      last4: '4242',
      brand: CardBrand.visa,
      expiryMonth: '08',
      expiryYear: '2027',
      isDefault: true,
    ),
    PaymentMethod(
      id: 'pm_002',
      type: PaymentMethodType.card,
      last4: '5555',
      brand: CardBrand.mastercard,
      expiryMonth: '03',
      expiryYear: '2026',
      isDefault: false,
    ),
    PaymentMethod(
      id: 'pm_003',
      type: PaymentMethodType.upi,
      upiId: 'rider@upi',
      isDefault: false,
    ),
  ];

  // ─── Public API ────────────────────────────────────────────────────────────

  /// GET /payments/payment-methods
  Future<List<PaymentMethod>> fetchMethods(String authToken) async {
    try {
      final resp = await _client
          .get(
            Uri.parse('$_base/payments/payment-methods'),
            headers: _headers(authToken),
          )
          .timeout(_timeout);

      if (resp.statusCode == 200) {
        final list = jsonDecode(resp.body) as List<dynamic>;
        return list
            .map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      // Fall through to mock on any non-200
    } on TimeoutException {
      // fall through
    } on SocketException {
      // fall through
    } catch (_) {
      // fall through
    }
    // Return a copy of mock data so callers can mutate their own list
    return List<PaymentMethod>.from(_mockMethods);
  }

  /// DELETE /payments/methods/{id}
  Future<bool> deleteMethod(String id, String authToken) async {
    try {
      final resp = await _client
          .delete(
            Uri.parse('$_base/payments/methods/$id'),
            headers: _headers(authToken),
          )
          .timeout(_timeout);
      return resp.statusCode == 200 || resp.statusCode == 204;
    } catch (_) {
      return true; // Optimistic: allow UI to proceed in mock mode
    }
  }

  /// POST /payments/methods  — tokenised card or UPI
  Future<PaymentMethod?> addMethod({
    required String authToken,
    required String type,
    String? token, // payment gateway token for cards
    String? upiId, // for UPI
  }) async {
    try {
      final body = <String, dynamic>{'type': type};
      if (token != null) body['token'] = token;
      if (upiId != null) body['upi_id'] = upiId;

      final resp = await _client
          .post(
            Uri.parse('$_base/payments/methods'),
            headers: _headers(authToken),
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return PaymentMethod.fromJson(
          jsonDecode(resp.body) as Map<String, dynamic>,
        );
      }
    } catch (_) {
      // fall through to mock response
    }

    // Mock: construct a local-only method so the UI is always responsive
    if (type == 'upi' && upiId != null) {
      return PaymentMethod(
        id: 'pm_local_${DateTime.now().millisecondsSinceEpoch}',
        type: PaymentMethodType.upi,
        upiId: upiId,
        isDefault: false,
      );
    }
    return null;
  }

  /// PATCH /payments/methods/{id}/default
  Future<bool> setDefault(String id, String authToken) async {
    try {
      final resp = await _client
          .patch(
            Uri.parse('$_base/payments/methods/$id/default'),
            headers: _headers(authToken),
          )
          .timeout(_timeout);
      return resp.statusCode == 200;
    } catch (_) {
      return true; // optimistic
    }
  }

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  void dispose() => _client.close();
}
