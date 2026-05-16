import 'package:flutter/material.dart';
import '../../core/validators/validators.dart';

/// Reusable Forgot Password Screen template extracted from Wezu and Meat apps.
class ForgotPasswordTemplate extends StatefulWidget {
  final Future<void> Function(String email) onSubmit;
  final Widget? logo;
  final String title;
  final String subtitle;

  const ForgotPasswordTemplate({
    super.key,
    required this.onSubmit,
    this.logo,
    this.title = 'Forgot Password',
    this.subtitle = 'Enter your email address to receive a password reset link.',
  });

  @override
  State<ForgotPasswordTemplate> createState() => _ForgotPasswordTemplateState();
}

class _ForgotPasswordTemplateState extends State<ForgotPasswordTemplate> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await widget.onSubmit(_emailCtrl.text.trim());
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.logo != null) ...[Center(child: widget.logo!), const SizedBox(height: 32)],
                
                Icon(Icons.lock_reset, size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 24),
                
                Text(widget.title, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                
                Text(widget.subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline, height: 1.5), textAlign: TextAlign.center),
                const SizedBox(height: 48),
                
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
                  validator: Validators.compose([Validators.required(), Validators.email()]),
                ),
                const SizedBox(height: 32),
                
                FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Send Reset Link', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
