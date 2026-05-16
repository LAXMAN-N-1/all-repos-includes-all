import 'package:flutter/material.dart';
import '../../../models/withdrawal_model.dart';
import '../../../repositories/wallet_repository.dart';
import 'wallet_view_model.dart';

enum WithdrawPaymentMode { bank, upi }

enum WithdrawStatus { idle, loading, success, failure }

/// Status for the UPI verification step.
enum UpiVerifyStatus { idle, verifying, verified, failed }

class WithdrawToBankViewModel extends ChangeNotifier {
  static const double minWithdrawalAmount = 100.0;
  static const double maxWithdrawalAmount = 50000.0;

  final WalletRepository _walletRepository;

  // ── Core state ─────────────────────────────────────────────────────────────
  WithdrawPaymentMode _paymentMode = WithdrawPaymentMode.bank;
  WithdrawStatus _status = WithdrawStatus.idle;
  String _errorMessage = '';
  WithdrawalErrorType? _errorType;
  Map<String, String> _fieldErrors = {};
  WithdrawalResponse? _lastResponse;

  // ── IFSC lookup state ──────────────────────────────────────────────────────
  String _resolvedBankName = '';
  bool _isLookingUpBank = false;
  String _lastLookedUpIfsc = '';

  // ── UPI verify state ───────────────────────────────────────────────────────
  UpiVerifyStatus _upiVerifyStatus = UpiVerifyStatus.idle;

  WithdrawToBankViewModel({required WalletRepository walletRepository})
    : _walletRepository = walletRepository;

  // ── Public getters ─────────────────────────────────────────────────────────

  WithdrawPaymentMode get paymentMode => _paymentMode;
  WithdrawStatus get status => _status;
  bool get isLoading => _status == WithdrawStatus.loading;
  String get errorMessage => _errorMessage;
  WithdrawalErrorType? get errorType => _errorType;
  Map<String, String> get fieldErrors => _fieldErrors;
  WithdrawalResponse? get lastResponse => _lastResponse;

  // IFSC lookup
  String get resolvedBankName => _resolvedBankName;
  bool get isLookingUpBank => _isLookingUpBank;

  // UPI
  UpiVerifyStatus get upiVerifyStatus => _upiVerifyStatus;
  bool get isUpiVerified => _upiVerifyStatus == UpiVerifyStatus.verified;
  bool get isVerifyingUpi => _upiVerifyStatus == UpiVerifyStatus.verifying;

  bool get isRetryable =>
      _errorType == WithdrawalErrorType.network ||
      _errorType == WithdrawalErrorType.timeout ||
      _errorType == WithdrawalErrorType.serverError;

  bool get isNetworkError => _errorType == WithdrawalErrorType.network;
  bool get isTimeoutError => _errorType == WithdrawalErrorType.timeout;

  // ── Setters ────────────────────────────────────────────────────────────────

  void setPaymentMode(WithdrawPaymentMode mode) {
    _paymentMode = mode;
    // Reset UPI verify state when switching modes
    if (mode == WithdrawPaymentMode.bank) {
      _upiVerifyStatus = UpiVerifyStatus.idle;
    }
    notifyListeners();
  }

  void resetStatus() {
    _status = WithdrawStatus.idle;
    _errorMessage = '';
    _errorType = null;
    _fieldErrors = {};
    _lastResponse = null;
    notifyListeners();
  }

  // ── IFSC Lookup ────────────────────────────────────────────────────────────

  /// Looks up the bank name for [ifsc] via the Razorpay public API.
  /// No-ops if already looked up or IFSC is incomplete.
  Future<void> lookupBankName(String ifsc) async {
    final clean = ifsc.trim().toUpperCase();
    // Only query when IFSC is complete (11 chars) and hasn't been fetched yet
    if (clean.length != 11 || clean == _lastLookedUpIfsc) return;

    _isLookingUpBank = true;
    _resolvedBankName = '';
    notifyListeners();

    final bankName = await _walletRepository.lookupBankName(clean);

    _lastLookedUpIfsc = clean;
    _resolvedBankName = bankName ?? '';
    _isLookingUpBank = false;
    notifyListeners();
  }

  void clearBankLookup() {
    _resolvedBankName = '';
    _lastLookedUpIfsc = '';
    _isLookingUpBank = false;
    notifyListeners();
  }

  // ── UPI Verification ───────────────────────────────────────────────────────

  /// Verifies [upiId] against a mock (or real) UPI lookup.
  /// Uses a 1 s simulated delay. Replace with real API when available.
  Future<void> verifyUpi(String upiId) async {
    final clean = upiId.trim();
    if (!_isValidUpiFormat(clean)) {
      _upiVerifyStatus = UpiVerifyStatus.failed;
      notifyListeners();
      return;
    }

    _upiVerifyStatus = UpiVerifyStatus.verifying;
    notifyListeners();

    // TODO: replace with real UPI validation API call
    await Future.delayed(const Duration(milliseconds: 1200));

    // Mock logic: treat any properly-formatted UPI as valid
    _upiVerifyStatus = UpiVerifyStatus.verified;
    notifyListeners();
  }

