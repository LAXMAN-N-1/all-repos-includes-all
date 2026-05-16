import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'wallet_view_model.dart';
import '../../services/transfer_service.dart';
import '../../services/security_service.dart';

class PeerTransferScreen extends StatefulWidget {
  const PeerTransferScreen({super.key});

  @override
  State<PeerTransferScreen> createState() => _PeerTransferScreenState();
}

class _PeerTransferScreenState extends State<PeerTransferScreen> {
  static const _dark = Color(0xFF233D4C);
  static const _accent = Color(0xFFFD802E);

  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _phoneFocus = FocusNode();
  final _amountFocus = FocusNode();

  String? _recipientName;
  bool _isLooking = false;
  bool _isSending = false;
  String? _phoneError;
  String? _amountError;

  final _transferService = TransferService();
  final _securityService = SecurityService();

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _phoneFocus.dispose();
    _amountFocus.dispose();
    _transferService.dispose();
    super.dispose();
  }

  // ─── Find User ──────────────────────────────────────────────────────────────

  Future<void> _findUser() async {
    final phone = _phoneController.text.trim();
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      setState(() {
        _phoneError = 'Enter a valid 10-digit phone number';
        _recipientName = null;
      });
      return;
    }
    setState(() {
      _isLooking = true;
      _phoneError = null;
      _recipientName = null;
    });
    try {
      final name = await _transferService.lookupUser(phone, '');
      if (mounted) {
        setState(() {
          _recipientName = name;
          _isLooking = false;
        });
        _amountFocus.requestFocus();
      }
    } on UserNotFoundException catch (e) {
      if (mounted) {
        setState(() {
          _phoneError = e.message;
          _isLooking = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _phoneError = 'Could not look up user. Please try again.';
          _isLooking = false;
        });
      }
    }
  }

  // ─── Send ───────────────────────────────────────────────────────────────────

  Future<void> _send() async {
    final walletVM = context.read<WalletViewModel>();
    final amount = double.tryParse(_amountController.text.trim());

    // Validate amount
    if (amount == null || amount < 10) {
      setState(() => _amountError = 'Minimum transfer amount is ₹10');
      return;
    }
    if (amount > walletVM.balance) {
      setState(
        () => _amountError =
            'Exceeds your balance of ₹${walletVM.balance.toStringAsFixed(2)}',
      );
      return;
    }
    setState(() => _amountError = null);

    // ── Step 1: Confirmation dialog ──────────────────────────────────────────
    final confirmed = await _showConfirmDialog(amount);
    if (!mounted || confirmed != true) {
      if (mounted && confirmed == null) _showCancelledModal();
      return;
    }

    // ── Step 2: Biometric / PIN (graceful fallback) ──────────────────────────
    bool authOk = false;
    try {
      authOk = await _securityService.authenticateForTransfer();
    } on SecurityAuthException catch (e) {
      if (mounted) {
        // Not enrolled → fall back to in-app PIN dialog
        if (e.isNotEnrolled) {
          authOk = await _showFallbackPinDialog() ?? false;
        } else if (!e.wasCancelled) {
          _showCancelledModal(reason: 'Authentication failed.');
        }
      }
    }

    if (!mounted) return;
    if (!authOk) {
      _showCancelledModal(reason: 'Authentication was not completed.');
      return;
    }

    // ── Step 3: API call ─────────────────────────────────────────────────────
    setState(() => _isSending = true);

    try {
      final result = await _transferService.sendTransfer(
        recipientPhone: _phoneController.text.trim(),
        amount: amount,
        currentBalance: walletVM.balance,
        note: _noteController.text.trim(),
      );

      if (!mounted) return;

      if (result.success) {
        walletVM.applyTransferResult(
          amount: amount,
          newBalance: result.newBalance,
          transactionId: result.transactionId,
          recipientName: _recipientName ?? 'User',
          note: _noteController.text.trim(),
        );
        // Show success BEFORE popping so context is still valid
        await _showSuccessModal(amount, result.transactionId);
        if (mounted) Navigator.pop(context);
      } else {
        _showCancelledModal(reason: 'Transfer was declined by the server.');
      }
    } catch (_) {
      if (mounted) {
        _showCancelledModal(reason: 'Network error. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // ─── Dialogs ─────────────────────────────────────────────────────────────

  /// Returns true = confirmed, false = cancelled, null = tapped outside
  Future<bool?> _showConfirmDialog(double amount) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: _accent, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Confirm Transfer',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ConfirmRow(label: 'To', value: _recipientName ?? ''),
            _ConfirmRow(label: 'Phone', value: _phoneController.text.trim()),
            _ConfirmRow(
              label: 'Amount',
              value: '₹${amount.toStringAsFixed(2)}',
              valueColor: _accent,
            ),
            if (_noteController.text.trim().isNotEmpty)
              _ConfirmRow(label: 'Note', value: _noteController.text.trim()),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 14,
                    color: Colors.amber[800],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Biometric or PIN confirmation required.',
                      style: TextStyle(fontSize: 11, color: Colors.amber[900]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.check_rounded, size: 16),
            label: const Text('Confirm & Send'),
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
    );
  }

  /// Fallback: simple 4-digit in-app PIN for devices without biometrics.
  /// Demo PIN is 1234.
  Future<bool?> _showFallbackPinDialog() async {
    String pin = '';
    String? pinError;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.lock_rounded, color: _accent, size: 22),
              SizedBox(width: 10),
              Text('Enter PIN', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Biometric not available. Enter your 4-digit transaction PIN.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 14),
              TextField(
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) => setLocal(() {
                  pin = v;
                  pinError = null;
                }),
                decoration: InputDecoration(
                  labelText: '4-digit PIN',
                  errorText: pinError,
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Demo PIN: 1234',
                style: TextStyle(fontSize: 11, color: Colors.blue[700]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (pin == '1234') {
                  Navigator.pop(ctx, true);
                } else {
                  setLocal(() => pinError = 'Incorrect PIN');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }

  /// Full-screen success bottom sheet — shown before pop() so context is valid.
  Future<void> _showSuccessModal(double amount, String txId) async {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Big animated success icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: Colors.green[700],
                size: 52,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Money Sent Successfully!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF233D4C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${amount.toStringAsFixed(2)} sent to ${_recipientName ?? 'User'}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Transaction ID chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Transaction ID: ',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  Text(
                    txId,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: txId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transaction ID copied'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Icon(
                      Icons.copy_rounded,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shown when transfer is cancelled or fails.
  void _showCancelledModal({String? reason}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cancel_rounded,
                color: Colors.red[600],
                size: 46,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Transaction Cancelled',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF233D4C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              reason ?? 'The transfer was not completed.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final balance = context.watch<WalletViewModel>().balance;
    final canSend = _recipientName != null && !_isSending;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Send Money'),
        backgroundColor: Colors.white,
        foregroundColor: _dark,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Balance chip ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _dark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Balance: ₹${balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Step 1 — Recipient ───────────────────────────────────────────
            _SectionLabel(number: '1', text: 'Recipient'),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Field(
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    label: 'Phone Number',
                    hint: '10-digit mobile number',
                    errorText: _phoneError,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    onChanged: (_) => setState(() => _recipientName = null),
                    onSubmitted: (_) => _findUser(),
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: _isLooking
                      ? const SizedBox(
                          width: 48,
                          height: 48,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _accent,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _findUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _dark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Find'),
                        ),
                ),
              ],
            ),

            // Recipient confirmation chip
            if (_recipientName != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green[300]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green[700],
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sending to: $_recipientName',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── Step 2 — Amount ──────────────────────────────────────────────
            _SectionLabel(number: '2', text: 'Amount'),
            const SizedBox(height: 10),
            _Field(
              controller: _amountController,
              label: 'Amount (₹)',
              hint: 'Min ₹10',
              errorText: _amountError,
              prefixText: '₹ ',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: (_) => setState(() => _amountError = null),
              enabled: _recipientName != null,
            ),

            const SizedBox(height: 16),

            // ── Step 3 — Note ────────────────────────────────────────────────
            _SectionLabel(number: '3', text: 'Note (optional)'),
            const SizedBox(height: 10),
            _Field(
              controller: _noteController,
              label: "What's this for?",
              hint: 'e.g. splitting bill, rent…',
              maxLength: 80,
              enabled: _recipientName != null,
            ),

            const SizedBox(height: 32),

            // ── Send button ──────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canSend ? _send : null,
                icon: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  _isSending ? 'Sending…' : 'Send Money',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            Center(
              child: Text(
                _recipientName == null
                    ? 'Find a recipient first to enable sending'
                    : '🔒 Confirmation required before sending',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Confirm row helper ───────────────────────────────────────────────────────

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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? const Color(0xFF233D4C),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.number, required this.text});
  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Color(0xFF233D4C),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF233D4C),
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.hint,
    this.errorText,
    this.prefixText,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.maxLength,
    this.enabled = true,
    this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String? hint;
  final String? errorText;
  final String? prefixText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int? maxLength;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      maxLength: maxLength,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixText: prefixText,
        counterText: '',
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDDE1E7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDDE1E7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF233D4C), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}
