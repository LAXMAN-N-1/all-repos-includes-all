import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/responsive_wrapper.dart';
import '../../../features/dashboard/widgets/main_layout.dart';
import '../providers/auth_provider.dart';
import 'otp_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController _inputController = TextEditingController();
  bool _isConsentChecked = false;

  void _handleContinue() async {
    if (!_isConsentChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please agree to the Terms of Service to continue')),
      );
      return;
    }

    final target = _inputController.text.trim();
    if (target.isEmpty) return;
    final isEmail = target.contains('@');
    if (!isEmail && !SupabaseConfig.phoneAuthEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone sign-up is disabled. Use email.')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).requestOtp(target);
    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPScreen(
            target: target,
            isRegistration: true,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen for global auth state (login success)
    ref.listen(authProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
        Future.microtask(() => ref.read(authProvider.notifier).clearError());
      }
      if (next.token != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
          (route) => false,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding:
                      EdgeInsets.all(Responsive.horizontalPadding(context)),
                  child: ResponsiveWrapper(
                    maxWidth: Responsive.formMaxWidth(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sign Up',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create an account to get started',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                        ),
                        const SizedBox(height: 48),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  AppTheme.primaryBlue.withValues(alpha: 0.2),
                            ),
                          ),
                          child: TextField(
                            controller: _inputController,
                            style: const TextStyle(color: AppTheme.textMain),
                            decoration: const InputDecoration(
                              hintText: 'Phone or Email',
                              hintStyle:
                                  TextStyle(color: AppTheme.textSecondary),
                              prefixIcon: Icon(Icons.contact_mail,
                                  color: AppTheme.primaryBlue),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Checkbox(
                              value: _isConsentChecked,
                              onChanged: (value) => setState(
                                  () => _isConsentChecked = value ?? false),
                              fillColor: WidgetStateProperty.resolveWith(
                                  (states) => AppTheme.primaryBlue),
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text: 'I agree to the ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                  children: const [
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: TextStyle(
                                        color: AppTheme.primaryBlue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: AppTheme.primaryBlue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (authState.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          ElevatedButton(
                            onPressed: _handleContinue,
                            child: const Text('Create Account'),
                          ),
                        const SizedBox(height: 24),
                        const Row(
                          children: [
                            Expanded(
                                child: Divider(color: AppTheme.textSecondary)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('OR',
                                  style:
                                      TextStyle(color: AppTheme.textSecondary)),
                            ),
                            Expanded(
                                child: Divider(color: AppTheme.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        OutlinedButton(
                          onPressed: authState.isLoading
                              ? null
                              : () {
                                  if (!_isConsentChecked) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Please agree to the Terms of Service to continue')),
                                    );
                                    return;
                                  }
                                  if (!SupabaseConfig.googleAuthEnabled) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Google sign-up is currently disabled.')),
                                    );
                                    return;
                                  }
                                  ref
                                      .read(authProvider.notifier)
                                      .loginWithGoogle();
                                },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                                color: AppTheme.primaryBlue
                                    .withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.g_mobiledata, size: 32),
                              const SizedBox(width: 8),
                              Text(
                                'Sign up with Google',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: authState.isLoading
                              ? null
                              : () {
                                  if (!_isConsentChecked) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Please agree to the Terms of Service to continue')),
                                    );
                                    return;
                                  }
                                  if (!SupabaseConfig.appleAuthEnabled) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Apple sign-up is currently disabled.')),
                                    );
                                    return;
                                  }
                                  ref
                                      .read(authProvider.notifier)
                                      .loginWithApple();
                                },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.apple,
                                  size: 32, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                'Sign up with Apple',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: RichText(
                              text: TextSpan(
                                text: 'Already have an account? ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                children: const [
                                  TextSpan(
                                    text: 'Sign In',
                                    style: TextStyle(
                                      color: AppTheme.primaryBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
