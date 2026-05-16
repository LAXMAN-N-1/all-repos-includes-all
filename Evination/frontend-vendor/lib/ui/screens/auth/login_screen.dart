import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/common_input.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_button.dart';
// import '../../widgets/animated_3d_logo.dart';
import '../../../theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../logic/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _rememberMe = false;
  bool _showPassword = false;

  // bool _showContent = false; // Removed logic

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authStateProvider.notifier).login(email, password);
      
      final state = ref.read(authStateProvider);
      if (state.hasError) {
        if (mounted) {
          setState(() {
            _error = 'Invalid email or password. Please try again.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Invalid email or password. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppTheme.darkEvergreen, // New Dark Theme Background
        ),
        child: Stack(
          children: [
            // Background Orbs/Gradients for premium nature look
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: AppTheme.emeraldGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppTheme.emeraldGreen.withOpacity(0.2), blurRadius: 100, spreadRadius: 20),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.mintWhisper.withOpacity(0.05),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppTheme.mintWhisper.withOpacity(0.1), blurRadius: 80, spreadRadius: 10),
                  ],
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       /* 
                       // Removed Animated3DLogo as per user request for "Clean" login page
                       */
                       const SizedBox(height: 64), // Spacing instead of Logo
                       
                       // Fade in Text and Form (Simple fade without delay)
                       Column(
                           children: [
                              Text(
                                'EVE NATION',
                                style: AppTheme.heading.copyWith(color: Colors.white, letterSpacing: 1.5, fontSize: 28),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Vendor Portal',
                                style: TextStyle(color: AppTheme.mintWhisper.withOpacity(0.8), fontSize: 14, letterSpacing: 0.5),
                              ),
                              const SizedBox(height: 48),
                        
                              // Login Card
                              Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05), // Glassmorphism effect
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: AppTheme.mintWhisper.withOpacity(0.1)),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10)),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'Welcome Back',
                                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text('Sign in to manage your events', style: TextStyle(color: Colors.white60)),
                                    const SizedBox(height: 32),
                        
                                    if (_error != null)
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        margin: const EdgeInsets.only(bottom: 24),
                                        decoration: BoxDecoration(
                                          color: AppTheme.error.withOpacity(0.1),
                                          border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(_error!, style: const TextStyle(color: AppTheme.error, fontSize: 13)),
                                      ),
                        
                                    // Email
                                    _buildLabel('Email Address'),
                                    const SizedBox(height: 8),
                                    CommonInput(
                                      controller: _emailController,
                                      placeholder: 'vendor@evination.com',
                                      prefixIcon: const Icon(Icons.email_outlined, color: Colors.white54),
                                    ),
                                    const SizedBox(height: 24),
                        
                                    // Password
                                    _buildLabel('Password'),
                                    const SizedBox(height: 8),
                                    CommonInput(
                                      controller: _passwordController,
                                      placeholder: 'Enter your password',
                                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.white54),
                                      obscureText: !_showPassword,
                                      suffixIcon: IconButton(
                                        icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, color: Colors.white54, size: 20),
                                        onPressed: () => setState(() => _showPassword = !_showPassword),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                        
                                    // Remember Me / Forgot Password
                                    Wrap(
                                      alignment: WrapAlignment.spaceBetween,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: Checkbox(
                                                value: _rememberMe,
                                                onChanged: (v) => setState(() => _rememberMe = v!),
                                                activeColor: AppTheme.emeraldGreen,
                                                side: const BorderSide(color: Colors.white54),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text('Remember me', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                          ],
                                        ),
                                        TextButton(
                                          onPressed: () {},
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: const Size(0, 0),
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            foregroundColor: AppTheme.emeraldGreen,
                                          ),
                                          child: const Text('Forgot password?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 32),
                        
                                    // Submit
                                    CommonButton(
                                      text: _isLoading ? 'Authenticating...' : 'Login',
                                      onPressed: _isLoading ? null : _handleLogin,
                                      fullWidth: true,
                                    ),
                                    
                                    const SizedBox(height: 24),
                                    // Create Account
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        const Text("Don't have an account? ", style: TextStyle(color: Colors.white60, fontSize: 13)),
                                        TextButton(
                                          onPressed: () => context.push('/register'),
                                          style: TextButton.styleFrom(foregroundColor: AppTheme.emeraldGreen),
                                          child: const Text('Register Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                           ],
                         ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    );
  }
}
