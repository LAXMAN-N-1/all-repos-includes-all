import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common_input.dart';
import '../../widgets/common_button.dart';

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

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // First try real login
      await ref.read(authStateProvider.notifier).login(email, password);
      
      // Check if real login failed (AuthNotifier catches errors and sets state to error)
      final state = ref.read(authStateProvider);
      if (state.hasError) {
        // Fallback to demo login if real login fails AND it matches demo credentials
        // Use either spelling to be helpful
        if ((email == 'admin@evination.com' || email == 'admin@evenation.com') && password == 'admin123') {
           print('Real login failed, falling back to demo login: ${state.error}');
           await ref.read(authStateProvider.notifier).loginDemo();
        } else {
          // If not demo credentials, show the error
          if (mounted) {
            setState(() {
              _error = 'Invalid email or password. Please try again.';
              _isLoading = false;
            });
          }
        }
      }
      // Router redirection handles navigation on auth state change
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
          gradient: LinearGradient(
             begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF111827), Color(0xFF1F2937), Colors.black], // Matches React dark theme
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
               width: 450, // Max width for card
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   // Header
                   const Icon(Icons.event, size: 60, color: Color(0xFFfdb913)), 
                  // Image.asset('assets/logo.png', height: 60), // Use asset if available
                   const SizedBox(height: 16),
                   const Text(
                    'Admin Portal - Please login to continue',
                    style: TextStyle(color: Color(0xFFfdb913), fontSize: 14),
                  ),
                  const SizedBox(height: 32),
            
                  // Login Card
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFfdb913).withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Admin Login',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFfdb913),
                          ),
                        ),
                        const SizedBox(height: 24),
            
                        if (_error != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              border: Border.all(color: Colors.red[200]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
            
                        // Email
                        _buildLabel('Email Address'),
                        const SizedBox(height: 8),
                        CommonInput(
                          controller: _emailController,
                          placeholder: 'Enter your email',
                          prefixIcon: const Icon(Icons.person, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
            
                        // Password
                        _buildLabel('Password'),
                        const SizedBox(height: 8),
                        CommonInput(
                          controller: _passwordController,
                          placeholder: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                          obscureText: !_showPassword,
                          suffixIcon: IconButton(
                            icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                            onPressed: () => setState(() => _showPassword = !_showPassword),
                          ),
                        ),
                        const SizedBox(height: 20),
            
                        // Remember Me / Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) => setState(() => _rememberMe = v!),
                                  activeColor: const Color(0xFFfdb913),
                                  side: const BorderSide(color: Colors.grey),
                                ),
                                const Text('Remember me', style: TextStyle(color: Colors.grey, fontSize: 14)),
                              ],
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('Forgot password?', style: TextStyle(color: Color(0xFFfdb913), fontSize: 14)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
            
                        // Submit
                        CommonButton(
                          text: _isLoading ? 'Signing in...' : 'Sign In',
                          onPressed: _isLoading ? null : _handleLogin,
                          fullWidth: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: Color(0xFFfdb913), fontSize: 14),
    );
  }

  Widget _buildCredentialRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Color(0xFFfdb913), fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
