import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/cashback_offer.dart';
import '../../repositories/wallet_repository.dart';
import '../../services/cashback_service.dart';

// ─── Enums ───────────────────────────────────────────────────────────────────

enum TransactionType { credit, debit }

/// Unified status covering both earnings and withdrawal transactions.
enum TransactionStatus {
  pending, // withdrawal submitted, awaiting review
  approved, // withdrawal approved by admin
  completed, // credit/payout settled
  rejected, // withdrawal denied
  failed, // technical failure
}

/// High-level category used for filter chips.
enum TransactionFilter { all, pending, approved, rejected, credits }

// ─── Models ──────────────────────────────────────────────────────────────────

class WalletTransaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final TransactionStatus status;

  /// True when this transaction was created by a bank/UPI withdrawal request.
  final bool isWithdrawal;

  /// 'bank' | 'upi' | null for non-withdrawal transactions.
  final String? withdrawalMethod;

  // ── Destination details (bank withdrawals) ──────────────────────────────
  final String? bankName;
  final String? accountNumber;
  final String? accountHolder;
  final String? ifscCode;

  // ── Destination detail (UPI withdrawals) ───────────────────────────────
  final String? upiId;

  WalletTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.status,
    this.isWithdrawal = false,
    this.withdrawalMethod,
    this.bankName,
    this.accountNumber,
    this.accountHolder,
    this.ifscCode,
    this.upiId,
  });

  String get formattedAmount {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final value = formatter.format(amount);
    return type == TransactionType.debit ? '-$value' : '+$value';
  }

  String get formattedDate => DateFormat('MMM d, yyyy').format(date);

  /// Human-readable status label.
  String get statusLabel {
    switch (status) {
      case TransactionStatus.pending:
        return 'PENDING';
      case TransactionStatus.approved:
        return 'APPROVED';
      case TransactionStatus.completed:
        return 'COMPLETED';
      case TransactionStatus.rejected:
        return 'REJECTED';
      case TransactionStatus.failed:
        return 'FAILED';
    }
  }

  /// Status chip colour.
  Color get statusColor {
    switch (status) {
      case TransactionStatus.pending:
        return const Color(0xFFFFA726); // amber
      case TransactionStatus.approved:
        return const Color(0xFF1565C0); // blue
      case TransactionStatus.completed:
        return const Color(0xFF2E7D32); // green
      case TransactionStatus.rejected:
        return const Color(0xFFC62828); // red
      case TransactionStatus.failed:
        return Colors.grey;
    }
  }
}

class BankAccount {
  final String id;
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final bool isPrimary;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    this.isPrimary = false,
  });
}

// ─── ViewModel ───────────────────────────────────────────────────────────────

class WalletViewModel extends ChangeNotifier {
  double _balance = 2000.00;
  List<WalletTransaction> _transactions = [];
  List<BankAccount> _bankAccounts = [];
  List<CashbackOffer> _offers = [];
  bool _isLoading = false;
  bool _offersLoading = false;
  TransactionFilter _activeFilter = TransactionFilter.all;

  double get balance => _balance;
  List<BankAccount> get bankAccounts => _bankAccounts;
  List<CashbackOffer> get offers => _offers;
  bool get isLoading => _isLoading;
  bool get offersLoading => _offersLoading;
  TransactionFilter get activeFilter => _activeFilter;

  /// All transactions, unfiltered.
  List<WalletTransaction> get transactions => _transactions;

  /// Filtered view consumed by the UI.
  List<WalletTransaction> get filteredTransactions {
    switch (_activeFilter) {
      case TransactionFilter.all:
        return _transactions;
      case TransactionFilter.pending:
        return _transactions
            .where((t) => t.status == TransactionStatus.pending)
            .toList();
      case TransactionFilter.approved:
        return _transactions
            .where((t) => t.status == TransactionStatus.approved)
            .toList();
      case TransactionFilter.rejected:
        return _transactions
            .where((t) => t.status == TransactionStatus.rejected)
            .toList();
      case TransactionFilter.credits:
        return _transactions
            .where((t) => t.type == TransactionType.credit)
            .toList();
    }
  }

