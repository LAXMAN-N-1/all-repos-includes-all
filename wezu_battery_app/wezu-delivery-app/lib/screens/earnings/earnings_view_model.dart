import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../repositories/earnings_repository.dart';

class EarningsViewModel extends ChangeNotifier {
  final EarningsRepository _earningsRepository;
  Timeframe _selectedTimeframe = Timeframe.weekly;
  bool _isLoading = false;

  EarningsViewModel({required EarningsRepository earningsRepository})
    : _earningsRepository = earningsRepository {
    _earningsRepository.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _earningsRepository.removeListener(notifyListeners);
    super.dispose();
  }

  double get totalBalance => _earningsRepository.totalBalance;
  List<Transaction> get transactions => _earningsRepository.transactions;
  Timeframe get selectedTimeframe => _selectedTimeframe;
  bool get isLoading => _isLoading;

  void setTimeframe(Timeframe timeframe) async {
    if (_selectedTimeframe == timeframe) return;
    _selectedTimeframe = timeframe;
    _isLoading = true;
    notifyListeners();

    await _earningsRepository.fetchTransactions(
      timeframe,
    ); // This is mock for now

    _isLoading = false;
    notifyListeners();
  }
}
