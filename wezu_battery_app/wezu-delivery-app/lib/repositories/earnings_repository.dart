import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../services/api_service.dart';

class EarningsRepository extends ChangeNotifier {
  final ApiService _api;

  double _totalBalance = 0.0;
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  double get totalBalance => _totalBalance;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  EarningsRepository({required ApiService api}) : _api = api {
    _load();
  }

  Future<void> _load() async {
    await Future.wait([fetchBalance(), fetchTransactions(Timeframe.monthly)]);
  }

  /// GET /wallet/balance
  Future<void> fetchBalance() async {
    try {
      final data = await _api.get('/wallet/balance');
      final raw = data['balance'] ?? data['data']?['balance'] ?? data['wallet_balance'];
      if (raw != null) {
        _totalBalance = (raw as num).toDouble();
        notifyListeners();
      }
    } on ApiException {
      // Network error: keep existing balance
    }
  }

  /// GET /wallet/transactions  (or /transactions/ if wallet endpoint differs)
  Future<void> fetchTransactions(Timeframe timeframe) async {
    _isLoading = true;
    notifyListeners();
    try {
      final list = await _api.getList('/wallet/transactions', queryParams: {
        'timeframe': _timeframeParam(timeframe),
        'limit': '50',
      });
      _transactions = list
          .whereType<Map<String, dynamic>>()
          .map(_mapTransaction)
          .toList();
    } on ApiException {
      // keep existing
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Transaction _mapTransaction(Map<String, dynamic> json) {
    final isCredit = (json['transaction_type']?.toString() ?? 'credit') != 'debit';
    DateTime date;
    try {
      date = DateTime.parse(json['created_at']?.toString() ?? '');
    } catch (_) {
      date = DateTime.now();
    }
    return Transaction(
      title: json['description']?.toString() ?? json['title']?.toString() ?? 'Transaction',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: date,
      type: isCredit ? TransactionType.credit : TransactionType.debit,
    );
  }

  String _timeframeParam(Timeframe t) {
    switch (t) {
      case Timeframe.daily:
        return 'daily';
      case Timeframe.weekly:
        return 'weekly';
      case Timeframe.monthly:
        return 'monthly';
    }
  }
}
