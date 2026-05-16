import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

/// 6-digit OTP confirmation sheet shown after biometric auth during withdrawal.
///
/// Returns `true` when the correct OTP is entered, `false`/null on cancel.
///
/// **Demo mode:** correct OTP is always `123456`.
class WithdrawOtpSheet extends StatefulWidget {
  const WithdrawOtpSheet({
    super.key,
    required this.maskedPhone,
    required this.amount,
  });

  final String maskedPhone;
  final double amount;

  @override
  State<WithdrawOtpSheet> createState() => _WithdrawOtpSheetState();
}

class _WithdrawOtpSheetState extends State<WithdrawOtpSheet> {
  static const _accent = Color(0xFFFD802E);
  static const _dark = Color(0xFF233D4C);
  static const _demoOtp = '123456';
  static const _resendSeconds = 60;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  bool _loading = false;
  String? _error;
  int _countdown = _resendSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Auto-focus after short delay so keyboard appears smoothly
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdown = _resendSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          t.cancel();
        }
      });
    });
  }

  void _resend() {
    if (_countdown > 0) return;
    _controller.clear();
    setState(() => _error = null);
    _startCountdown();
    // In production: call SMS API here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP resent successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _verify(String otp) async {
    if (otp.length < 6) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    // Simulate a short verification delay
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    if (otp == _demoOtp) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _loading = false;
        _error = 'Incorrect OTP. Please try again.';
      });
      _controller.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: _dark,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
    );

    final focusedTheme = defaultTheme.copyDecorationWith(
      border: Border.all(color: _accent, width: 2),
      borderRadius: BorderRadius.circular(12),
    );

    final errorTheme = defaultTheme.copyDecorationWith(
      border: Border.all(color: Colors.red[400]!, width: 2),
      borderRadius: BorderRadius.circular(12),
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Shield icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_rounded, color: _accent, size: 32),
          ),
          const SizedBox(height: 16),

          const Text(
            'OTP Verification',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _dark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the 6-digit code sent to\n${widget.maskedPhone}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),

          // Amount reminder
          Container(
            margin: const EdgeInsets.only(top: 4, bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Withdrawing ₹${widget.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: _accent,
                fontSize: 13,
              ),
            ),
          ),

          // Pinput field
          Pinput(
            controller: _controller,
            focusNode: _focusNode,
            length: 6,
            defaultPinTheme: defaultTheme,
            focusedPinTheme: focusedTheme,
            errorPinTheme: errorTheme,
            onCompleted: _verify,
            enabled: !_loading,
          ),

          // Error message
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _error != null
                ? Padding(
                    key: ValueKey(_error),
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  )
                : const SizedBox(height: 10),
          ),

          const SizedBox(height: 16),

          // Demo hint banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[100]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: Colors.blue[700],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Demo mode — use OTP: 123456',
                    style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Verify button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _loading ? null : () => _verify(_controller.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: _accent.withValues(alpha: 0.5),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Verify & Withdraw',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 14),

          // Resend button
          GestureDetector(
            onTap: _countdown == 0 ? _resend : null,
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.black54),
                children: [
                  const TextSpan(text: "Didn't receive the code? "),
                  TextSpan(
                    text: _countdown > 0
                        ? 'Resend in ${_countdown}s'
                        : 'Resend OTP',
                    style: TextStyle(
                      color: _countdown > 0 ? Colors.grey : _accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