  bool _hasLoadedData = false;

  WalletViewModel() {
    _loadMockData();
  }

  bool get hasLoadedData => _hasLoadedData;

  void setFilter(TransactionFilter filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  /// Called after a successful withdrawal API response.
  ///
  /// When the server returns [serverRemainingBalance] it is used as-is
  /// (authoritative). Otherwise the balance is decremented locally
  /// (optimistic update) — the UI will self-correct on the next
  /// [refreshBalanceFromServer] call.
  void applyWithdrawal({
    required double amount,
    required String method, // 'bank' or 'upi'
    String? transactionId,
    double? serverRemainingBalance, // from WithdrawalResponse.remainingBalance
  }) {
    if (amount > _balance) return; // Safety guard
    _balance = serverRemainingBalance ?? (_balance - amount);
    _transactions.insert(
      0,
      WalletTransaction(
        id: transactionId ?? 'WD${DateTime.now().millisecondsSinceEpoch}',
        title: method == 'upi' ? 'Withdraw via UPI' : 'Withdraw to Bank',
        amount: amount,
        date: DateTime.now(),
        type: TransactionType.debit,
        status: TransactionStatus.pending,
        isWithdrawal: true,
        withdrawalMethod: method,
      ),
    );
    notifyListeners();
  }

  /// Directly sets [_balance] to the server-authoritative value.
  /// Call this after any API response that includes the definitive balance
  /// (e.g. GET /wallet/balance or a withdrawal response with remaining_balance).
  void syncBalance(double serverBalance) {
    if (_balance == serverBalance) return; // no-op if already in sync
    _balance = serverBalance;
    notifyListeners();
  }

  /// Fires GET /wallet/balance and reconciles the local balance.
  /// Safe to call at any time — no-ops silently on network failure.
  Future<void> refreshBalanceFromServer(WalletRepository repo) async {
    final serverBalance = await repo.fetchBalance();
    if (serverBalance != null) syncBalance(serverBalance);
  }

  /// Fetches cashback offers from the server (or mock).
  Future<void> fetchOffers({String authToken = ''}) async {
    if (_offersLoading) return;
    _offersLoading = true;
    notifyListeners();
    try {
      final service = CashbackService();
      _offers = await service.fetchOffers(authToken);
      service.dispose();
    } catch (_) {
      _offers = [];
    } finally {
      _offersLoading = false;
      notifyListeners();
    }
  }

  /// Called after a successful peer transfer.
  /// Deducts [amount] from balance and inserts a new debit transaction.
  void applyTransferResult({
    required double amount,
    required double newBalance,
    required String transactionId,
    required String recipientName,
    String note = '',
  }) {
    _balance = newBalance;
    _transactions.insert(
      0,
      WalletTransaction(
        id: transactionId,
        title: 'Sent to $recipientName${note.isNotEmpty ? ' · $note' : ''}',
        amount: amount,
        date: DateTime.now(),
        type: TransactionType.debit,
        status: TransactionStatus.completed,
      ),
    );
    notifyListeners();
  }

  /// Re-fetches wallet data from the API (or mock).
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    // TODO: replace with real API call
    await Future.delayed(const Duration(milliseconds: 800));
    _isLoading = false;
    notifyListeners();
    await fetchOffers();
  }

  /// Called on logout to wipe all wallet state.
  /// Next login will trigger a fresh _loadMockData (or real API fetch).
  void resetForLogout() {
    _balance = 0;
    _transactions = [];
    _bankAccounts = [];
    _offers = [];
    _activeFilter = TransactionFilter.all;
    _hasLoadedData = false;
    _isLoading = false;
    _offersLoading = false;
    notifyListeners();
  }

