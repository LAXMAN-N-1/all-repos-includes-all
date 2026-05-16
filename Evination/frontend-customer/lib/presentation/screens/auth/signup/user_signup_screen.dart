import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:evination_customer_app/core/constants/app_colors.dart';
import 'package:evination_customer_app/core/utils/responsive_helper.dart';
import 'package:evination_customer_app/app/routes.dart';
import '../../../providers/auth/auth_notifier.dart';

class UserSignupScreen extends ConsumerStatefulWidget {
  const UserSignupScreen({super.key});

  @override
  ConsumerState<UserSignupScreen> createState() => _UserSignupScreenState();
}

class _UserSignupScreenState extends ConsumerState<UserSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      _showError('Please accept the terms and conditions');
      return;
    }

    await ref.read(authProvider.notifier).signup(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    final authState = ref.read(authProvider);
    if (authState.status == AuthStatus.authenticated && mounted) {
      context.go(AppRouter.home);
    } else if (authState.status == AuthStatus.error && mounted) {
      _showError(authState.errorMessage ?? 'Signup failed. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.alertTriangle, color: Colors.white, size: 18),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14))),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: isDesktop || isTablet
          ? Row(
              children: [
                Expanded(flex: 5, child: _buildBrandPanel()),
                Expanded(flex: 4, child: _buildSignupForm(authState)),
              ],
            )
          : _buildMobileLayout(authState),
    );
  }

  // ─── LEFT BRAND PANEL ──────────────────────────────────────
  Widget _buildBrandPanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFF8E7),
            Color(0xFFFFF0D4),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative shapes
          Positioned(
            bottom: 100,
            right: 50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.sunflowerYellow.withValues(alpha: 0.15), width: 1),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(duration: 6.seconds, begin: const Offset(1, 1), end: const Offset(1.4, 1.4)),
          ),
          Positioned(
            top: 120,
            left: 40,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.sunflowerYellow.withValues(alpha: 0.1), width: 1),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .rotate(duration: 20.seconds),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(64),
            child: SingleChildScrollView(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: AppColors.luxuryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: AppColors.sunflowerYellow.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: const Icon(LucideIcons.zap, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Text('EVE NATION', style: GoogleFonts.cormorantGaramond(color: AppColors.darkCharcoal, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 3.0)),
                  ],
                ).animate().fadeIn(duration: 800.ms),

                const SizedBox(height: 64),

                Text(
                  'Start Your\nJourney With Us',
                  style: GoogleFonts.cormorantGaramond(color: AppColors.darkCharcoal, fontSize: 52, fontWeight: FontWeight.w900, height: 1.1),
                ).animate().fadeIn(delay: 200.ms, duration: 800.ms).slideX(begin: -0.1, end: 0),

                const SizedBox(height: 24),

                Container(width: 60, height: 4, decoration: BoxDecoration(gradient: AppColors.luxuryGradient, borderRadius: BorderRadius.circular(2)))
                  .animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 32),

                SizedBox(
                  width: 380,
                  child: Text(
                    'Create your free account and start planning your perfect celebrations with verified vendors.',
                    style: GoogleFonts.outfit(color: AppColors.greyDark, fontSize: 16, height: 1.7),
                  ),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 56),

                // Benefits
                _buildBenefit(LucideIcons.shieldCheck, 'Book verified & trusted vendors'),
                const SizedBox(height: 20),
                _buildBenefit(LucideIcons.zap, 'Get instant quotes & compare'),
                const SizedBox(height: 20),
                _buildBenefit(LucideIcons.heart, 'Plan stress-free celebrations'),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.sunflowerYellow.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.sunflowerYellow, size: 18),
        ),
        const SizedBox(width: 16),
        Text(text, style: GoogleFonts.outfit(color: AppColors.greyDark, fontSize: 15)),
      ],
    ).animate().fadeIn(delay: 800.ms, duration: 600.ms).slideX(begin: -0.05, end: 0);
  }

  // ─── MOBILE LAYOUT ─────────────────────────────────────────
  Widget _buildMobileLayout(AuthState authState) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFFFF), Color(0xFFFFF8E7)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.arrowLeft, color: AppColors.darkCharcoal),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppColors.luxuryGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: AppColors.sunflowerYellow.withValues(alpha: 0.3), blurRadius: 15)],
                      ),
                      child: const Icon(LucideIcons.zap, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text('EVE NATION', style: GoogleFonts.cormorantGaramond(color: AppColors.darkCharcoal, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 3.0)),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Create Account', style: GoogleFonts.cormorantGaramond(color: AppColors.darkCharcoal, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Join us and start planning', style: GoogleFonts.outfit(color: AppColors.greyDark, fontSize: 14)),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms),

          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildFormContent(authState),
          ),
        ],
      ),
    );
  }

  // ─── SIGNUP FORM PANEL (Desktop/Tablet) ────────────────────
  Widget _buildSignupForm(AuthState authState) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Desktop back button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: AppColors.darkCharcoal, size: 20),
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: 8),
                Text('Back to Login', style: GoogleFonts.outfit(color: AppColors.greyMedium, fontSize: 14)),
              ],
            ),
          ),

          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Account',
                        style: GoogleFonts.cormorantGaramond(color: AppColors.darkCharcoal, fontSize: 40, fontWeight: FontWeight.bold),
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1, end: 0),
                      const SizedBox(height: 8),
                      Text(
                        'Fill in your details to get started',
                        style: GoogleFonts.outfit(color: AppColors.greyMedium, fontSize: 15),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 40),
                      _buildFormContent(authState),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SHARED FORM ───────────────────────────────────────────
  Widget _buildFormContent(AuthState authState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Row
          Row(
            children: [
              Expanded(
                child: _buildField(
                  controller: _firstNameController,
                  label: 'First Name',
                  hint: 'John',
                  icon: LucideIcons.user,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  hint: 'Doe',
                  icon: LucideIcons.user,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

          const SizedBox(height: 20),

          _buildField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'you@example.com',
            icon: LucideIcons.mail,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
              return null;
            },
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

          const SizedBox(height: 20),

          _buildField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: '+91 98765 43210',
            icon: LucideIcons.phone,
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (v.length < 10) return 'Enter a valid phone number';
              return null;
            },
          ).animate().fadeIn(delay: 500.ms, duration: 600.ms),

          const SizedBox(height: 20),

          _buildField(
            controller: _passwordController,
            label: 'Password',
            hint: '••••••••',
            icon: LucideIcons.lock,
            isPassword: true,
            isPasswordField: true,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (v.length < 6) return 'Minimum 6 characters';
              return null;
            },
          ).animate().fadeIn(delay: 600.ms, duration: 600.ms),

          const SizedBox(height: 20),

          _buildField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hint: '••••••••',
            icon: LucideIcons.lock,
            isPassword: true,
            isConfirmField: true,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (v != _passwordController.text) return 'Passwords do not match';
              return null;
            },
          ).animate().fadeIn(delay: 700.ms, duration: 600.ms),

          const SizedBox(height: 24),

          // Terms checkbox
          InkWell(
            onTap: () => setState(() => _acceptTerms = !_acceptTerms),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    color: _acceptTerms ? AppColors.sunflowerYellow : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _acceptTerms ? AppColors.sunflowerYellow : Colors.grey.shade400, width: 1.5),
                  ),
                  child: _acceptTerms ? const Icon(Icons.check, size: 15, color: Colors.white) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.outfit(color: AppColors.greyDark, fontSize: 13, height: 1.5),
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        TextSpan(text: 'Terms of Service', style: TextStyle(color: AppColors.sunflowerYellow, fontWeight: FontWeight.w600)),
                        const TextSpan(text: ' and '),
                        TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppColors.sunflowerYellow, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 800.ms),

          const SizedBox(height: 32),

          // Sign Up Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.luxuryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.sunflowerYellow.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: ElevatedButton(
                onPressed: authState.status == AuthStatus.loading ? null : _handleSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: authState.status == AuthStatus.loading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Create Account', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          const SizedBox(width: 8),
                          const Icon(LucideIcons.arrowRight, size: 18),
                        ],
                      ),
              ),
            ),
          ).animate().fadeIn(delay: 900.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 32),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('or sign up with', style: GoogleFonts.outfit(color: AppColors.greyMedium, fontSize: 12)),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ).animate().fadeIn(delay: 1000.ms),

          const SizedBox(height: 24),

          // Social
          Row(
            children: [
              Expanded(child: _buildSocialButton(Icons.g_mobiledata_rounded, 'Google')),
              const SizedBox(width: 16),
              Expanded(child: _buildSocialButton(Icons.apple, 'Apple')),
            ],
          ).animate().fadeIn(delay: 1100.ms),

          const SizedBox(height: 32),

          // Login link
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Already have an account? ', style: GoogleFonts.outfit(color: AppColors.greyMedium, fontSize: 14)),
                GestureDetector(
                  onTap: () => context.push(AppRouter.login),
                  child: Text(
                    'Sign In',
                    style: GoogleFonts.outfit(color: AppColors.sunflowerYellow, fontWeight: FontWeight.bold, fontSize: 14, decoration: TextDecoration.underline, decorationColor: AppColors.sunflowerYellow),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 1200.ms),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── INPUT FIELD ───────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool isPasswordField = false,
    bool isConfirmField = false,
    String? Function(String?)? validator,
  }) {
    bool obscure = false;
    if (isPasswordField) obscure = !_isPasswordVisible;
    if (isConfirmField) obscure = !_isConfirmVisible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(color: AppColors.greyDark, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? obscure : false,
          keyboardType: keyboardType,
          style: GoogleFonts.outfit(color: AppColors.darkCharcoal, fontSize: 15),
          cursorColor: AppColors.sunflowerYellow,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(icon, color: AppColors.greyMedium, size: 20),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      (isPasswordField ? _isPasswordVisible : _isConfirmVisible) ? LucideIcons.eye : LucideIcons.eyeOff,
                      color: AppColors.greyMedium, size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isPasswordField) _isPasswordVisible = !_isPasswordVisible;
                        if (isConfirmField) _isConfirmVisible = !_isConfirmVisible;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: AppColors.greyLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.sunflowerYellow, width: 2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.error, width: 1)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.error, width: 2)),
            errorStyle: GoogleFonts.outfit(color: AppColors.error, fontSize: 12),
          ),
          validator: validator,
        ),
      ],
    );
  }

  // ─── SOCIAL BUTTON ─────────────────────────────────────────
  Widget _buildSocialButton(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: AppColors.greyDark),
            const SizedBox(width: 10),
            Text(label, style: GoogleFonts.outfit(color: AppColors.greyDark, fontWeight: FontWeight.w500, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
