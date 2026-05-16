import 'package:flutter/foundation.dart';
import '../models/withdrawal_model.dart';
import '../services/wallet_service.dart';

/// Repository that mediates between the UI/ViewModel and [WalletService].
/// Manages the auth token and exposes a clean [withdraw] method.
class WalletRepository extends ChangeNotifier {
  final WalletService _walletService;

  /// Auth token used for API calls.
  /// Update this via [setAuthToken] once the user logs in.
  String _authToken = '';

  WalletRepository({WalletService? walletService})
    : _walletService = walletService ?? WalletService();

  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Submits a withdrawal request to POST /wallet/withdraw.
  ///
  /// Returns a [WithdrawalResponse] describing success or failure.
  Future<WithdrawalResponse> withdraw(WithdrawalRequest request) async {
    return _walletService.withdraw(request: request, authToken: _authToken);
  }

  /// Looks up the bank name for a given IFSC code via the Razorpay public API.
  /// Returns the bank name string, or null if the IFSC is invalid / offline.
  Future<String?> lookupBankName(String ifsc) {
    return _walletService.lookupBankName(ifsc);
  }

  /// Fetches the server-authoritative wallet balance.
  /// Returns null when offline or server returned an error — callers degrade
  /// gracefully (balance already updated optimistically via [applyWithdrawal]).
  Future<double?> fetchBalance() {
    return _walletService.fetchWalletBalance(_authToken);
  }

  @override
  void dispose() {
    _walletService.dispose();
    super.dispose();
  }
}
