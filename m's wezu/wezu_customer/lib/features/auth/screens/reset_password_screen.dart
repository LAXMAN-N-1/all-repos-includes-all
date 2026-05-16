import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  String _passwordStrength = "";
  Color _strengthColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
    _otpController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _otpController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = "";
        _strengthColor = Colors.grey;
      });
      return;
    }

    if (password.length < 8) {
      setState(() {
        _passwordStrength = "Weak (Min 8 chars)";
        _strengthColor = Colors.red;
      });
    } else if (!RegExp(r'[A-Z]').hasMatch(password) ||
        !RegExp(r'[0-9]').hasMatch(password)) {
      setState(() {
        _passwordStrength = "Fair (Need uppercase & number)";
        _strengthColor = Colors.orange;
      });
    } else {
      setState(() {
        _passwordStrength = "Strong";
        _strengthColor = Colors.green;
      });
    }
    setState(() {});
  }

  void _submit() async {
    final password = _passwordController.text;
    final otp = _otpController.text;

    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the 6-digit OTP code.")),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    debugPrint("Reset Password: Submitting OTP and New Password");
    try {
      await ref.read(authProvider.notifier).resetPassword(
            identifier: widget.email,
            otp: otp,
            newPassword: password,
          );
      debugPrint("Reset Password: Success, navigating to Login");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password reset successful. Please login."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      debugPrint("Reset Password: API Error: $e");
      // Error handled by listener
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(authProvider, (previous, next) {
      if (next.error != null && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      appBar: AppBar(
        title: Text("Set New Password",
            style: GoogleFonts.outfit(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
        leading: BackButton(color: isDark ? Colors.white : Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter the 6-digit code sent to ${widget.email}",
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.blueGrey[200] : Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

              // OTP Input
              Center(
                child: Pinput(
                  length: 6,
                  controller: _otpController,
                  defaultPinTheme: PinTheme(
                    width: 50,
                    height: 56,
                    textStyle: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      border: Border.all(
                          color:
                              isDark ? Colors.white10 : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 50,
                    height: 56,
                    textStyle: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      border: Border.all(color: AppTheme.primaryBlue, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // New Password
              _buildPremiumTextField(
                controller: _passwordController,
                label: "New Password",
                isDark: isDark,
                isVisible: _isPasswordVisible,
                onToggle: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
                validator: (val) {
                  if (val == null || val.length < 8) return "Min 8 characters";
                  if (!RegExp(r'[A-Z]').hasMatch(val))
                    return "Need at least one uppercase letter";
                  if (!RegExp(r'[0-9]').hasMatch(val))
                    return "Need at least one number";
                  return null;
                },
              ),

              if (_passwordStrength.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    "Strength: $_passwordStrength",
                    style: GoogleFonts.outfit(
                        color: _strengthColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                ),

              const SizedBox(height: 24),

              // Confirm Password
              _buildPremiumTextField(
                controller: _confirmPasswordController,
                label: "Confirm Password",
                isDark: isDark,
                isVisible: _isPasswordVisible,
                validator: (val) => (val != _passwordController.text)
                    ? "Passwords do not match"
                    : null,
              ),

              const SizedBox(height: 48),

              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: (authState.isLoading ||
                          _otpController.text.length < 6 ||
                          _passwordController.text.length < 8 ||
                          _passwordController.text !=
                              _confirmPasswordController.text)
                      ? null
                      : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    disabledBackgroundColor:
                        AppTheme.primaryBlue.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text("Reset Password",
                          style: GoogleFonts.outfit(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String label,
    required bool isDark,
    bool isVisible = false,
    VoidCallback? onToggle,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        style: GoogleFonts.outfit(
          color: isDark ? Colors.white : const Color(0xFF0F172A),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.blueGrey[400] : Colors.blueGrey,
          ),
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: isDark ? Colors.blueGrey[400] : Colors.blueGrey[300],
          ),
          suffixIcon: onToggle != null
              ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    color: isDark ? Colors.blueGrey[400] : Colors.blueGrey[300],
                  ),
                  onPressed: onToggle,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          errorStyle: GoogleFonts.outfit(
            color: Colors.redAccent,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
