import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../services/wallet_service.dart';
import '../models/withdrawal_request.dart';
import 'package:flutter/services.dart';
import '../../../core/network/dio_provider.dart';

class WithdrawToBankScreen extends ConsumerStatefulWidget {
  const WithdrawToBankScreen({super.key});

  @override
  ConsumerState<WithdrawToBankScreen> createState() => _WithdrawToBankScreenState();
}

class _WithdrawToBankScreenState extends ConsumerState<WithdrawToBankScreen> {
  late final WalletService _walletService = WalletService(ref.read(authenticatedDioProvider));
  bool _isLoading = true;
  bool _isWithdrawing = false;
  double _availableBalance = 0.0;

  final _amountController = TextEditingController();
  final _accountNoController = TextEditingController();
  final _confirmAccountNoController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _upiController = TextEditingController();
  final _accountHolderController = TextEditingController();

  int _selectedTab = 0; // 0 for Bank, 1 for UPI
  final _formKey = GlobalKey<FormState>();

  bool _isPinValidating = false;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    setState(() => _isLoading = true);
    final balance = await _walletService.getBalance();
    if (mounted) {
      setState(() {
        _availableBalance = balance;
        // Pre-fill amount max balance
        if (balance > 0) {
          _amountController.text = _availableBalance.toStringAsFixed(2);
        }
        _isLoading = false;
      });
    }
  }

  void _onIfscChanged(String ifsc) {
    if (ifsc.length < 11 && _bankNameController.text.isNotEmpty) {
      setState(_bankNameController.clear);
    }
  }

  void _submitWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0;

    // Show confirmation Dialog
    // Show confirmation Dialog imitating an App PIN or Biometric test
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AppPinDialog(amount: amount),
    );

    if (confirmed != true) return;

    setState(() => _isWithdrawing = true);

    // Prepare the request based on selected method
    final request = WithdrawalRequest(
      amount: amount,
      method: _selectedTab == 0 ? 'bank' : 'upi',
      accountNo: _selectedTab == 0 ? _accountNoController.text.trim() : null,
      accountHolder:
          _selectedTab == 0 ? _accountHolderController.text.trim() : null,
      ifsc: _selectedTab == 0 ? _ifscController.text.trim() : null,
      upiId: _selectedTab == 1 ? _upiController.text.trim() : null,
    );

    final success = await _walletService.withdrawFunds(request);

    if (!mounted) return;

    setState(() => _isWithdrawing = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Withdrawal successful!'),
          backgroundColor: AppTheme.accentGreen,
        ),
      );
      // Reset form on success
      _amountController.clear();
      _accountNoController.clear();
      _confirmAccountNoController.clear();
      _accountHolderController.clear();
      _ifscController.clear();
      _bankNameController.clear();
      _upiController.clear();

      // Reload balance
      _loadBalance();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Withdrawal failed, please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _accountNoController.dispose();
    _confirmAccountNoController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _upiController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Withdraw Funds',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accentGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(),
                    const SizedBox(height: 32),
                    _buildAmountField(),
                    const SizedBox(height: 24),
                    _buildTabs(),
                    const SizedBox(height: 24),
                    if (_selectedTab == 0)
                      _buildBankForm()
                    else
                      _buildUPIForm(),
                    const SizedBox(height: 40),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            const Text(
              'AVAILABLE BALANCE',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${_availableBalance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ));
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
      ],
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Amount (\$) *',
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppTheme.primaryBlue),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter an amount';
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) return 'Please enter a valid amount';
        if (amount < 100) return 'Minimum withdrawal is ₹100';
        if (amount > _availableBalance) return 'Insufficient balance';
        return null;
      },
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTab = 0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _selectedTab == 0
                    ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _selectedTab == 0
                        ? AppTheme.primaryBlue
                        : Colors.white10),
              ),
              alignment: Alignment.center,
              child: Text(
                'Bank Account',
                style: TextStyle(
                  color:
                      _selectedTab == 0 ? AppTheme.primaryBlue : Colors.white54,
                  fontWeight:
                      _selectedTab == 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTab = 1),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _selectedTab == 1
                    ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _selectedTab == 1
                        ? AppTheme.primaryBlue
                        : Colors.white10),
              ),
              alignment: Alignment.center,
              child: Text(
                'UPI ID',
                style: TextStyle(
                  color:
                      _selectedTab == 1 ? AppTheme.primaryBlue : Colors.white54,
                  fontWeight:
                      _selectedTab == 1 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBankForm() {
    return Column(
      children: [
        TextFormField(
          controller: _accountHolderController,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Account Holder Name *'),
          validator: (value) {
            if (value == null || value.isEmpty)
              return 'Please enter account holder name';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _accountNoController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          obscureText: true,
          decoration: _inputDecoration('Account Number *'),
          validator: (value) {
            if (value == null || value.isEmpty)
              return 'Please enter account number';
            if (value.length < 8)
              return 'Account number must be at least 8 digits';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmAccountNoController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Confirm Account Number *'),
          validator: (value) {
            if (value == null || value.isEmpty)
              return 'Please re-enter account number';
            if (value != _accountNoController.text)
              return 'Account numbers do not match';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _ifscController,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(color: Colors.white),
          onChanged: _onIfscChanged,
          decoration: _inputDecoration('IFSC Code *'),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter IFSC code';
            final regex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
            if (!regex.hasMatch(value)) return 'Please enter a valid IFSC code';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _bankNameController,
          readOnly: false,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          decoration: _inputDecoration('Bank Name *'),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter bank name';
            }
            return null;
          },
        )
      ],
    );
  }

  Widget _buildUPIForm() {
    return Column(
      children: [
        TextFormField(
          controller: _upiController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('UPI ID (e.g., example@upi) *'),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter UPI ID';
            final regex = RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$');
            if (!regex.hasMatch(value))
              return 'Please enter a valid UPI ID format';
            return null;
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                final isValid = _upiController.text.isNotEmpty &&
                    RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$')
                        .hasMatch(_upiController.text);
                if (isValid) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                      'UPI format looks valid. Final verification happens on submit.',
                    ),
                    backgroundColor: AppTheme.primaryBlue,
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Invalid UPI ID format'),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppTheme.primaryBlue),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text('Verify UPI ID',
                  style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold)),
            ))
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppTheme.primaryBlue),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Column(children: [
      const Text(
        'Withdrawals typically process in 2–3 business days.',
        style: TextStyle(
            color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: (_isWithdrawing || _availableBalance < 100)
              ? null
              : _submitWithdrawal,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            disabledBackgroundColor: Colors.white10,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _isWithdrawing
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  'Withdraw Funds',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    ]);
  }
}

class _AppPinDialog extends ConsumerStatefulWidget {
  final double amount;
  const _AppPinDialog({required this.amount});

  @override
  ConsumerState<_AppPinDialog> createState() => _AppPinDialogState();
}

class _AppPinDialogState extends ConsumerState<_AppPinDialog> {
  final _pinController = TextEditingController();
  bool _isVerifying = false;

  void _verifyPin() async {
    if (_pinController.text.length != 4) return;
    setState(() => _isVerifying = true);

    try {
      final dio = ref.read(authenticatedDioProvider);
      final response = await dio.post('/wallet/withdraw/verify', data: {
        'pin': _pinController.text,
        'amount': widget.amount,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        if (mounted) Navigator.pop(context, true); // PIN Verified
      } else {
        throw Exception(response.data['message'] ?? 'Invalid PIN');
      }
    } catch (e) {
      debugPrint('PIN Verification error: $e');
      if (mounted) {
        setState(() => _isVerifying = false);
        _pinController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().contains('Invalid PIN') ? 'Invalid PIN' : 'Verification failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceDark,
      title: const Text('Security Verification',
          style: TextStyle(color: Colors.white)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(
            'Enter your 4-digit App PIN to confirm withdrawal of \$${widget.amount.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 16),
        TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            style: const TextStyle(
                color: Colors.white, fontSize: 24, letterSpacing: 8),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              counterText: '',
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryBlue)),
            ),
            onChanged: (val) {
              if (val.length == 4) {
                _verifyPin();
              }
            }),
        if (_isVerifying)
          const Padding(
              padding: EdgeInsets.only(top: 16),
              child: CircularProgressIndicator(color: AppTheme.primaryBlue))
      ]),
      actions: [
        TextButton(
          onPressed: _isVerifying
              ? null
              : () => Navigator.pop(context, false), // Cancel
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
      ],
    );
  }
}