  void resetUpiVerification() {
    _upiVerifyStatus = UpiVerifyStatus.idle;
    notifyListeners();
  }

  // ── Local Validation ──────────────────────────────────────────────────────

  String? validateAmount(String? value, double balance) {
    if (value == null || value.trim().isEmpty) return 'Please enter an amount';
    final amount = double.tryParse(value.trim());
    if (amount == null) return 'Enter a valid number';
    if (amount < minWithdrawalAmount) {
      return 'Minimum withdrawal is ₹${minWithdrawalAmount.toStringAsFixed(0)}';
    }
    if (amount > maxWithdrawalAmount) {
      return 'Maximum withdrawal is ₹${maxWithdrawalAmount.toStringAsFixed(0)}';
    }
    if (amount > balance) {
      return 'Insufficient balance (available: ₹${balance.toStringAsFixed(2)})';
    }
    return null;
  }

  String? validateAccountHolderName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter account holder name';
    }
    if (value.trim().length < 3) return 'Name must be at least 3 characters';
    if (!RegExp(r"^[a-zA-Z\s'.\-]+$").hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? validateAccountNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter account number';
    }
    if (!RegExp(r'^\d{9,18}$').hasMatch(value.trim())) {
      return 'Enter a valid 9–18 digit account number';
    }
    return null;
  }

  String? validateConfirmAccountNumber(String? value, String accountNumber) {
    if (value == null || value.trim().isEmpty) {
      return 'Please confirm account number';
    }
    if (value.trim() != accountNumber.trim()) {
      return 'Account numbers do not match';
    }
    return null;
  }

  String? validateIFSC(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter IFSC code';
    if (!RegExp(
      r'^[A-Z]{4}0[A-Z0-9]{6}$',
    ).hasMatch(value.trim().toUpperCase())) {
      return 'Enter a valid IFSC code (e.g. HDFC0001234)';
    }
    return null;
  }

  String? validateUPI(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter UPI ID';
    if (!_isValidUpiFormat(value.trim())) {
      return 'Enter a valid UPI ID (e.g. name@upi)';
    }
    if (_upiVerifyStatus == UpiVerifyStatus.failed) {
      return 'UPI verification failed. Please check the ID and try again.';
    }
    if (!isUpiVerified) {
      return 'Please verify your UPI ID before proceeding';
    }
    return null;
  }

  bool _isValidUpiFormat(String value) =>
      RegExp(r'^[\w.\-]{2,256}@[a-zA-Z]{2,64}$').hasMatch(value);

  // ── Pre-submit guard ───────────────────────────────────────────────────────

  String? canSubmit(double amount, double balance) {
    if (amount <= 0) return 'Please enter a valid amount';
    if (amount < minWithdrawalAmount) {
      return 'Minimum withdrawal is ₹${minWithdrawalAmount.toStringAsFixed(0)}';
    }
    if (amount > maxWithdrawalAmount) {
      return 'Maximum withdrawal is ₹${maxWithdrawalAmount.toStringAsFixed(0)}';
    }
    if (amount > balance) {
      return 'Your wallet balance (₹${balance.toStringAsFixed(2)}) is insufficient.';
    }
    return null;
  }

  // ── Submission ─────────────────────────────────────────────────────────────

  Future<WithdrawalResponse> submitWithdrawal({
    required double amount,
    required WalletViewModel walletViewModel,
    required WalletRepository walletRepository,
    String? accountHolderName,
    String? accountNumber,
    String? ifscCode,
    String? bankName,
    String? upiId,
  }) async {
    final balanceError = canSubmit(amount, walletViewModel.balance);
    if (balanceError != null) {
      final response = WithdrawalResponse.insufficientBalanceError();
      _setFailure(response);
      return response;
    }

    _status = WithdrawStatus.loading;
    _errorMessage = '';
    _errorType = null;
    _fieldErrors = {};
    notifyListeners();

    final request = WithdrawalRequest(
      amount: amount,
      paymentMode: _paymentMode == WithdrawPaymentMode.bank ? 'bank' : 'upi',
      accountHolderName: accountHolderName,
      accountNumber: accountNumber,
      bankName: bankName,
      ifscCode: ifscCode,
      upiId: upiId,
    );

    final response = await _walletRepository.withdraw(request);

    if (response.success) {
      // Apply withdrawal: prefer server's authoritative remaining balance when
      // available; fall back to local optimistic deduction.
      walletViewModel.applyWithdrawal(
        amount: amount,
        method: _paymentMode == WithdrawPaymentMode.bank ? 'bank' : 'upi',
        transactionId: response.transactionId,
        serverRemainingBalance: response.remainingBalance,
      );

      // Fire-and-forget: reconcile balance from server in the background.
      // This self-corrects any drift without blocking the success flow.
      walletViewModel.refreshBalanceFromServer(walletRepository);

      _status = WithdrawStatus.success;
      _lastResponse = response;
    } else {
      _setFailure(response);
    }

    notifyListeners();
    return response;
  }

  void _setFailure(WithdrawalResponse response) {
    _status = WithdrawStatus.failure;
    _errorMessage = response.message;
    _errorType = response.errorType;
    _fieldErrors = response.fieldErrors;
    _lastResponse = response;
  }
}
