import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:evination_customer_app/core/constants/app_colors.dart';
import 'package:evination_customer_app/core/utils/responsive_helper.dart';
import 'package:evination_customer_app/app/routes.dart';
import 'package:evination_customer_app/presentation/providers/auth/auth_notifier.dart';

class AdvancedUserLoginScreen extends ConsumerStatefulWidget {
  const AdvancedUserLoginScreen({super.key});

  @override
  ConsumerState<AdvancedUserLoginScreen> createState() => _AdvancedUserLoginScreenState();
}

class _AdvancedUserLoginScreenState extends ConsumerState<AdvancedUserLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      final authState = ref.read(authProvider);
      if (authState.status == AuthStatus.authenticated && mounted) {
        context.go(AppRouter.home);
      } else if (authState.status == AuthStatus.error && mounted) {
        _showErrorSnackBar(authState.errorMessage ?? 'Login failed. Please try again.');
      }
    }
  }

  void _showErrorSnackBar(String message) {
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
                Expanded(flex: 4, child: _buildLoginForm(authState)),
              ],
            )
          : _buildMobileLayout(authState),
    );
  }

  // ─── LEFT BRAND PANEL (Desktop/Tablet) ─────────────────────
  Widget _buildBrandPanel() {
    return Container(
      decoration: BoxDecoration(
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
          // Pattern overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.network(
                'https://images.unsplash.com/photo-1583939003579-730e3918a45a?q=80&w=1200&auto=format&fit=crop',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),

          // Animated floating shapes
          Positioned(
            top: 80,
            right: 60,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.sunflowerYellow.withValues(alpha: 0.2), width: 1),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(duration: 5.seconds, begin: const Offset(1, 1), end: const Offset(1.3, 1.3))
             .rotate(duration: 20.seconds),
          ),
          Positioned(
            bottom: 120,
            left: 40,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.sunflowerYellow.withValues(alpha: 0.15), width: 1),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(duration: 7.seconds, begin: const Offset(1.2, 1.2), end: const Offset(1, 1))
             .rotate(duration: 15.seconds),
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
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.sunflowerYellow.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(LucideIcons.zap, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'EVE NATION',
                      style: GoogleFonts.cormorantGaramond(
                        color: AppColors.darkCharcoal,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3.0,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.1, end: 0),

                const SizedBox(height: 64),

                Text(
                  'Your Event\nMasterpiece\nAwaits',
                  style: GoogleFonts.cormorantGaramond(
                    color: AppColors.darkCharcoal,
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 800.ms).slideX(begin: -0.1, end: 0),

                const SizedBox(height: 24),

                Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: AppColors.luxuryGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.3, end: 0),

                const SizedBox(height: 32),

                SizedBox(
                  width: 380,
                  child: Text(
                    'From weddings to corporate events, connect with verified vendors and plan every detail effortlessly.',
                    style: GoogleFonts.outfit(
                      color: AppColors.greyDark,
                      fontSize: 16,
                      height: 1.7,
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms, duration: 800.ms),

                const SizedBox(height: 56),

                // Trust badges
                Row(
                  children: [
                    _buildTrustBadge(LucideIcons.shieldCheck, '500+', 'Verified\nVendors'),
                    const SizedBox(width: 32),
                    _buildTrustBadge(LucideIcons.star, '4.9', 'Average\nRating'),
                    const SizedBox(width: 32),
                    _buildTrustBadge(LucideIcons.heart, '10K+', 'Happy\nCustomers'),
                  ],
                ).animate().fadeIn(delay: 800.ms, duration: 800.ms).slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.sunflowerYellow, size: 22),
        const SizedBox(height: 12),
        Text(value, style: GoogleFonts.outfit(color: AppColors.darkCharcoal, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.outfit(color: AppColors.greyMedium, fontSize: 12, height: 1.4)),
      ],
    );
  }

  // ─── MOBILE LAYOUT ─────────────────────────────────────────
  Widget _buildMobileLayout(AuthState authState) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Mobile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFFFF8E7),
                ],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
            child: Column(
              children: [
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
                Text('Welcome Back', style: GoogleFonts.cormorantGaramond(color: AppColors.darkCharcoal, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Sign in to continue planning your events', style: GoogleFonts.outfit(color: AppColors.greyDark, fontSize: 14)),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms),

          // Form
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildFormContent(authState),
          ),
        ],
      ),
    );
  }

  // ─── LOGIN FORM PANEL (Desktop/Tablet) ─────────────────────
  Widget _buildLoginForm(AuthState authState) {
    return Container(
      color: Colors.white,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome text
                Text(
                  'Welcome Back',
                  style: GoogleFonts.cormorantGaramond(
                    color: AppColors.darkCharcoal,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1, end: 0),
                const SizedBox(height: 8),
                Text(
                  'Sign in to your EVE NATION account',
                  style: GoogleFonts.outfit(
                    color: AppColors.greyMedium,
                    fontSize: 15,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

                const SizedBox(height: 48),
                _buildFormContent(authState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── SHARED FORM CONTENT ───────────────────────────────────
  Widget _buildFormContent(AuthState authState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email Field
          _buildInputField(
            controller: _emailController,
            focusNode: _emailFocus,
            label: 'Email Address',
            hint: 'you@example.com',
            icon: LucideIcons.mail,
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please enter your email';
              if (!val.contains('@')) return 'Please enter a valid email';
              return null;
            },
          ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideX(begin: 0.05, end: 0),

          const SizedBox(height: 24),

          // Password Field
          _buildInputField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            label: 'Password',
            hint: '••••••••',
            icon: LucideIcons.lock,
            isPassword: true,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Please enter your password';
              if (val.length < 4) return 'Password too short';
              return null;
            },
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideX(begin: 0.05, end: 0),

          const SizedBox(height: 20),

          // Remember Me + Forgot Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => setState(() => _rememberMe = !_rememberMe),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _rememberMe ? AppColors.sunflowerYellow : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _rememberMe ? AppColors.sunflowerYellow : Colors.grey.shade400,
                          width: 1.5,
                        ),
                      ),
                      child: _rememberMe
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text('Remember me', style: GoogleFonts.outfit(color: AppColors.greyDark, fontSize: 13)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text('Forgot password?', style: GoogleFonts.outfit(color: AppColors.sunflowerYellow, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ).animate().fadeIn(delay: 500.ms, duration: 600.ms),

          const SizedBox(height: 36),

          // Sign In Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.luxuryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.sunflowerYellow.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: authState.status == AuthStatus.loading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: authState.status == AuthStatus.loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Sign In', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          const SizedBox(width: 8),
                          const Icon(LucideIcons.arrowRight, size: 18),
                        ],
                      ),
              ),
            ),
          ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 32),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('or continue with', style: GoogleFonts.outfit(color: AppColors.greyMedium, fontSize: 12)),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ).animate().fadeIn(delay: 700.ms),

          const SizedBox(height: 24),

          // Social Login Buttons
          Row(
            children: [
              Expanded(child: _buildSocialButton(Icons.g_mobiledata_rounded, 'Google')),
              const SizedBox(width: 16),
              Expanded(child: _buildSocialButton(Icons.apple, 'Apple')),
            ],
          ).animate().fadeIn(delay: 800.ms, duration: 600.ms),

          const SizedBox(height: 40),

          // Sign Up Link
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Don't have an account? ", style: GoogleFonts.outfit(color: AppColors.greyMedium, fontSize: 14)),
                GestureDetector(
                  onTap: () => context.push(AppRouter.signup),
                  child: Text(
                    'Create Account',
                    style: GoogleFonts.outfit(
                      color: AppColors.sunflowerYellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.sunflowerYellow,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 900.ms),
        ],
      ),
    );
  }

  // ─── INPUT FIELD ───────────────────────────────────────────
  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(color: AppColors.greyDark, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: isPassword && !_isPasswordVisible,
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
                      _isPasswordVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                      color: AppColors.greyMedium,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  )
                : null,
            filled: true,
            fillColor: AppColors.greyLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.sunflowerYellow, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
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
