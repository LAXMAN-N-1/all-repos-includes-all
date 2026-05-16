import 'dart:async';
import 'package:flutter/material.dart';
import '../../widgets/inputs/inputs.dart';

/// Comprehensive OTP Screen template with built-in resend timer and OtpInput layout.
class OtpScreenTemplate extends StatefulWidget {
  final Future<void> Function(String otpCode) onVerify;
  final Future<void> Function()? onResend;
  final String title;
  final String subtitle;
  final String destination;
  final int codeLength;
  final int resendTimeoutSeconds;
  final Widget? logo;

  const OtpScreenTemplate({
    super.key,
    required this.onVerify,
    this.onResend,
    this.title = 'Verification Code',
    this.subtitle = 'Please enter the code sent to',
    required this.destination,
    this.codeLength = 6,
    this.resendTimeoutSeconds = 60,
    this.logo,
  });

  @override
  State<OtpScreenTemplate> createState() => _OtpScreenTemplateState();
}

class _OtpScreenTemplateState extends State<OtpScreenTemplate> {
  Timer? _timer;
  int _secondsLeft = 0;
  bool _isLoading = false;
  String _currentCode = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _secondsLeft = widget.resendTimeoutSeconds);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleResend() async {
    if (widget.onResend != null) {
      await widget.onResend!();
      _startTimer();
    }
  }

  Future<void> _submit() async {
    if (_currentCode.length != widget.codeLength) return;
    setState(() => _isLoading = true);
    try {
      await widget.onVerify(_currentCode);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.logo != null) ...[Center(child: widget.logo!), const SizedBox(height: 32)],
              
              Text(widget.title, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline, height: 1.5),
                  children: [
                    TextSpan(text: '${widget.subtitle}\n'),
                    TextSpan(
                      text: widget.destination,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87), // Fallback hardcoded for contrast on light mode or let theme handle
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              
              OtpInput(
                length: widget.codeLength,
                onCompleted: (code) {
                  _currentCode = code;
                  _submit(); // Auto submit when code is full
                },
              ),
              
              const SizedBox(height: 48),
              
              FilledButton(
                onPressed: _isLoading || _currentCode.length != widget.codeLength ? null : _submit,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Verify', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              
              const SizedBox(height: 32),
              
              if (widget.onResend != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Didn't receive the code? ", style: theme.textTheme.bodyMedium),
                    if (_secondsLeft > 0)
                      Text('Resend in ${_secondsLeft}s', style: TextStyle(color: theme.colorScheme.outline))
                    else
                      TextButton(onPressed: _handleResend, child: const Text('Resend Code')),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
