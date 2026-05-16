import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/i_payment_repository.dart';
import '../models/payment/payment_model.dart';
import 'package:uuid/uuid.dart';

class PaymentRepositoryImpl implements IPaymentRepository {
  @override
  Future<PaymentModel> processPayment(double amount, String method, String bookingId) async {
    await Future.delayed(const Duration(seconds: 1));
    return PaymentModel(
      id: const Uuid().v4(),
      bookingId: bookingId,
      amount: amount,
      currency: 'INR',
      status: 'Completed',
      paymentMethod: method,
      transactionDate: DateTime.now(),
      transactionReference: 'TXN${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<List<PaymentModel>> getPaymentHistory() async {
    return [];
  }
}

final paymentRepositoryProvider = Provider<IPaymentRepository>((ref) {
  return PaymentRepositoryImpl();
});
