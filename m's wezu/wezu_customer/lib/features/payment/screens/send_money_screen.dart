import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/wallet_provider.dart';
import '../models/payment_models.dart';
import '../services/wallet_service.dart';

import '../../../core/network/dio_provider.dart';

class SendMoneyScreen extends ConsumerStatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  ConsumerState<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends ConsumerState<SendMoneyScreen> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic>? _recipient;
  bool _isSearching = false;
  bool _isSending = false;

  late final WalletService _walletService = WalletService(ref.read(authenticatedDioProvider));

  Future<void> _findUser() async {
    if (_phoneController.text.length < 10) return;

    setState(() => _isSearching = true);
    final user = await _walletService.findUserByPhone(_phoneController.text);
    setState(() {
      _recipient = user;
      _isSearching = false;
    });

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User not found'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate() || _recipient == null) return;

    // PIN Confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _PinConfirmationDialog(
        amount: double.parse(_amountController.text),
        recipientName: _recipient!['name'],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSending = true);

    final request = TransferRequest(
      recipientPhone: _phoneController.text,
      amount: double.parse(_amountController.text),
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    final success = await ref.read(walletProvider.notifier).transfer(request);

    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Money sent successfully!'),
              backgroundColor: AppTheme.accentGreen),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Transfer failed'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(walletProvider).balance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Send Money',
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black)),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recipient Phone Number',
                  style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black),
                      decoration:
                          AppTheme.inputDecoration('Enter phone number', isDark)
                              .copyWith(
                        prefixIcon: const Icon(LucideIcons.phone, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSearching ? null : _findUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Find',
                            style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_recipient != null) ...[
                _buildRecipientCard(isDark),
                const SizedBox(height: 32),
                Text('Amount',
                    style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration:
                      AppTheme.inputDecoration('₹0.00', isDark).copyWith(
                    prefixIcon: const Icon(LucideIcons.indianRupee, size: 20),
                    suffixText: 'Balance: ₹${balance.toStringAsFixed(0)}',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter amount';
                    final amt = double.tryParse(value);
                    if (amt == null || amt <= 0) return 'Invalid amount';
                    if (amt > balance) return 'Insufficient balance';
                    if (amt < 10) return 'Minimum transfer is ₹10';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text('Note (Optional)',
                    style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noteController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration:
                      AppTheme.inputDecoration('What\'s this for?', isDark),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSending ? null : _handleSend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isSending
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('Send Money',
                            style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipientCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
            child: const Icon(LucideIcons.user, color: AppTheme.primaryBlue),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sending to',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(_recipient!['name'],
                  style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PinConfirmationDialog extends StatefulWidget {
  final double amount;
  final String recipientName;
  const _PinConfirmationDialog(
      {required this.amount, required this.recipientName});

  @override
  State<_PinConfirmationDialog> createState() => _PinConfirmationDialogState();
}

class _PinConfirmationDialogState extends State<_PinConfirmationDialog> {
  final _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Transfer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('You are sending ₹${widget.amount} to ${widget.recipientName}'),
          const SizedBox(height: 24),
          TextField(
            controller: _pinController,
            obscureText: true,
            maxLength: 4,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              labelText: 'Enter 4-digit PIN',
              counterText: '',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_pinController.text.length == 4) {
              Navigator.pop(context, true);
            }
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