  void _loadMockData() {
    if (_hasLoadedData) return; // Don't reload if already hydrated
    _isLoading = true;
    notifyListeners();

    _bankAccounts = [
      BankAccount(
        id: '1',
        bankName: 'HDFC Bank',
        accountNumber: '**** **** 1234',
        accountHolderName: 'Bindu P',
        isPrimary: true,
      ),
    ];

    _transactions = [
      // ── Withdrawals with varied statuses ──────────────────────────────────
      WalletTransaction(
        id: 'WD001',
        title: 'Withdraw to HDFC Bank',
        amount: 500.00,
        date: DateTime.now().subtract(const Duration(hours: 3)),
        type: TransactionType.debit,
        status: TransactionStatus.pending,
        isWithdrawal: true,
        withdrawalMethod: 'bank',
        bankName: 'HDFC Bank',
        accountNumber: '**** **** **** 1234',
        accountHolder: 'Bindu P',
        ifscCode: 'HDFC0001234',
      ),
      WalletTransaction(
        id: 'WD002',
        title: 'Withdraw via UPI',
        amount: 250.00,
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: TransactionType.debit,
        status: TransactionStatus.approved,
        isWithdrawal: true,
        withdrawalMethod: 'upi',
        upiId: 'bindu@okhdfc',
        accountHolder: 'Bindu P',
      ),
      WalletTransaction(
        id: 'WD003',
        title: 'Withdraw to SBI',
        amount: 1000.00,
        date: DateTime.now().subtract(const Duration(days: 3)),
        type: TransactionType.debit,
        status: TransactionStatus.rejected,
        isWithdrawal: true,
        withdrawalMethod: 'bank',
        bankName: 'State Bank of India',
        accountNumber: '**** **** **** 5678',
        accountHolder: 'Bindu P',
        ifscCode: 'SBIN0005678',
      ),
      WalletTransaction(
        id: 'WD004',
        title: 'Withdraw to HDFC Bank',
        amount: 3000.00,
        date: DateTime.now().subtract(const Duration(days: 7)),
        type: TransactionType.debit,
        status: TransactionStatus.completed,
        isWithdrawal: true,
        withdrawalMethod: 'bank',
        bankName: 'HDFC Bank',
        accountNumber: '**** **** **** 1234',
        accountHolder: 'Bindu P',
        ifscCode: 'HDFC0001234',
      ),
      // ── Earnings / credits ─────────────────────────────────────────────────
      WalletTransaction(
        id: 'TXN001',
        title: 'Order Earnings #1234',
        amount: 120.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: TransactionType.credit,
        status: TransactionStatus.completed,
      ),
      WalletTransaction(
        id: 'TXN002',
        title: 'Bonus Reward',
        amount: 50.0,
        date: DateTime.now().subtract(const Duration(days: 2)),
        type: TransactionType.credit,
        status: TransactionStatus.completed,
      ),
      WalletTransaction(
        id: 'TXN003',
        title: 'Order Earnings #1198',
        amount: 95.0,
        date: DateTime.now().subtract(const Duration(days: 4)),
        type: TransactionType.credit,
        status: TransactionStatus.completed,
      ),
    ];

    _isLoading = false;
    _hasLoadedData = true;
    notifyListeners();
  }

  /// Legacy method kept for PayoutRequestScreen compatibility.
  /// New withdrawal flow uses [applyWithdrawal] directly.
  Future<bool> requestPayout(double amount, String bankAccountId) async {
    if (amount > _balance) return false;
    // No API call here — apply balance change synchronously
    _balance -= amount;
    _transactions.insert(
      0,
      WalletTransaction(
        id: 'WD${DateTime.now().millisecondsSinceEpoch}',
        title: bankAccountId == 'upi-transfer'
            ? 'Withdraw via UPI'
            : 'Withdraw to Bank',
        amount: amount,
        date: DateTime.now(),
        type: TransactionType.debit,
        status: TransactionStatus.pending,
        isWithdrawal: true,
        withdrawalMethod: bankAccountId == 'upi-transfer' ? 'upi' : 'bank',
      ),
    );
    notifyListeners();
    return true;
  }

  void addBankAccount(BankAccount account) {
    _bankAccounts.add(account);
    notifyListeners();
  }
}
