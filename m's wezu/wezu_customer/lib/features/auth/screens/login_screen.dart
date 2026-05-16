import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/routing/app_router.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _fadeController;
  late final AnimationController _bgController;
  late final Animation<double> _fadeAnim;

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _passwordVisible = false;
  int _activeField = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _bgController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final isPhone = _tabController.index == 0;
    if (isPhone && !SupabaseConfig.phoneAuthEnabled) {
      _showSnack('Phone login is disabled. Please use email login.');
      return;
    }
    final raw =
        isPhone ? _phoneController.text.trim() : _emailController.text.trim();
    final username = isPhone ? _normalizePhone(raw) : raw;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showSnack('Enter your credentials to continue');
      return;
    }
    if (isPhone && username.length != 10) {
      _showSnack('Enter a valid 10-digit phone number');
      return;
    }

    TextInput.finishAutofillContext(shouldSave: true);

    await ref
        .read(authProvider.notifier)
        .login(username: username, password: password);
  }

  String _normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 11 && digits.startsWith('0'))
      return digits.substring(1);
    if (digits.length == 12 && digits.startsWith('91'))
      return digits.substring(2);
    if (digits.length > 10) return digits.substring(digits.length - 10);
    return digits;
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _handleBiometricLogin() async {
    try {
      await ref.read(authProvider.notifier).loginWithBiometrics();
    } catch (e) {
      if (mounted) _showSnack(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;

    ref.listen(authProvider, (previous, next) {
      if (next.error != null) {
        _showSnack(next.error!);
        ref.read(authProvider.notifier).clearError();
      }
      if (next.requires2FA) {
        Navigator.pushNamed(context, AppRoutes.loginTwoFactor);
      } else if (next.isAuthenticated) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.home, (r) => false);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // ── Animated dark background ────────────────────────────────────
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, _) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(
                    -1 + _bgController.value * 0.5,
                    -1,
                  ),
                  end: Alignment(
                    1 - _bgController.value * 0.5,
                    1,
                  ),
                  colors: const [
                    Color(0xFF0A1628),
                    Color(0xFF0D1F3C),
                    Color(0xFF0C1833),
                  ],
                ),
              ),
            ),
          ),

          // Glow accent
          Positioned(
            left: -100,
            top: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            right: -80,
            bottom: size.height * 0.2,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
              ),
            ),
          ),

          // ── Form ────────────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Header
                    Text(
                      'Welcome\nBack',
                      style: GoogleFonts.outfit(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sign in to your WEZU account',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Tab selector
                    _buildTabSelector(),

                    const SizedBox(height: 28),

                    // Autofill Group for Username/Password
                    AutofillGroup(
                      child: Column(
                        children: [
                          // Phone / Email input
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 280),
                            transitionBuilder: (child, anim) => FadeTransition(
                              opacity: anim,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.05, 0),
                                  end: Offset.zero,
                                ).animate(anim),
                                child: child,
                              ),
                            ),
                            child: _tabController.index == 0
                                ? _buildInput(
                                    key: const ValueKey('phone'),
                                    controller: _phoneController,
                                    label: 'Mobile Number',
                                    icon: Icons.phone_rounded,
                                    fieldIndex: 0,
                                    isPhone: true,
                                  )
                                : _buildInput(
                                    key: const ValueKey('email'),
                                    controller: _emailController,
                                    label: 'Email Address',
                                    icon: Icons.email_rounded,
                                    fieldIndex: 0,
                                  ),
                          ),

                          const SizedBox(height: 16),

                          // Password
                          _buildInput(
                            key: const ValueKey('password'),
                            controller: _passwordController,
                            label: 'Password',
                            icon: Icons.lock_rounded,
                            fieldIndex: 1,
                            isPassword: true,
                            isPasswordVisible: _passwordVisible,
                            onVisibilityToggle: () => setState(
                                () => _passwordVisible = !_passwordVisible),
                          ),
                        ],
                      ),
                    ),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(
                            context, AppRoutes.forgotPassword),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF60A5FA),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 4),
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Login button
                    _buildLoginButton(authState.isLoading),

                    // Biometric
                    if (!kIsWeb &&
                        authState.isBiometricEnabled &&
                        authState.failedBiometricAttempts < 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Center(
                          child: _BiometricButton(
                            onTap: authState.isLoading
                                ? null
                                : _handleBiometricLogin,
                          ),
                        ),
                      ),

                    const SizedBox(height: 44),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Or continue with',
                            style: GoogleFonts.outfit(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Social buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialButton(
                          icon: Icons.g_mobiledata,
                          label: 'Google',
                          onTap: () {
                            if (!SupabaseConfig.googleAuthEnabled) {
                              _showSnack('Google login is currently disabled.');
                              return;
                            }
                            ref.read(authProvider.notifier).loginWithGoogle();
                          },
                        ),
                        const SizedBox(width: 16),
                        _SocialButton(
                          icon: Icons.apple,
                          label: 'Apple',
                          onTap: () {
                            if (!SupabaseConfig.appleAuthEnabled) {
                              _showSnack('Apple login is currently disabled.');
                              return;
                            }
                            ref.read(authProvider.notifier).loginWithApple();
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    Center(
                      child: GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.register),
                        child: RichText(
                          text: TextSpan(
                            text: "New here? ",
                            style: GoogleFonts.outfit(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 15,
                            ),
                            children: [
                              TextSpan(
                                text: 'Create Account',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF60A5FA),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (_) => setState(() {}),
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          ),
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.45),
        dividerColor: Colors.transparent,
        labelStyle:
            GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle:
            GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 14),
        tabs: const [
          Tab(text: 'Phone'),
          Tab(text: 'Email'),
        ],
      ),
    );
  }

  Widget _buildInput({
    required Key key,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required int fieldIndex,
    bool isPhone = false,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityToggle,
  }) {
    final isFocused = _activeField == fieldIndex;

    return AnimatedContainer(
      key: key,
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: isFocused ? 0.1 : 0.06),
        border: Border.all(
          color: isFocused
              ? const Color(0xFF3B82F6).withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.08),
          width: isFocused ? 1.5 : 1,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        autofillHints: isPassword
            ? const [AutofillHints.password]
            : (isPhone
                ? const [AutofillHints.telephoneNumber]
                : const [AutofillHints.email]),
        keyboardType: isPhone
            ? TextInputType.phone
            : (isPassword ? TextInputType.text : TextInputType.emailAddress),
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        onTap: () => setState(() => _activeField = fieldIndex),
        onSubmitted: (_) => setState(() => _activeField = -1),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isFocused
                ? const Color(0xFF93C5FD)
                : Colors.white.withValues(alpha: 0.4),
            fontFamily: GoogleFonts.outfit().fontFamily,
          ),
          prefixIcon: Icon(
            icon,
            color: isFocused
                ? const Color(0xFF3B82F6)
                : Colors.white.withValues(alpha: 0.35),
          ),
          prefixText: isPhone ? '+91 ' : null,
          prefixStyle: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 22,
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildLoginButton(bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : _handleLogin,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: isLoading
              ? LinearGradient(
                  colors: [
                    const Color(0xFF3B82F6).withValues(alpha: 0.5),
                    const Color(0xFF1D4ED8).withValues(alpha: 0.5),
                  ],
                )
              : const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                ),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                'Sign In',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}

// ─── Subwidgets ───────────────────────────────────────────────────────────────

class _BiometricButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _BiometricButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                  blurRadius: 16,
                ),
              ],
            ),
            child: const Icon(
              Icons.fingerprint_rounded,
              size: 38,
              color: Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use Biometrics',
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 26, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
