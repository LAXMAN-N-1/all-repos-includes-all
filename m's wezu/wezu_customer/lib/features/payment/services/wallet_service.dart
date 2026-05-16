import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';
import '../models/withdrawal_request.dart';
import '../models/payment_models.dart';

class WalletService {
  final Dio _dio;
  double _balance = 0.0;

  WalletService(this._dio);

  double get balance => _balance;

  Future<double> getBalance() async {
    try {
      final response = await _dio.get('/wallet/balance');
      _balance = (response.data['balance'] as num).toDouble();
    } catch (e) {
      debugPrint('Error fetching balance: $e');
      _balance = 0.0;
    }
    return _balance;
  }

  Future<bool> topUp(double amount, PaymentMethod method) async {
    try {
      final response = await _dio.post('/wallet/top-ups', data: {
        'amount': amount,
        'payment_method': method.name,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error topping up wallet: $e');
    }
    return false;
  }

  Future<bool> pay(double amount, {String? description}) async {
    try {
      final response = await _dio.post('/wallet/pay', data: {
        'amount': amount,
        'description': description ?? 'Purchase',
      });
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error processing wallet payment: $e');
    }
    return false;
  }

  Future<bool> withdrawFunds(WithdrawalRequest request) async {
    try {
      final response =
          await _dio.post('/wallet/withdraw', data: request.toJson());
      return response.data['status'] == 'success';
    } catch (e) {
      debugPrint('Error processing withdrawal: $e');
    }
    return false;
  }

  Future<List<Transaction>> getTransactionHistory() async {
    try {
      final response = await _dio.get('/wallet/transactions');
      final List<dynamic> data = response.data;
      return data.map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching transaction history: $e');
    }
    return [];
  }

  Future<List<SavedPaymentMethod>> getSavedMethods() async {
    try {
      final response = await _dio.get('/wallet/payment-methods');
      if (response.data is Map &&
          response.data['success'] == true &&
          response.data['data'] is Map &&
          response.data['data']['methods'] is List) {
        final List<dynamic> data =
            response.data['data']['methods'] as List<dynamic>;
        return data
            .map((json) => SavedPaymentMethod.fromJson(
                Map<String, dynamic>.from(json as Map)))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching saved methods: $e');
    }
    return [];
  }

  Future<bool> addSavedMethod(SavedPaymentMethod method) async {
    try {
      final response = await _dio.post('/wallet/payment-methods', data: {
        'type': method.type.name,
        'provider_token': method.id,
        'is_default': method.isDefault,
        'details': {
          if (method.last4 != null) 'last4': method.last4,
          if (method.brand != null) 'brand': method.brand,
          if (method.upiId != null) 'upi_id': method.upiId,
        },
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error adding saved method: $e');
      return false;
    }
  }

  Future<bool> deleteSavedMethod(String id) async {
    try {
      final response = await _dio.delete('/wallet/payment-methods/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error deleting saved method: $e');
      return false;
    }
  }

  Future<List<CashbackOffer>> getCashbackOffers() async {
    try {
      final response = await _dio.get('/wallet/cashback');
      if (response.statusCode == 200 &&
          response.data is Map &&
          response.data['transactions'] is List) {
        final List<dynamic> txns =
            response.data['transactions'] as List<dynamic>;
        return txns.take(10).map((json) {
          final map = Map<String, dynamic>.from(json as Map);
          return CashbackOffer(
            id: map['id']?.toString() ?? '',
            title: 'Cashback',
            description: map['description']?.toString() ?? 'Wallet cashback',
            expiryDate: DateTime.now().add(const Duration(days: 30)),
            category: 'cashback',
            terms: 'Auto-applied cashback',
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Error fetching cashback offers: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> findUserByPhone(String phone) async {
    try {
      final response = await _dio.get('/wallet/lookup', queryParameters: {
        'phone': phone,
      });
      if (response.statusCode == 200 && response.data is Map) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error looking up user: $e');
    }
    return null;
  }

  Future<bool> transferMoney(TransferRequest request) async {
    try {
      final response =
          await _dio.post('/wallet/transfers', data: request.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        await getBalance();
        return true;
      }
    } catch (e) {
      debugPrint('Error transferring money: $e');
    }
    return false;
  }

  Future<String?> downloadTransactionInvoice(String transactionId) async {
    // TODO: Backend does not generate wallet transaction PDFs yet.
    debugPrint(
        'Wallet transaction invoices are not supported by the backend yet.');
    return null;
  }

  Future<String?> downloadRentalInvoice(String rentalId) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/rental_invoice_$rentalId.pdf';

      final response = await _dio.get('/rentals/$rentalId/receipt');
      final receiptUrl = response.data['receipt_url'];

      if (receiptUrl != null) {
        final downloadUrl = receiptUrl.toString().startsWith('http')
            ? receiptUrl
            : '${_dio.options.baseUrl}$receiptUrl';

        await _dio.download(downloadUrl, filePath);
        return filePath;
      }
      return null;
    } on DioException catch (e) {
      debugPrint('Error downloading rental invoice: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error downloading rental invoice: $e');
      return null;
    }
  }
}
