import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/payment_method_model.dart';
import '../../../repositories/payment_method_repository.dart';
import 'wallet_view_model.dart';

class PayoutRequestScreen extends StatefulWidget {
  const PayoutRequestScreen({super.key});

  @override
  State<PayoutRequestScreen> createState() => _PayoutRequestScreenState();
}

class _PayoutRequestScreenState extends State<PayoutRequestScreen> {
  final _amountController = TextEditingController();
  String? _selectedMethodId;

  static const _accent = Color(0xFFFD802E);
  static const _dark = Color(0xFF233D4C);

  @override
  void initState() {
    super.initState();
    // Pre-select the default method when the screen opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final repo = context.read<PaymentMethodRepository>();
      if (repo.methods.isEmpty) {
        repo.fetchMethods().then((_) {
          if (mounted) {
            setState(() => _selectedMethodId = repo.defaultMethod?.id);
          }
        });
      } else {
        setState(() => _selectedMethodId = repo.defaultMethod?.id);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit(
    WalletViewModel walletVM,
    PaymentMethodRepository repo,
  ) async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showSnack('Please enter a valid amount');
      return;
    }
    if (amount > walletVM.balance) {
      _showSnack('Insufficient balance');
      return;
    }
    if (_selectedMethodId == null) {
      _showSnack('Please select a payment method');
      return;
    }

    final success = await walletVM.requestPayout(amount, _selectedMethodId!);

    if (success && mounted) {
      // Persist the selected method as new default.
      await repo.setDefault(_selectedMethodId!);
      if (mounted) Navigator.pop(context);
      _showSnack('Payout requested successfully', green: true);
    }
  }

  void _showSnack(String msg, {bool green = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: green ? Colors.green[700] : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletVM = context.watch<WalletViewModel>();
    final repo = context.watch<PaymentMethodRepository>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Request Payout'),
        backgroundColor: Colors.white,
        foregroundColor: _dark,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Amount ────────────────────────────────────────────────────────
            const _Label('Enter Amount'),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                prefixText: '₹  ',
                hintText: '0.00',
                helperText:
                    'Available: ₹${walletVM.balance.toStringAsFixed(2)}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _accent, width: 1.5),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // ── Pay with ──────────────────────────────────────────────────────
            const _Label('Pay with'),
            const SizedBox(height: 10),

            if (repo.isLoading) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: _accent),
                ),
              ),
            ] else if (repo.methods.isEmpty) ...[
              _NoMethodsBanner(
                onAdd: () => Navigator.pushNamed(context, '/payment-methods'),
              ),
            ] else ...[
              ...repo.methods.map(
                (m) => _MethodRadioTile(
                  method: m,
                  isSelected: _selectedMethodId == m.id,
                  onTap: () => setState(() => _selectedMethodId = m.id),
                ),
              ),
              // Add new
              const SizedBox(height: 8),
              _AddNewMethodRow(
                onTap: () => Navigator.pushNamed(context, '/payment-methods'),
              ),
            ],

            const SizedBox(height: 32),

            // ── Submit ────────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (walletVM.isLoading ||
                        repo.isLoading ||
                        walletVM.balance <= 0)
                    ? null
                    : () => _submit(walletVM, repo),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _accent.withValues(alpha: 0.45),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: walletVM.isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Submit Request',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF233D4C),
      ),
    );
  }
}

/// A tappable card representing a saved payment method (radio-style).
class _MethodRadioTile extends StatelessWidget {
  const _MethodRadioTile({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  static const _accent = Color(0xFFFD802E);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _accent : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _accent : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? _accent : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        method.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (method.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'DEFAULT',
                            style: TextStyle(
                              color: _accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (method.type == PaymentMethodType.card &&
                      method.expiryLabel.isNotEmpty)
                    Text(
                      method.expiryLabel,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                ],
              ),
            ),
            Icon(
              method.type == PaymentMethodType.card
                  ? Icons.credit_card_rounded
                  : Icons.account_balance_wallet_rounded,
              color: isSelected ? _accent : Colors.grey[400],
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddNewMethodRow extends StatelessWidget {
  const _AddNewMethodRow({required this.onTap});
  final VoidCallback onTap;
  static const _accent = Color(0xFFFD802E);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _accent.withValues(alpha: 0.35),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: _accent, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Use a new method',
              style: TextStyle(
                color: _accent,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: _accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoMethodsBanner extends StatelessWidget {
  const _NoMethodsBanner({required this.onAdd});
  final VoidCallback onAdd;
  static const _accent = Color(0xFFFD802E);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'No saved payment methods.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Add a method'),
            style: TextButton.styleFrom(
              foregroundColor: _accent,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
