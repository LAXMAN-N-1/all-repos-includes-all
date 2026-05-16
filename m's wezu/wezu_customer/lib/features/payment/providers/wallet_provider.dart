import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/wallet_service.dart';
import '../models/transaction.dart';
import '../models/payment_models.dart';
import '../models/withdrawal_request.dart';
import '../../../core/network/dio_provider.dart';

class WalletState {
  static const Object _unset = Object();

  final double balance;
  final List<Transaction> transactions;
  final List<SavedPaymentMethod> savedMethods;
  final List<CashbackOffer> offers;
  final bool isLoading;
  final String? error;

  WalletState({
    this.balance = 0.0,
    this.transactions = const [],
    this.savedMethods = const [],
    this.offers = const [],
    this.isLoading = false,
    this.error,
  });

  WalletState copyWith({
    double? balance,
    List<Transaction>? transactions,
    List<SavedPaymentMethod>? savedMethods,
    List<CashbackOffer>? offers,
    bool? isLoading,
    Object? error = _unset,
  }) {
    return WalletState(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      savedMethods: savedMethods ?? this.savedMethods,
      offers: offers ?? this.offers,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  final WalletService _service;
  Future<void>? _refreshInFlight;

  WalletNotifier(this._service) : super(WalletState()) {
    refreshAll();
  }

  Future<void> refreshAll() async {
    if (_refreshInFlight != null) {
      return _refreshInFlight!;
    }

    final refresh = _refreshAllInternal();
    _refreshInFlight = refresh;
    try {
      await refresh;
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<void> _refreshAllInternal() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final balance = await _service.getBalance();
      final txns = await _service.getTransactionHistory();
      // Mocking methods and offers for now until service is fully updated
      final methods = await _service.getSavedMethods();
      final offers = await _service.getCashbackOffers();

      state = state.copyWith(
        balance: balance,
        transactions: txns,
        savedMethods: methods,
        offers: offers,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> withdraw(WithdrawalRequest request) async {
    final success = await _service.withdrawFunds(request);
    if (success) {
      await refreshAll();
    }
    return success;
  }

  Future<bool> transfer(TransferRequest request) async {
    final success = await _service.transferMoney(request);
    if (success) {
      await refreshAll();
    }
    return success;
  }

  Future<bool> pay(double amount, {String? description}) async {
    final success = await _service.pay(amount, description: description);
    if (success) {
      await refreshAll();
    }
    return success;
  }

  Future<bool> topUp(double amount, PaymentMethod method) async {
    final success = await _service.topUp(amount, method);
    if (success) {
      await refreshAll();
    }
    return success;
  }

  void updateBalance(double newBalance) {
    state = state.copyWith(balance: newBalance);
  }
}

final walletProvider =
    StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return WalletNotifier(WalletService(dio));
});
