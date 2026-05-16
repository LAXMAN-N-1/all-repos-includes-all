import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:email_validator/email_validator.dart';
import 'package:wezu_customer_app/core/routing/app_router.dart';
import 'package:wezu_customer_app/features/auth/providers/auth_provider.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _fadeController;
  late final AnimationController _bgController;
  late final Animation<double> _fadeAnim;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _agreedToTerms = false;
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
    _fadeAnim =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _bgController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      _showSnack('Please agree to Terms & Privacy Policy to continue');
      return;
    }

    final isEmail = _tabController.index == 1;
    final target = isEmail
        ? _emailController.text.trim()
        : _phoneController.text.trim();

    final data = <String, dynamic>{
      'full_name': _nameController.text.trim(),
      'password': _passwordController.text,
      if (isEmail) 'email': target,
      if (!isEmail) 'phone_number': target,
    };

    try {
      await ref.read(authProvider.notifier).register(data);
      // register handles auth success internally — navigation via listener below
    } catch (e) {
      if (mounted) {
        String msg = e.toString().replaceFirst('Exception: ', '');
        _showSnack(msg);
      }
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
      if (next.isAuthenticated) {
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

          // Glow orbs
          Positioned(
            right: -80,
            top: -80,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            left: -60,
            bottom: size.height * 0.15,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              ),
            ),
          ),

          // ── Form ────────────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Form(
                key: _formKey,
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

                      const SizedBox(height: 32),

                      // Header
                      Text(
                        'Create\nAccount',
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
                        'Join WEZU and power your ride today',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Tab selector
                      _buildTabSelector(),

                      const SizedBox(height: 24),

                      // Full name
                      _buildInput(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_rounded,
                        fieldIndex: 0,
                        validator: (v) => v != null && v.trim().length >= 3
                            ? null
                            : 'Name must be at least 3 characters',
                      ),

                      const SizedBox(height: 14),

                      // Phone or Email
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
                                fieldIndex: 1,
                                isPhone: true,
                                validator: (v) {
                                  final digits =
                                      v?.replaceAll(RegExp(r'[^0-9]'), '') ??
                                          '';
                                  return digits.length == 10
                                      ? null
                                      : 'Enter a valid 10-digit number';
                                },
                              )
                            : _buildInput(
                                key: const ValueKey('email'),
                                controller: _emailController,
                                label: 'Email Address',
                                icon: Icons.email_rounded,
                                fieldIndex: 1,
                                validator: (v) =>
                                    v != null && EmailValidator.validate(v)
                                        ? null
                                        : 'Enter a valid email',
                              ),
                      ),

                      const SizedBox(height: 14),

                      // Password
                      _buildInput(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_rounded,
                        fieldIndex: 2,
                        isPassword: true,
                        isPasswordVisible: _passwordVisible,
                        onVisibilityToggle: () =>
                            setState(() => _passwordVisible = !_passwordVisible),
                        validator: (v) => v != null && v.length >= 8
                            ? null
                            : 'Password must be at least 8 characters',
                      ),

                      const SizedBox(height: 14),

                      // Confirm password
                      _buildInput(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        icon: Icons.lock_outline_rounded,
                        fieldIndex: 3,
                        isPassword: true,
                        isPasswordVisible: _confirmPasswordVisible,
                        onVisibilityToggle: () => setState(() =>
                            _confirmPasswordVisible = !_confirmPasswordVisible),
                        validator: (v) =>
                            v == _passwordController.text
                                ? null
                                : 'Passwords do not match',
                      ),

                      const SizedBox(height: 24),

                      // Terms
                      GestureDetector(
                        onTap: () =>
                            setState(() => _agreedToTerms = !_agreedToTerms),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: _agreedToTerms
                                    ? const Color(0xFF3B82F6)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: _agreedToTerms
                                      ? const Color(0xFF3B82F6)
                                      : Colors.white.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: _agreedToTerms
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text: 'I agree to the ',
                                  style: GoogleFonts.outfit(
                                    color:
                                        Colors.white.withValues(alpha: 0.55),
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFF60A5FA),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' and ',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white
                                            .withValues(alpha: 0.55),
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFF60A5FA),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Register button
                      _buildRegisterButton(authState.isLoading),

                      const SizedBox(height: 40),

                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                              context, AppRoutes.login),
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account? ',
                              style: GoogleFonts.outfit(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 15,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign In',
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
    Key? key,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required int fieldIndex,
    bool isPhone = false,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityToggle,
    String? Function(String?)? validator,
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
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: isPhone
            ? TextInputType.phone
            : (isPassword
                ? TextInputType.text
                : TextInputType.emailAddress),
        validator: validator,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        onTap: () => setState(() => _activeField = fieldIndex),
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
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          errorStyle: GoogleFonts.outfit(
            color: const Color(0xFFFCA5A5),
            fontSize: 12,
          ),
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : _submit,
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
                'Create Account',
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
