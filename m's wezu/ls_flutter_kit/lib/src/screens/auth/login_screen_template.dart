import 'package:flutter/material.dart';
import '../../core/validators/validators.dart';

/// Reusable Login Screen template extracted from Wezu and Meat apps.
/// Pass in custom actions to decouple the UI from your state manager.
class LoginScreenTemplate extends StatefulWidget {
  final Future<void> Function(String email, String password) onLogin;
  final VoidCallback? onGoogleLogin;
  final VoidCallback? onAppleLogin;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onSignup;
  final Widget? logo;
  final String title;
  final String subtitle;

  const LoginScreenTemplate({
    super.key,
    required this.onLogin,
    this.onGoogleLogin,
    this.onAppleLogin,
    this.onForgotPassword,
    this.onSignup,
    this.logo,
    this.title = 'Welcome Back',
    this.subtitle = 'Sign in to your account',
  });

  @override
  State<LoginScreenTemplate> createState() => _LoginScreenTemplateState();
}

class _LoginScreenTemplateState extends State<LoginScreenTemplate> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await widget.onLogin(_emailCtrl.text.trim(), _passCtrl.text);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.logo != null) ...[
                    Center(child: widget.logo!),
                    const SizedBox(height: 32),
                  ],
                  Text(widget.title, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(widget.subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline), textAlign: TextAlign.center),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
                    validator: Validators.compose([Validators.required(), Validators.email()]),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: Validators.required(),
                  ),
                  if (widget.onForgotPassword != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(onPressed: widget.onForgotPassword, child: const Text('Forgot Password?')),
                    )
                  else
                    const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Login', style: TextStyle(fontSize: 16)),
                  ),
                  if (widget.onGoogleLogin != null || widget.onAppleLogin != null) ...[
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('OR', style: theme.textTheme.bodySmall)),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (widget.onGoogleLogin != null)
                      OutlinedButton.icon(
                        onPressed: widget.onGoogleLogin,
                        icon: const Icon(Icons.g_mobiledata, size: 28),
                        label: const Text('Continue with Google'),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                    const SizedBox(height: 12),
                    if (widget.onAppleLogin != null)
                      OutlinedButton.icon(
                        onPressed: widget.onAppleLogin,
                        icon: const Icon(Icons.apple, size: 24),
                        label: const Text('Continue with Apple'),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                  ],
                  if (widget.onSignup != null) ...[
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(onPressed: widget.onSignup, child: const Text('Sign up')),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
