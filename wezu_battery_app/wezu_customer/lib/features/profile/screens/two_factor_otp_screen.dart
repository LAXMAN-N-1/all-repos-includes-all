import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../../core/theme/app_theme.dart';
import '../providers/security_provider.dart';

class TwoFactorOtpScreen extends ConsumerStatefulWidget {
  const TwoFactorOtpScreen({super.key});

  @override
  ConsumerState<TwoFactorOtpScreen> createState() => _TwoFactorOtpScreenState();
}

class _TwoFactorOtpScreenState extends ConsumerState<TwoFactorOtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _timerSeconds = 60;
  Timer? _timer;
  bool _canResend = false;

  bool _hasError = false;
  int _failedAttempts = 0;
  bool _isLocked = false;
  int _lockoutSeconds = 120; // 2 minutes
  Timer? _lockoutTimer;

  bool _isSuccess = false;
  bool _isInit = false;
  bool _isEnabling = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('isEnabling')) {
        _isEnabling = args['isEnabling'];
      }
      _isInit = true;
    }
  }

  void _startTimer() {
    setState(() {
      _timerSeconds = 60;
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  void _startLockoutTimer() {
    setState(() {
      _isLocked = true;
      _lockoutSeconds = 120;
    });

    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_lockoutSeconds > 0) {
        setState(() => _lockoutSeconds--);
      } else {
        setState(() {
          _isLocked = false;
          _failedAttempts = 0;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lockoutTimer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyCode();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }

    if (_hasError) {
      setState(() => _hasError = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_isLocked) return;

    final code = _controllers.map((c) => c.text).join();
    if (code.length < 6) return;

    try {
      if (_isEnabling) {
        await ref.read(securityProvider.notifier).verify2FAOTP(code);
      } else {
        await ref.read(securityProvider.notifier).disable2FA(code);
      }

      if (!mounted) return;

      setState(() => _isSuccess = true);

      // Show success toast
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEnabling
            ? "Two-Factor Authentication is now active"
            : "Two-Factor Authentication is now disabled"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ));

      // Delay to let the checkmark animation play
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _hasError = true;
        _failedAttempts++;
        for (var c in _controllers) {
          c.clear();
        }
      });
      _focusNodes[0].requestFocus();

      if (_failedAttempts >= 3) {
        _startLockoutTimer();
      }
    }
  }

  void _resendCode() {
    if (!_canResend || _isLocked) return;

    final future = _isEnabling
        ? ref.read(securityProvider.notifier).request2FAOTP()
        : ref.read(securityProvider.notifier).requestDisable2FAOTP();

    future.then((_) {
      if (!mounted) return;
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Code resent successfully!")));
    }).catchError((e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to resend: $e")));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(securityProvider).isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final inputFillColor = isDark ? const Color(0xFF1E293B) : Colors.grey[100];
    final iconBgColor =
        isDark ? AppTheme.primaryBlue.withValues(alpha: 0.2) : Colors.blue[50];

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration:
                    BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
                child: const Icon(Icons.lock_outline,
                    color: AppTheme.primaryBlue, size: 48),
              ).animate(target: _isSuccess ? 1 : 0).fadeOut(duration: 300.ms),

              if (_isSuccess)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle,
                      color: Colors.green, size: 48),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 32),

              Text(
                _isSuccess ? "Verified!" : "Enter Verification Code",
                style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),

              const SizedBox(height: 12),

              Text(
                "We've sent a 6-digit code to your registered contact.",
                textAlign: TextAlign.center,
                style: TextStyle(color: secondaryTextColor, fontSize: 16),
              ),

              const SizedBox(height: 40),

              // OTP Boxes
              if (_isLocked)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      color: isDark
                          ? Colors.red.withValues(alpha: 0.2)
                          : Colors.red[50],
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      const Icon(Icons.timer, color: Colors.red, size: 40),
                      const SizedBox(height: 12),
                      Text("Too many failed attempts",
                          style: GoogleFonts.outfit(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(
                          "Please try again in ${(_lockoutSeconds ~/ 60).toString().padLeft(2, '0')}:${(_lockoutSeconds % 60).toString().padLeft(2, '0')}",
                          style: GoogleFonts.outfit(
                              color: isDark ? Colors.red[300] : Colors.red[700],
                              fontSize: 16)),
                    ],
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (index) => SizedBox(
                      width: 50,
                      height: 60,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor),
                        decoration: InputDecoration(
                          counterText: "",
                          contentPadding: EdgeInsets.zero,
                          filled: true,
                          fillColor: _hasError
                              ? (isDark
                                  ? Colors.red.withValues(alpha: 0.2)
                                  : Colors.red[50])
                              : inputFillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: _hasError
                                    ? Colors.red
                                    : Colors.transparent),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: _hasError
                                    ? Colors.red
                                    : Colors.transparent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: _hasError
                                    ? Colors.red
                                    : AppTheme.primaryBlue,
                                width: 2),
                          ),
                        ),
                        onChanged: (value) => _onChanged(value, index),
                      ),
                    ),
                  ),
                )
                    .animate(
                        key: ValueKey(_failedAttempts),
                        target: _hasError ? 1 : 0)
                    .shakeX(amount: 5),

              if (_hasError && !_isLocked) ...[
                const SizedBox(height: 16),
                Text("Incorrect code. Please try again.",
                        style: GoogleFonts.outfit(
                            color: Colors.red, fontWeight: FontWeight.w500))
                    .animate()
                    .fadeIn(),
              ],

              const SizedBox(height: 48),

              if (!_isLocked && !_isSuccess)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _verifyCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text("Verify",
                            style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                  ),
                ),

              const SizedBox(height: 24),

              if (!_isLocked && !_isSuccess)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Didn't receive the code? ",
                        style: TextStyle(color: secondaryTextColor)),
                    GestureDetector(
                      onTap: _resendCode,
                      child: Text(
                        _canResend
                            ? "Resend Route"
                            : "Resend in $_timerSeconds" "s",
                        style: TextStyle(
                          color: _canResend
                              ? AppTheme.primaryBlue
                              : secondaryTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
