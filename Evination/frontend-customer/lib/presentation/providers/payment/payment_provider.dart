import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/payment/payment_model.dart';
import '../../../data/repositories/payment_repository_impl.dart';

// State for a single payment process
class PaymentState {
  final bool isLoading;
  final String? error;
  final PaymentModel? result;

  PaymentState({this.isLoading = false, this.error, this.result});
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  final Ref ref;

  PaymentNotifier(this.ref) : super(PaymentState());

  Future<void> processPayment({
    required double amount,
    required String method,
    required String bookingId,
  }) async {
    state = PaymentState(isLoading: true);
    try {
      final repository = ref.read(paymentRepositoryProvider);
      final result = await repository.processPayment(amount, method, bookingId);
      state = PaymentState(result: result);
    } catch (e) {
      state = PaymentState(error: e.toString());
    }
  }
}

final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  return PaymentNotifier(ref);
});

final paymentHistoryProvider = FutureProvider<List<PaymentModel>>((ref) async {
  final repository = ref.watch(paymentRepositoryProvider);
  return repository.getPaymentHistory();
});
