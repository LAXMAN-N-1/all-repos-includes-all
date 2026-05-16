import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_navigator.dart';
import '../../config/app_colors.dart';
import '../../config/app_spacing.dart';
import '../../config/app_text_styles.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
import 'providers/auth_providers.dart';
import '../../utils/app_haptics.dart';

/// Dealer login screen — wired to auth providers for reactive state.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    ref
        .read(authStateProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // Reactive navigation — when login succeeds, go to dashboard
    ref.listen(authStateProvider, (previous, next) {
      next.when(
        initial: () {},
        loading: () {},
        loaded: (_) {
          TextInput.finishAutofillContext(shouldSave: true);
          AppNavigator.toDashboard(context);
        },
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    });

    return AppScaffold(
      useSafeArea: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),

                  // Logo - M3 Expressive Pop
                  Center(
                    child:
                        Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(
                                  24,
                                ), // M3 Large shape
                              ),
                              child: Icon(
                                Icons.bolt_rounded,
                                size: 40,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            )
                            .animate()
                            .scale(duration: 600.ms, curve: Curves.elasticOut)
                            .fadeIn(duration: 400.ms),
                  ),
                  AppSpacing.gapH24,

                  // Title
                  Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        textAlign: TextAlign.center,
                      )
                      .animate()
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        duration: 500.ms,
                        curve: Curves.easeOutQuart,
                      )
                      .fadeIn(),

                  AppSpacing.gapH8,

                  Text(
                        'Sign in to your logistics account',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      )
                      .animate()
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        delay: 100.ms,
                        duration: 500.ms,
                        curve: Curves.easeOutQuart,
                      )
                      .fadeIn(),

                  AppSpacing.gapH32,

                  // Email
                  AppTextField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        label: 'Email Address',
                        hint: 'Enter your email address',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [
                          AutofillHints.username,
                          AutofillHints.email,
                        ],
                        autocorrect: false,
                        enableSuggestions: false,
                        textCapitalization: TextCapitalization.none,
                        onSubmitted: (_) {
                          _passwordFocusNode.requestFocus();
                        },
                        validator: Validators.email,
                      )
                      .animate()
                      .slideX(
                        begin: 0.2,
                        end: 0,
                        delay: 200.ms,
                        duration: 400.ms,
                        curve: Curves.easeOutQuad,
                      )
                      .fadeIn(),

                  AppSpacing.gapH16,

                  // Password
                  AppTextField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        label: 'Password',
                        hint: 'Enter your password',
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        onSuffixIconTap: () {
                          AppHaptics.tap();
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        autocorrect: false,
                        enableSuggestions: false,
                        textCapitalization: TextCapitalization.none,
                        onSubmitted: (_) => _handleLogin(),
                        onEditingComplete: _handleLogin,
                        validator: Validators.password,
                      )
                      .animate()
                      .slideX(
                        begin: 0.2,
                        end: 0,
                        delay: 300.ms,
                        duration: 400.ms,
                        curve: Curves.easeOutQuad,
                      )
                      .fadeIn(),

                  AppSpacing.gapH8,

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        AppHaptics.tap();
                      },
                      child: Text(
                        'Forgot Password?',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms),

                  AppSpacing.gapH24,

                  // Login Button
                  AppButton(
                    label: 'Sign In',
                    onPressed: authState.isLoading ? null : _handleLogin,
                    isLoading: authState.isLoading,
                    icon: Icons.login_rounded,
                  ).animate().scale(
                    delay: 600.ms,
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  ),

                  AppSpacing.gapH16,

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('or', style: AppTextStyles.caption),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ).animate().fadeIn(delay: 700.ms),

                  AppSpacing.gapH16,

                  // Contact Admin
                  AppButton(
                    label: 'Contact Admin',
                    onPressed: () {},
                    variant: AppButtonVariant.outlined,
                    icon: Icons.support_agent_rounded,
                  ).animate().fadeIn(delay: 800.ms),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
