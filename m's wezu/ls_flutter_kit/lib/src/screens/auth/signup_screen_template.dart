import 'package:flutter/material.dart';
import '../../core/validators/validators.dart';

/// Define required fields for sign up.
class SignupData {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  const SignupData({required this.fullName, required this.email, required this.phone, required this.password});
}

/// Reusable Signup Screen template extracted from Wezu and Meat apps.
class SignupScreenTemplate extends StatefulWidget {
  final Future<void> Function(SignupData data) onSignup;
  final VoidCallback? onLogin;
  final Widget? logo;
  final String title;
  final String subtitle;
  final bool includePhone;

  const SignupScreenTemplate({
    super.key,
    required this.onSignup,
    this.onLogin,
    this.logo,
    this.title = 'Create Account',
    this.subtitle = 'Join us today',
    this.includePhone = true,
  });

  @override
  State<SignupScreenTemplate> createState() => _SignupScreenTemplateState();
}

class _SignupScreenTemplateState extends State<SignupScreenTemplate> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await widget.onSignup(SignupData(
        fullName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: widget.includePhone ? _phoneCtrl.text.trim() : '',
        password: _passCtrl.text,
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.logo != null) ...[Center(child: widget.logo!), const SizedBox(height: 24)],
                Text(widget.title, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(widget.subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
                const SizedBox(height: 32),
                
                TextFormField(
                  controller: _nameCtrl,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder()),
                  validator: Validators.required(),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
                  validator: Validators.compose([Validators.required(), Validators.email()]),
                ),
                const SizedBox(height: 16),
                
                if (widget.includePhone) ...[
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined), border: OutlineInputBorder()),
                    validator: Validators.compose([Validators.required(), Validators.phone()]),
                  ),
                  const SizedBox(height: 16),
                ],
                
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: Validators.password(minLength: 6),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _confirmPassCtrl,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: Validators.match(_passCtrl, 'Passwords do not match'),
                ),
                
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                
                if (widget.onLogin != null) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(onPressed: widget.onLogin, child: const Text('Log in')),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
