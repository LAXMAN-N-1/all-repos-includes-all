import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'invoice_service.dart';

enum PaymentMethod { upi, card, wallet }

class PaymentResult {
  final bool success;
  final String orderId;
  final String transactionId;
  final String? errorMessage;

  PaymentResult({
    required this.success,
    required this.orderId,
    required this.transactionId,
    this.errorMessage,
  });
}

class PaymentService {
  static Dio? _dio;

  /// Set Dio instance for API calls (call once at app init or from provider)
  static void init(Dio dio) => _dio = dio;

  /// Process a purchase payment via the backend
  static Future<PaymentResult> processPayment({
    required double amount,
    required PaymentMethod method,
    required String productSku,
  }) async {
    try {
      if (_dio == null) {
        throw Exception('PaymentService not initialized. Call PaymentService.init(dio) first.');
      }

      final response = await _dio!.post('/payments/initiate', data: {
        'amount': amount,
        'payment_method': method.name,
        'product_sku': productSku,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final status = data['status']?.toString().toLowerCase();

        if (status == 'success' || status == 'initiated' || status == 'completed') {
          final orderId = data['order_id']?.toString();
          final transactionId =
              data['transaction_id']?.toString() ?? data['id']?.toString();
          if (orderId == null ||
              orderId.isEmpty ||
              transactionId == null ||
              transactionId.isEmpty) {
            return PaymentResult(
              success: false,
              orderId: '',
              transactionId: '',
              errorMessage: 'Payment response is missing identifiers',
            );
          }

          return PaymentResult(
            success: true,
            orderId: orderId,
            transactionId: transactionId,
          );
        } else {
          // Payment failed server-side — trigger refund if needed
          final txnId = data['transaction_id']?.toString() ?? '';
          if (txnId.isNotEmpty) {
            await InvoiceService.triggerAutomaticRefund(txnId);
          }
          return PaymentResult(
            success: false,
            orderId: '',
            transactionId: txnId,
            errorMessage: data['message'] ?? data['error'] ?? 'Payment failed',
          );
        }
      }

      return PaymentResult(
        success: false,
        orderId: '',
        transactionId: '',
        errorMessage: 'Unexpected response from payment server',
      );
    } on DioException catch (e) {
      debugPrint('Payment API error: ${e.message}');
      return PaymentResult(
        success: false,
        orderId: '',
        transactionId: '',
        errorMessage: e.response?.data?['detail'] ?? e.message ?? 'Payment request failed',
      );
    } catch (e) {
      debugPrint('Unexpected payment error: $e');
      return PaymentResult(
        success: false,
        orderId: '',
        transactionId: '',
        errorMessage: e.toString(),
      );
    }
  }

  static List<Map<String, dynamic>> getSupportedMethods() {
    return [
      {'id': 'upi', 'name': 'UPI (Google Pay, PhonePe)', 'icon': 'upi_logo'},
      {
        'id': 'card',
        'name': 'Credit/Debit Card (Visa, Master)',
        'icon': 'card_icon'
      },
      {
        'id': 'wallet',
        'name': 'Wallets (Paytm, Mobikwik)',
        'icon': 'wallet_icon'
      },
    ];
  }
}
