import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../models/withdrawal_model.dart';
import '../../../repositories/wallet_repository.dart';
import '../../../services/security_service.dart';
import 'wallet_view_model.dart';
import 'withdraw_otp_sheet.dart';
import 'withdraw_to_bank_view_model.dart';

class WithdrawToBankScreen extends StatelessWidget {
  const WithdrawToBankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletRepo = context.read<WalletRepository>();
    return ChangeNotifierProvider(
      create: (_) => WithdrawToBankViewModel(walletRepository: walletRepo),
      child: const _WithdrawToBankBody(),
    );
  }
}

class _WithdrawToBankBody extends StatefulWidget {
  const _WithdrawToBankBody();

  @override
  State<_WithdrawToBankBody> createState() => _WithdrawToBankBodyState();
}

class _WithdrawToBankBodyState extends State<_WithdrawToBankBody> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _holderNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _confirmAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _upiController = TextEditingController();

  final _securityService = SecurityService();

  /// Server-side field errors from 422 responses — shown inline.
  Map<String, String> _serverFieldErrors = {};

  /// Stores the last submit data for retry.
  WithdrawToBankViewModel? _lastVm;
  WalletViewModel? _lastWalletVm;

  bool _amountPreFilled = false;
  String? _selectedBank; // for bank selector

  static const _accent = Color(0xFFFD802E);
  static const _dark = Color(0xFF233D4C);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-fill the amount with full balance on first render
    if (!_amountPreFilled) {
      final balance = context.read<WalletViewModel>().balance;
      if (balance > 0) {
        _amountController.text = balance.toStringAsFixed(2);
      }
      _amountPreFilled = true;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _holderNameController.dispose();
    _accountNumberController.dispose();
    _confirmAccountController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _amountController.clear();
    _holderNameController.clear();
    _accountNumberController.clear();
    _confirmAccountController.clear();
    _ifscController.clear();
    _bankNameController.clear();
    _upiController.clear();
    setState(() {
      _serverFieldErrors = {};
      _selectedBank = null;
    });
  }

  // ─── IFSC Lookup ───────────────────────────────────────────────────────────

  void _onIfscChanged(String value, WithdrawToBankViewModel vm) {
    // Clear resolved bank name if user is editing
    if (value.trim().toUpperCase() != vm.resolvedBankName) {
      _bankNameController.clear();
    }
    // Trigger lookup when 11 chars entered
    if (value.trim().length == 11) {
      vm.lookupBankName(value.trim()).then((_) {
        if (mounted && vm.resolvedBankName.isNotEmpty) {
          _bankNameController.text = vm.resolvedBankName;
        }
      });
    }
  }

  // ─── Confirmation + Biometric flow ────────────────────────────────────────

  Future<bool> _showConfirmationDialog({
    required BuildContext context,
    required double amount,
    required WithdrawToBankViewModel vm,
  }) async {
    final isBankMode = vm.paymentMode == WithdrawPaymentMode.bank;
    final acct = _accountNumberController.text.trim();
    final masked = acct.length >= 4
        ? '••••${acct.substring(acct.length - 4)}'
        : '••••';

    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send_to_mobile_rounded,
                    color: _accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Confirm Withdrawal',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please verify the details before proceeding.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 16),
                _ConfirmRow(
                  label: 'Amount',
                  value: '₹${amount.toStringAsFixed(2)}',
                  valueColor: _accent,
                ),
                _ConfirmRow(
                  label: 'Method',
                  value: isBankMode ? 'Bank Transfer' : 'UPI',
                ),
                if (isBankMode) ...[
                  _ConfirmRow(
                    label: 'Holder',
                    value: _holderNameController.text.trim(),
                  ),
                  _ConfirmRow(label: 'Account', value: masked),
                  _ConfirmRow(
                    label: 'IFSC',
                    value: _ifscController.text.trim().toUpperCase(),
                  ),
                  if (_bankNameController.text.isNotEmpty)
                    _ConfirmRow(
                      label: 'Bank',
                      value: _bankNameController.text.trim(),
                    ),
                ] else
                  _ConfirmRow(
                    label: 'UPI ID',
                    value: _upiController.text.trim(),
                  ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 15,
                        color: Colors.amber[800],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You will be asked to confirm with biometrics or PIN.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.amber[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.lock_open_rounded, size: 16),
                label: const Text('Confirm & Authenticate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Triggers biometric / device-PIN auth.
  /// Returns true only if authentication succeeds.
  Future<bool> _authenticateUser(BuildContext ctx) async {
    try {
      final ok = await _securityService.authenticateForWithdrawal();
      if (!ok && mounted) {
        _showErrorBanner(
          ctx,
          'Authentication cancelled. Withdrawal not submitted.',
        );
      }
      return ok;
    } on SecurityAuthException catch (e) {
      if (!mounted) return false;
      if (e.isNotEnrolled) {
        _showErrorBanner(
          ctx,
          'No biometric or PIN set up on this device. '
          'Please enable screen lock in Settings to withdraw.',
        );
      } else {
        _showErrorBanner(ctx, 'Authentication failed. Please try again.');
      }
      return false;
    }
  }

  // ─── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit(
    BuildContext ctx,
    WithdrawToBankViewModel vm,
    WalletViewModel walletVM,
  ) async {
    setState(() => _serverFieldErrors = {});
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) return;

    final balanceError = vm.canSubmit(amount, walletVM.balance);
    if (balanceError != null) {
      _showErrorBanner(ctx, balanceError);
      return;
    }

    _lastVm = vm;
    _lastWalletVm = walletVM;

    // Step 1 — Summary confirmation
    if (!mounted) return;
    final confirmed = await _showConfirmationDialog(
      context: ctx,
      amount: amount,
      vm: vm,
    );
    if (!mounted || !confirmed) return;

    // Step 2 — Biometric / PIN authentication
    final authenticated = await _authenticateUser(ctx);
    if (!mounted || !authenticated) return;

    // Step 3 — OTP verification
    final otpVerified = await showModalBottomSheet<bool>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => WithdrawOtpSheet(
        maskedPhone: '+91 ****9876', // TODO: replace with real user phone
        amount: amount,
      ),
    );
    if (!mounted || otpVerified != true) {
      if (mounted && otpVerified == null) {
        _showErrorBanner(ctx, 'OTP not verified. Withdrawal cancelled.');
      }
      return;
    }

    final isBankMode = vm.paymentMode == WithdrawPaymentMode.bank;
    final walletRepo = context.read<WalletRepository>();

    final response = await vm.submitWithdrawal(
      amount: amount,
      walletViewModel: walletVM,
      walletRepository: walletRepo,
      accountHolderName: isBankMode ? _holderNameController.text.trim() : null,
      accountNumber: isBankMode ? _accountNumberController.text.trim() : null,
      ifscCode: isBankMode ? _ifscController.text.trim().toUpperCase() : null,
      bankName: isBankMode ? _bankNameController.text.trim() : null,
      upiId: !isBankMode ? _upiController.text.trim() : null,
    );

    if (!mounted) return;

    if (response.success) {
      _resetForm();
      _showSuccessToast(ctx, amount);
    } else {
      _handleFailure(ctx, vm, response);
    }
  }

  Future<void> _retry() async {
    if (_lastVm == null || _lastWalletVm == null) return;
    _lastVm!.resetStatus();
    await _submit(context, _lastVm!, _lastWalletVm!);
  }

  // ─── Failure handling ──────────────────────────────────────────────────────

  void _handleFailure(
    BuildContext ctx,
    WithdrawToBankViewModel vm,
    WithdrawalResponse response,
  ) {
    if (response.isValidationError && response.fieldErrors.isNotEmpty) {
      setState(() => _serverFieldErrors = response.fieldErrors);
      _formKey.currentState?.validate();
    }
    if (response.isNetworkError || response.isTimeoutError) {
      _showNetworkErrorBanner(ctx);
      return;
    }
    _showErrorBanner(ctx, response.message);
  }

  void _showNetworkErrorBanner(BuildContext ctx) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF37474F),
        duration: const Duration(seconds: 8),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: const Row(
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.white70),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'No internet connection. Check your network and try again.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'RETRY',
          textColor: _accent,
          onPressed: _retry,
        ),
      ),
    );
  }

  void _showErrorBanner(BuildContext ctx, String message) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message.isNotEmpty
                    ? message
                    : 'Withdrawal failed. Please try again.',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessToast(BuildContext ctx, double amount) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '₹${amount.toStringAsFixed(2)} withdrawal submitted! '
                'Funds arrive in 2–3 business days.',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WithdrawToBankViewModel>();
    final walletVM = context.watch<WalletViewModel>();
    final isBankMode = vm.paymentMode == WithdrawPaymentMode.bank;
    final balance = walletVM.balance;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Withdraw to Bank'),
        backgroundColor: Colors.white,
        foregroundColor: _dark,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Balance Banner ───────────────────────────────────────────────
              _BalanceBanner(balance: balance),
              const SizedBox(height: 16),

              // ── Zero-balance guard ───────────────────────────────────────────
              if (balance <= 0) ...[
                _InlineBanner(
                  icon: Icons.account_balance_wallet_outlined,
                  message:
                      'Your wallet balance is ₹0.00. '
                      'Complete deliveries to earn before withdrawing.',
                  color: Colors.red[700]!,
                ),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 8),

              // ── Amount ──────────────────────────────────────────────────────
              _SectionLabel(label: 'Withdrawal Amount'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                enabled: balance > 0 && !vm.isLoading,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                onChanged: (_) => _formKey.currentState?.validate(),
                decoration: _inputDecoration(
                  label: 'Enter amount',
                  prefixText: '₹  ',
                  helperText:
                      'Min ₹${WithdrawToBankViewModel.minWithdrawalAmount.toStringAsFixed(0)}'
                      '  •  Max ₹${WithdrawToBankViewModel.maxWithdrawalAmount.toStringAsFixed(0)}'
                      '  •  Available ₹${balance.toStringAsFixed(2)}',
                  serverError: _serverFieldErrors['amount'],
                ),
                validator: (v) {
                  if (_serverFieldErrors.containsKey('amount')) {
                    return _serverFieldErrors['amount'];
                  }
                  return vm.validateAmount(v, balance);
                },
              ),
              const SizedBox(height: 24),

              // ── Payment Mode Toggle ──────────────────────────────────────────
              _SectionLabel(label: 'Transfer Method'),
              const SizedBox(height: 10),
              IgnorePointer(
                ignoring: vm.isLoading,
                child: _PaymentModeToggle(
                  selectedMode: vm.paymentMode,
                  onChanged: (m) {
                    setState(() {
                      _serverFieldErrors = {};
                      _bankNameController.clear();
                    });
                    vm.setPaymentMode(m);
                  },
                ),
              ),
              const SizedBox(height: 24),

              // ── Bank Fields ──────────────────────────────────────────────────
              if (isBankMode) ...[
                _SectionLabel(label: 'Bank Account Details'),
                const SizedBox(height: 12),

                // Account Holder Name
                TextFormField(
                  controller: _holderNameController,
                  enabled: !vm.isLoading,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration(
                    label: 'Account Holder Name',
                    prefixIcon: Icons.person_outline_rounded,
                    serverError: _serverFieldErrors['account_holder_name'],
                  ),
                  validator: (v) {
                    if (_serverFieldErrors.containsKey('account_holder_name')) {
                      return _serverFieldErrors['account_holder_name'];
                    }
                    return vm.validateAccountHolderName(v);
                  },
                ),
                const SizedBox(height: 12),

                // Account Number
                TextFormField(
                  controller: _accountNumberController,
                  enabled: !vm.isLoading,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _inputDecoration(
                    label: 'Account Number',
                    prefixIcon: Icons.account_balance_outlined,
                    serverError: _serverFieldErrors['account_number'],
                  ),
                  validator: (v) {
                    if (_serverFieldErrors.containsKey('account_number')) {
                      return _serverFieldErrors['account_number'];
                    }
                    return vm.validateAccountNumber(v);
                  },
                ),
                const SizedBox(height: 12),

                // Confirm Account Number
                TextFormField(
                  controller: _confirmAccountController,
                  enabled: !vm.isLoading,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _inputDecoration(
                    label: 'Confirm Account Number',
                    prefixIcon: Icons.account_balance_outlined,
                  ),
                  validator: (v) => vm.validateConfirmAccountNumber(
                    v,
                    _accountNumberController.text,
                  ),
                ),
                const SizedBox(height: 12),

                // IFSC (triggers bank-name lookup on change)
                TextFormField(
                  controller: _ifscController,
                  enabled: !vm.isLoading,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                    LengthLimitingTextInputFormatter(11),
                    _UpperCaseTextFormatter(),
                  ],
                  onChanged: (v) => _onIfscChanged(v, vm),
                  onEditingComplete: () {
                    FocusScope.of(context).nextFocus();
                    _onIfscChanged(_ifscController.text, vm);
                  },
                  decoration: _inputDecoration(
                    label: 'IFSC Code',
                    prefixIcon: Icons.code_rounded,
                    helperText: 'e.g. HDFC0001234',
                    serverError: _serverFieldErrors['ifsc_code'],
                    suffixWidget: vm.isLookingUpBank
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  ),
                  validator: (v) {
                    if (_serverFieldErrors.containsKey('ifsc_code')) {
                      return _serverFieldErrors['ifsc_code'];
                    }
                    return vm.validateIFSC(v);
                  },
                ),
                const SizedBox(height: 12),

                // Bank Selector — popular banks quick-chips + full dropdown
                _SectionLabel(label: 'Select Bank'),
                const SizedBox(height: 10),
                _BankSelector(
                  selectedBank: _selectedBank,
                  bankNameController: _bankNameController,
                  resolvedBankName: vm.resolvedBankName,
                  enabled: !vm.isLoading,
                  onBankSelected: (bank) {
                    setState(() => _selectedBank = bank);
                    if (bank != null && bank != 'Other') {
                      _bankNameController.text = bank;
                    } else if (bank == 'Other') {
                      // Keep whatever was typed / resolved previously
                      if (vm.resolvedBankName.isNotEmpty) {
                        _bankNameController.text = vm.resolvedBankName;
                      }
                    }
                  },
                  serverError: _serverFieldErrors['bank_name'],
                ),
                if (_selectedBank == 'Other' ||
                    (_selectedBank == null && vm.resolvedBankName.isEmpty)) ...[
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _bankNameController,
                    enabled: !vm.isLoading,
                    decoration: _inputDecoration(
                      label: 'Bank Name',
                      prefixIcon: Icons.business_rounded,
                      helperText: vm.resolvedBankName.isNotEmpty
                          ? 'Auto-filled from IFSC'
                          : 'Type your bank name',
                      serverError: _serverFieldErrors['bank_name'],
                      suffixWidget:
                          vm.resolvedBankName.isNotEmpty &&
                              _bankNameController.text.isNotEmpty
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF2E7D32),
                              size: 20,
                            )
                          : null,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                _IFSCHintBanner(),
              ],

              // ── UPI Section ──────────────────────────────────────────────────
              if (!isBankMode) ...[
                _SectionLabel(label: 'UPI Details'),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _upiController,
                        enabled: !vm.isLoading && !vm.isVerifyingUpi,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) {
                          // Reset verification if user edits UPI ID
                          if (vm.isUpiVerified) vm.resetUpiVerification();
                        },
                        decoration: _inputDecoration(
                          label: 'UPI ID',
                          prefixIcon: Icons.qr_code_rounded,
                          helperText: 'e.g. name@upi or 9999999999@paytm',
                          serverError: _serverFieldErrors['upi_id'],
                          suffixWidget: vm.isUpiVerified
                              ? const Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFF2E7D32),
                                  size: 22,
                                )
                              : null,
                        ),
                        validator: (v) {
                          if (_serverFieldErrors.containsKey('upi_id')) {
                            return _serverFieldErrors['upi_id'];
                          }
                          return vm.validateUPI(v);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: _VerifyUpiButton(
                        vm: vm,
                        onVerify: () async {
                          final upi = _upiController.text.trim();
                          await vm.verifyUpi(upi);
                          if (mounted) _formKey.currentState?.validate();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // UPI status feedback
                if (vm.upiVerifyStatus == UpiVerifyStatus.verified) ...[
                  _InlineBanner(
                    icon: Icons.check_circle_rounded,
                    message: 'UPI ID verified successfully.',
                    color: const Color(0xFF2E7D32),
                  ),
                ] else if (vm.upiVerifyStatus == UpiVerifyStatus.failed) ...[
                  _InlineBanner(
                    icon: Icons.cancel_outlined,
                    message:
                        'UPI verification failed. Please check the ID and try again.',
                    color: Colors.red[700]!,
                  ),
                ],
              ],

              // ── Persistent server error panel ────────────────────────────────
              if (vm.status == WithdrawStatus.failure &&
                  !vm.isNetworkError &&
                  vm.errorMessage.isNotEmpty &&
                  _serverFieldErrors.isEmpty) ...[
                const SizedBox(height: 16),
                _InlineBanner(
                  icon: vm.isRetryable
                      ? Icons.sync_problem_rounded
                      : Icons.cancel_outlined,
                  message: vm.errorMessage,
                  color: vm.isRetryable
                      ? const Color(0xFF37474F)
                      : Colors.red[700]!,
                  action: vm.isRetryable
                      ? TextButton.icon(
                          onPressed: _retry,
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Retry'),
                          style: TextButton.styleFrom(foregroundColor: _accent),
                        )
                      : null,
                ),
              ],

              const SizedBox(height: 28),

              // ── Security notice ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDE7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 18,
                      color: Color(0xFFF57F17),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your withdrawal requires biometric or PIN confirmation for security.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.brown[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Submit button ────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (vm.isLoading || balance <= 0)
                      ? null
                      : () => _submit(context, vm, walletVM),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _accent.withValues(alpha: 0.45),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: vm.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_rounded, size: 16),
                            const SizedBox(width: 6),
                            const Icon(Icons.send_to_mobile_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              balance <= 0
                                  ? 'Insufficient Balance'
                                  : 'Authenticate & Withdraw',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Withdrawals typically process in 2–3 business days.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Input decoration ──────────────────────────────────────────────────────

  InputDecoration _inputDecoration({
    required String label,
    String? prefixText,
    IconData? prefixIcon,
    String? helperText,
    String? serverError,
    Widget? suffixWidget,
  }) {
    final bool hasServerError = serverError != null && serverError.isNotEmpty;
    return InputDecoration(
      labelText: label,
      prefixText: prefixText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
      suffixIcon: suffixWidget != null
          ? Padding(
              padding: const EdgeInsets.only(right: 12),
              child: suffixWidget,
            )
          : null,
      helperText: helperText,
      helperStyle: TextStyle(color: Colors.grey[500], fontSize: 11),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: hasServerError ? Colors.red : Colors.grey[300]!,
          width: hasServerError ? 1.5 : 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: hasServerError ? Colors.red : _accent,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}

// ─── Sub-components ──────────────────────────────────────────────────────────

class _IFSCHintBanner extends StatelessWidget {
  static const _accent = Color(0xFFFD802E);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: _accent),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'IFSC format: 4 letters + 0 + 6 alphanumeric  •  Bank name auto-fills when IFSC is complete',
              style: TextStyle(fontSize: 11, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

/// Verify UPI button — disabled while verifying or already verified.
class _VerifyUpiButton extends StatelessWidget {
  const _VerifyUpiButton({required this.vm, required this.onVerify});
  final WithdrawToBankViewModel vm;
  final VoidCallback onVerify;
  static const _accent = Color(0xFFFD802E);

  @override
  Widget build(BuildContext context) {
    final isVerified = vm.isUpiVerified;
    final isVerifying = vm.isVerifyingUpi;

    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: (isVerified || isVerifying || vm.isLoading)
            ? null
            : onVerify,
        style: ElevatedButton.styleFrom(
          backgroundColor: isVerified ? const Color(0xFF2E7D32) : _accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: isVerified
              ? const Color(0xFF81C784)
              : Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        child: isVerifying
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                isVerified ? '✓ Verified' : 'Verify',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

class _InlineBanner extends StatelessWidget {
  const _InlineBanner({
    required this.icon,
    required this.message,
    required this.color,
    this.action,
  });

  final IconData icon;
  final String message;
  final Color color;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: TextStyle(color: color, fontSize: 13)),
                if (action != null) ...[const SizedBox(height: 4), action!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow({
    required this.label,
    required this.value,
    this.valueColor,
  });
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceBanner extends StatelessWidget {
  const _BalanceBanner({required this.balance});
  final double balance;

  @override
  Widget build(BuildContext context) {
    final isLow = balance < 100;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLow
              ? [const Color(0xFF7B1010), const Color(0xFF5C0C0C)]
              : [const Color(0xFF233D4C), const Color(0xFF1A2E39)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isLow ? Colors.red : const Color(0xFF233D4C)).withOpacity(
              0.25,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0x33FD802E),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: Color(0xFFFD802E),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isLow ? 'Low Balance' : 'Available Balance',
                style: TextStyle(
                  color: isLow ? Colors.red[200] : Colors.white60,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${balance.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF233D4C),
      ),
    );
  }
}

class _PaymentModeToggle extends StatelessWidget {
  const _PaymentModeToggle({
    required this.selectedMode,
    required this.onChanged,
  });

  final WithdrawPaymentMode selectedMode;
  final ValueChanged<WithdrawPaymentMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F7),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _Tab(
            label: '🏦  Bank Account',
            isSelected: selectedMode == WithdrawPaymentMode.bank,
            onTap: () => onChanged(WithdrawPaymentMode.bank),
          ),
          _Tab(
            label: '📲  UPI',
            isSelected: selectedMode == WithdrawPaymentMode.upi,
            onTap: () => onChanged(WithdrawPaymentMode.upi),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const _accent = Color(0xFFFD802E);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: isSelected ? _accent : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}

// ─── Bank Selector ────────────────────────────────────────────────────────────

class _BankSelector extends StatefulWidget {
  const _BankSelector({
    required this.selectedBank,
    required this.bankNameController,
    required this.resolvedBankName,
    required this.enabled,
    required this.onBankSelected,
    this.serverError,
  });

  final String? selectedBank;
  final TextEditingController bankNameController;
  final String resolvedBankName;
  final bool enabled;
  final ValueChanged<String?> onBankSelected;
  final String? serverError;

  // Popular banks shown as quick-select chips (top 9)
  static const _quickBanks = [
    'SBI',
    'HDFC Bank',
    'ICICI Bank',
    'Axis Bank',
    'Kotak Bank',
    'Punjab National Bank',
    'Bank of Baroda',
    'IDFC First Bank',
    'Yes Bank',
  ];

  // ── Public Sector Banks ──────────────────────────────────────────────────
  static const _publicSectorBanks = [
    'SBI',
    'Bank of Baroda',
    'Bank of India',
    'Bank of Maharashtra',
    'Canara Bank',
    'Central Bank of India',
    'Indian Bank',
    'Indian Overseas Bank',
    'Punjab & Sind Bank',
    'Punjab National Bank',
    'UCO Bank',
    'Union Bank of India',
    'IDBI Bank',
  ];

  // ── Private Sector Banks ─────────────────────────────────────────────────
  static const _privateSectorBanks = [
    'Axis Bank',
    'Bandhan Bank',
    'Catholic Syrian Bank',
    'City Union Bank',
    'CSB Bank',
    'DCB Bank',
    'Dhanlaxmi Bank',
    'Federal Bank',
    'HDFC Bank',
    'ICICI Bank',
    'IDFC First Bank',
    'IndusInd Bank',
    'Jammu & Kashmir Bank',
    'Karnataka Bank',
    'Karur Vysya Bank',
    'Kotak Bank',
    'Lakshmi Vilas Bank',
    'Nainital Bank',
    'RBL Bank',
    'South Indian Bank',
    'Tamilnad Mercantile Bank',
    'Yes Bank',
  ];

  // ── Small Finance Banks ──────────────────────────────────────────────────
  static const _smallFinanceBanks = [
    'AU Small Finance Bank',
    'Capital Small Finance Bank',
    'Equitas Small Finance Bank',
    'ESAF Small Finance Bank',
    'Fincare Small Finance Bank',
    'Jana Small Finance Bank',
    'North East Small Finance Bank',
    'Shivalik Small Finance Bank',
    'Suryoday Small Finance Bank',
    'Ujjivan Small Finance Bank',
    'Unity Small Finance Bank',
    'Utkarsh Small Finance Bank',
  ];

  // ── Payments Banks ───────────────────────────────────────────────────────
  static const _paymentsBanks = [
    'Airtel Payments Bank',
    'FINO Payments Bank',
    'India Post Payments Bank',
    'Jio Payments Bank',
    'NSDL Payments Bank',
    'Paytm Payments Bank',
  ];

  // ── Co-operative & Regional Banks ────────────────────────────────────────
  static const _cooperativeBanks = [
    'Abhyudaya Co-operative Bank',
    'Bassein Catholic Co-operative Bank',
    'Cosmos Co-operative Bank',
    'Gujarat State Co-operative Bank',
    'Kalyan Janata Sahakari Bank',
    'Kalupur Commercial Co-operative Bank',
    'Mehsana Urban Co-operative Bank',
    'Saraswat Bank',
    'Shamrao Vithal Co-operative Bank',
    'The Shamrao Vithal Co-op Bank',
    'Zoroastrian Co-operative Bank',
  ];

  // ── Regional Rural Banks (RRBs) ──────────────────────────────────────────
  static const _rrbBanks = [
    'Andhra Pradesh Grameena Vikas Bank',
    'Aryavart Bank',
    'Baroda Gujarat Gramin Bank',
    'Baroda Rajasthan Kshetriya Gramin Bank',
    'Baroda UP Gramin Bank',
    'Bangiya Gramin Vikash Bank',
    'Chaitanya Godavari Grameena Bank',
    'Chhattisgarh Rajya Gramin Bank',
    'Dakshin Bihar Gramin Bank',
    'Ellaquai Dehati Bank',
    'Himachal Pradesh Gramin Bank',
    'J&K Grameen Bank',
    'Jharkhand Rajya Gramin Bank',
    'Karnataka Gramin Bank',
    'Karnataka Vikas Grameena Bank',
    'Kerala Gramin Bank',
    'Madhya Pradesh Gramin Bank',
    'Madhyanchal Gramin Bank',
    'Maharashtra Gramin Bank',
    'Manipur Rural Bank',
    'Meghalaya Rural Bank',
    'Mizoram Rural Bank',
    'Nagaland Rural Bank',
    'Odisha Gramya Bank',
    'Paschim Banga Gramin Bank',
    'Prathama UP Gramin Bank',
    'Punjab Gramin Bank',
    'Puduvai Bharathiar Grama Bank',
    'Rajasthan Marudhara Gramin Bank',
    'Saptagiri Grameena Bank',
    'Sarva Haryana Gramin Bank',
    'Saurashtra Gramin Bank',
    'Tamil Nadu Grama Bank',
    'Telangana Grameena Bank',
    'Tripura Gramin Bank',
    'Utkal Grameen Bank',
    'Uttarakhand Gramin Bank',
    'Uttarbanga Kshetriya Gramin Bank',
    'Vidharbha Konkan Gramin Bank',
  ];

  // ── Foreign Banks ────────────────────────────────────────────────────────
  static const _foreignBanks = [
    'Abu Dhabi Commercial Bank',
    'American Express Banking Corp',
    'Australia and New Zealand Banking Group',
    'Barclays Bank',
    'BNP Paribas',
    'Citibank',
    'Credit Agricole Corporate & Investment Bank',
    'Credit Suisse AG',
    'DBS Bank India',
    'Deutsche Bank',
    'FirstRand Bank',
    'HSBC India',
    'Industrial & Commercial Bank of China',
    'JP Morgan Chase Bank',
    'Mizuho Bank',
    'MUFG Bank',
    'National Australia Bank',
    'Rabobank International',
    'Royal Bank of Scotland',
    'Shinhan Bank',
    'Societe Generale',
    'Standard Chartered Bank',
    'Sumitomo Mitsui Banking Corporation',
    'United Overseas Bank',
    'Woori Bank',
  ];

  // ── Full flat list (for search) ──────────────────────────────────────────
  static final _allBanks =
      [
        ..._publicSectorBanks,
        ..._privateSectorBanks,
        ..._smallFinanceBanks,
        ..._paymentsBanks,
        ..._cooperativeBanks,
        ..._rrbBanks,
        ..._foreignBanks,
        'Other',
      ]..sort(
        (a, b) => a == 'Other'
            ? 1
            : b == 'Other'
            ? -1
            : a.compareTo(b),
      );

  @override
  State<_BankSelector> createState() => _BankSelectorState();
}

class _BankSelectorState extends State<_BankSelector> {
  static const _dark = Color(0xFF233D4C);
  static const _accent = Color(0xFFFD802E);

  Future<void> _openBankPicker(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BankPickerSheet(
        allBanks: _BankSelector._allBanks,
        publicSectorBanks: _BankSelector._publicSectorBanks,
        privateSectorBanks: _BankSelector._privateSectorBanks,
        smallFinanceBanks: _BankSelector._smallFinanceBanks,
        paymentsBanks: _BankSelector._paymentsBanks,
        cooperativeBanks: _BankSelector._cooperativeBanks,
        foreignBanks: _BankSelector._foreignBanks,
        currentSelection: widget.selectedBank,
      ),
    );
    if (result != null) widget.onBankSelected(result);
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selectedBank;
    final resolved = widget.resolvedBankName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // IFSC resolved name badge
        if (resolved.isNotEmpty && selected == null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              border: Border.all(color: Colors.green[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green[700],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Auto-detected from IFSC: $resolved',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: widget.enabled
                      ? () => widget.onBankSelected('Other')
                      : null,
                  style: TextButton.styleFrom(
                    foregroundColor: _dark,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Change', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Quick-select chips for top 9 popular banks
        const Text(
          'Popular banks',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _BankSelector._quickBanks.map((bank) {
            final isSel = selected == bank;
            return GestureDetector(
              onTap: widget.enabled
                  ? () => widget.onBankSelected(isSel ? null : bank)
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isSel ? _dark : Colors.white,
                  border: Border.all(
                    color: isSel ? _dark : Colors.grey[300]!,
                    width: isSel ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  bank,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSel ? Colors.white : _dark,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // Searchable bank picker button
        GestureDetector(
          onTap: widget.enabled ? () => _openBankPicker(context) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: widget.enabled ? Colors.white : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: widget.serverError != null
                    ? Colors.red
                    : (selected != null ? _accent : const Color(0xFFDDE1E7)),
                width: selected != null ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_rounded,
                  size: 20,
                  color: selected != null ? _accent : Colors.grey[500],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selected ?? 'Search & select your bank…',
                    style: TextStyle(
                      fontSize: 14,
                      color: selected != null ? _dark : Colors.grey[400],
                      fontWeight: selected != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (selected != null) ...[
                  GestureDetector(
                    onTap: widget.enabled
                        ? () => widget.onBankSelected(null)
                        : null,
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
                ] else
                  const Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: Colors.grey,
                  ),
              ],
            ),
          ),
        ),
        if (widget.serverError != null && widget.serverError!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              widget.serverError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ],
        const SizedBox(height: 6),
        Text(
          '${_BankSelector._allBanks.length - 1} banks available  •  tap to search',
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
      ],
    );
  }
}

// ─── Bank Picker Bottom Sheet ─────────────────────────────────────────────────

class _BankPickerSheet extends StatefulWidget {
  const _BankPickerSheet({
    required this.allBanks,
    required this.publicSectorBanks,
    required this.privateSectorBanks,
    required this.smallFinanceBanks,
    required this.paymentsBanks,
    required this.cooperativeBanks,
    required this.foreignBanks,
    this.currentSelection,
  });

  final List<String> allBanks;
  final List<String> publicSectorBanks;
  final List<String> privateSectorBanks;
  final List<String> smallFinanceBanks;
  final List<String> paymentsBanks;
  final List<String> cooperativeBanks;
  final List<String> foreignBanks;
  final String? currentSelection;

  @override
  State<_BankPickerSheet> createState() => _BankPickerSheetState();
}

class _BankPickerSheetState extends State<_BankPickerSheet>
    with SingleTickerProviderStateMixin {
  static const _dark = Color(0xFF233D4C);
  static const _accent = Color(0xFFFD802E);

  final _searchController = TextEditingController();
  late TabController _tabController;

  List<String> _filtered = [];
  bool _isSearching = false;

  static const _tabs = [
    'All',
    'Public',
    'Private',
    'Small Finance',
    'Payments',
    'Co-op',
    'Foreign',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _filtered = widget.allBanks;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _isSearching = q.isNotEmpty;
      _filtered = q.isEmpty
          ? widget.allBanks
          : widget.allBanks.where((b) => b.toLowerCase().contains(q)).toList();
    });
  }

  List<String> _listForTab(int idx) {
    if (_isSearching) return _filtered;
    switch (idx) {
      case 0:
        return widget.allBanks;
      case 1:
        return widget.publicSectorBanks;
      case 2:
        return widget.privateSectorBanks;
      case 3:
        return widget.smallFinanceBanks;
      case 4:
        return widget.paymentsBanks;
      case 5:
        return widget.cooperativeBanks;
      case 6:
        return widget.foreignBanks;
      default:
        return widget.allBanks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return Container(
      height: screenH * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_rounded,
                  color: _dark,
                  size: 22,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Select Your Bank',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _dark,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 22),
                ),
              ],
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Search bank name…',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Colors.grey,
                ),
                suffixIcon: _isSearching
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _accent, width: 1.5),
                ),
              ),
            ),
          ),
          // Tabs (hidden while searching)
          if (!_isSearching)
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: _accent,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: _accent,
              indicatorWeight: 2.5,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_filtered.length} result${_filtered.length == 1 ? '' : 's'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ),
            ),
          const Divider(height: 1),
          // Bank list
          Expanded(
            child: _isSearching
                ? _buildBankList(_filtered)
                : TabBarView(
                    controller: _tabController,
                    children: List.generate(
                      _tabs.length,
                      (i) => _buildBankList(_listForTab(i)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankList(List<String> banks) {
    if (banks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('No banks found', style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: banks.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, i) {
        final bank = banks[i];
        final isSelected = bank == widget.currentSelection;
        return ListTile(
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: isSelected
                ? _accent.withValues(alpha: 0.12)
                : Colors.grey[100],
            child: Text(
              bank.substring(0, 1),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected ? _accent : _dark,
              ),
            ),
          ),
          title: Text(
            bank,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
              color: isSelected ? _accent : Colors.black87,
            ),
          ),
          trailing: isSelected
              ? const Icon(Icons.check_circle_rounded, color: _accent, size: 20)
              : null,
          onTap: () => Navigator.pop(context, bank),
        );
      },
    );
  }
}
