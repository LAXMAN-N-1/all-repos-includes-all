import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import '../models/purchase_invoice.dart';

class InvoiceService {
  static Dio? _dio;

  /// Set Dio instance for API calls (call once at app init or from provider)
  static void init(Dio dio) => _dio = dio;

  /// Generate an invoice for a completed purchase via backend
  static Future<PurchaseInvoice> generateInvoice({
    required String orderId,
    required String productName,
    required double amount,
    required String transactionId,
  }) async {
    if (_dio == null) {
      throw Exception('InvoiceService not initialized. Call InvoiceService.init(dio) first.');
    }

    try {
      final response = await _dio!.post('/payments/$transactionId/invoice', data: {
        'order_id': orderId,
        'product_name': productName,
        'amount': amount,
      });

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Invoice generation failed');
      }

      final data = response.data;
      return PurchaseInvoice.fromOrderDetails(
        orderId: data['order_id']?.toString() ?? orderId,
        customerName: data['customer_name'] ?? 'Customer',
        customerAddress: data['customer_address'] ?? '',
        productName: data['product_name'] ?? productName,
        price: (data['amount'] as num?)?.toDouble() ?? amount,
        method: data['payment_method'] ?? 'Razorpay',
        txnId: data['transaction_id']?.toString() ?? transactionId,
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? e.message ?? 'Invoice generation failed');
    } catch (e) {
      rethrow;
    }
  }

  /// Send invoice notifications (email/SMS) via backend
  static Future<bool> sendNotifications(PurchaseInvoice invoice) async {
    try {
      if (_dio != null) {
        final response = await _dio!.post('/notifications/invoice', data: {
          'order_id': invoice.orderId,
          'type': 'purchase_invoice',
        });
        return response.statusCode == 200;
      }
    } on DioException catch (e) {
      debugPrint('Notification send error: ${e.message}');
    } catch (e) {
      debugPrint('Notification error: $e');
    }
    // Notifications are best-effort — don't block on failure
    return true;
  }

  /// Trigger automatic refund for a failed transaction
  static Future<void> triggerAutomaticRefund(String transactionId) async {
    try {
      debugPrint('AUTOMATIC REFUND: Initiating for transaction $transactionId');
      if (_dio != null) {
        await _dio!.post('/payments/refund', data: {
          'transaction_id': transactionId,
          'reason': 'automatic_failed_transaction',
        });
        debugPrint('AUTOMATIC REFUND: Successfully initiated for $transactionId');
      }
    } on DioException catch (e) {
      debugPrint('Automatic refund API error: ${e.message}');
    } catch (e) {
      debugPrint('Automatic refund error: $e');
    }
  }
}
