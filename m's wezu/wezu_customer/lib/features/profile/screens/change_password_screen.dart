import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  String _passwordStrength = "";
  Color _strengthColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_updatePasswordStrength);
    _currentPasswordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final password = _newPasswordController.text;
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
  }

  void _submit() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;

    if (!_formKey.currentState!.validate()) return;

    debugPrint("Change Password: Submitting Old and New Passwords");
    try {
      await ref.read(authProvider.notifier).changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
      debugPrint("Change Password: Success");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password changed successfully"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Change Password: API Error: $e");
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
        title: Text("Change Password",
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
              // Current Password
              _buildPremiumTextField(
                controller: _currentPasswordController,
                label: "Current Password",
                isDark: isDark,
                isVisible: _isCurrentPasswordVisible,
                onToggle: () => setState(() =>
                    _isCurrentPasswordVisible = !_isCurrentPasswordVisible),
              ),

              const SizedBox(height: 24),

              // New Password
              _buildPremiumTextField(
                controller: _newPasswordController,
                label: "New Password",
                isDark: isDark,
                isVisible: _isNewPasswordVisible,
                onToggle: () => setState(
                    () => _isNewPasswordVisible = !_isNewPasswordVisible),
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
                label: "Confirm New Password",
                isDark: isDark,
                isVisible: _isNewPasswordVisible,
                validator: (val) => (val != _newPasswordController.text)
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
                          _currentPasswordController.text.isEmpty ||
                          _newPasswordController.text.length < 8 ||
                          _newPasswordController.text !=
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
                      : Text("Update Password",
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
