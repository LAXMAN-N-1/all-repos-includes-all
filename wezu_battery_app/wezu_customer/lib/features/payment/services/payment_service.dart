import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import '../models/transaction.dart';

class PaymentService {
  final Dio _dio;

  PaymentService(this._dio);

  /// Initiate a payment via the backend payment gateway
  Future<bool> initiatePayment({
    required double amount,
    required PaymentMethod method,
    required String description,
  }) async {
    try {
      debugPrint("--- [INITIATING PAYMENT] ---");
      final response = await _dio.post('/payments/initiate', data: {
        'amount': amount,
        'payment_method': method.name,
        'description': description,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        debugPrint("Payment ID: ${data['payment_id'] ?? data['id']}");
        debugPrint("Status: ${data['status']}");
        return data['status'] == 'success' || data['status'] == 'initiated';
      }
      return false;
    } on DioException catch (e) {
      debugPrint("Payment initiation failed: ${e.message}");
      if (e.response != null) {
        debugPrint("Server response: ${e.response?.data}");
      }
      return false;
    } catch (e) {
      debugPrint("Unexpected payment error: $e");
      return false;
    }
  }

  /// Process a refund for a given transaction
  Future<bool> processRefund(String transactionId, double amount) async {
    try {
      debugPrint("--- [PROCESSING REFUND] ---");
      debugPrint("Target Transaction: $transactionId");
      debugPrint("Refund Amount: \$${amount.toStringAsFixed(2)}");

      final response = await _dio.post('/payments/refund', data: {
        'transaction_id': transactionId,
        'amount': amount,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Status: REFUND INITIATED");
        return true;
      }
      return false;
    } on DioException catch (e) {
      debugPrint("Refund failed: ${e.message}");
      return false;
    }
  }
}
