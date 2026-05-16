import '../../data/models/payment/payment_model.dart';

abstract class IPaymentRepository {
  Future<PaymentModel> processPayment(double amount, String method, String bookingId);
  Future<List<PaymentModel>> getPaymentHistory();
}
