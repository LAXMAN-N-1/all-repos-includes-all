import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../../../core/services/users_service.dart';
import '../../../core/services/toast_service.dart';

/// Activation screen for invited users — validates token and lets user set password.
class ActivateAccountScreen extends ConsumerStatefulWidget {
  final String token;
  const ActivateAccountScreen({super.key, required this.token});

  @override
  ConsumerState<ActivateAccountScreen> createState() => _ActivateAccountScreenState();
}

class _ActivateAccountScreenState extends ConsumerState<ActivateAccountScreen> {
  bool _loading = true;
  bool _submitting = false;
  bool _tokenValid = false;
  bool _tokenExpired = false;
  String _errorMessage = '';

  // Invite info
  String _fullName = '';
  String _email = '';
  String _roleName = '';
  String _dealerName = '';

  // Password
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _validateToken();
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _validateToken() async {
    try {
      final result = await ref.read(usersServiceProvider).validateInvite(widget.token);
      setState(() {
        _loading = false;
        _tokenValid = result['valid'] == true;
        _tokenExpired = result['expired'] == true;
        _fullName = result['full_name'] ?? '';
        _email = result['email'] ?? '';
        _roleName = result['role_name'] ?? '';
        _dealerName = result['dealer_name'] ?? '';
        if (!_tokenValid) _errorMessage = result['message'] ?? 'Invalid link';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _tokenValid = false;
        _errorMessage = 'Unable to verify invitation link';
      });
    }
  }

  double get _passwordStrength {
    final p = _passwordCtrl.text;
    if (p.isEmpty) return 0;
    double score = 0;
    if (p.length >= 8) score += 0.25;
    if (p.contains(RegExp(r'[A-Z]'))) score += 0.25;
    if (p.contains(RegExp(r'[0-9]'))) score += 0.25;
    if (p.contains(RegExp(r'[^A-Za-z0-9]'))) score += 0.25;
    return score;
  }

  Color get _strengthColor {
    final s = _passwordStrength;
    if (s <= 0.25) return AppColors.red;
    if (s <= 0.5) return AppColors.amber;
    if (s <= 0.75) return AppColors.primary;
    return AppColors.cyan;
  }

  String get _strengthLabel {
    final s = _passwordStrength;
    if (s <= 0.25) return 'Weak';
    if (s <= 0.5) return 'Fair';
    if (s <= 0.75) return 'Strong';
    return 'Very Strong';
  }

  bool get _canSubmit {
    return _passwordCtrl.text.length >= 8 &&
           _passwordCtrl.text == _confirmCtrl.text &&
           _agreedToTerms &&
           _passwordStrength >= 0.5;
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await ref.read(usersServiceProvider).activateAccount(
        widget.token,
        _passwordCtrl.text,
      );
      if (!mounted) return;
      ToastService.show(context, 'Account activated!', type: ToastType.success);
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ToastService.show(context, 'Activation failed: $e', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shellBg,
      body: Center(
        child: _loading
            ? _buildLoading()
            : _tokenValid
                ? _buildActivationForm()
                : _buildError(),
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        CircularProgressIndicator(color: AppColors.primary),
        SizedBox(height: 20),
        Text('Verifying your invitation...', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
      ],
    );
  }

  Widget _buildError() {
    return Container(
      width: 480,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: (_tokenExpired ? AppColors.amber : AppColors.red).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _tokenExpired ? LucideIcons.clock : LucideIcons.alertTriangle,
              color: _tokenExpired ? AppColors.amber : AppColors.red,
              size: 28,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _tokenExpired ? 'Invitation Expired' : 'Invalid Invitation',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(_errorMessage,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildActivationForm() {
    return SingleChildScrollView(
      child: Container(
        width: 520,
        margin: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            // Welcome card
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _fullName.isNotEmpty ? _fullName[0].toUpperCase() : 'W',
                        style: const TextStyle(color: AppColors.primary, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Welcome, $_fullName!',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    _dealerName.isNotEmpty
                        ? 'You\'ve been invited to join $_dealerName'
                        : 'You\'ve been invited to the dealer portal',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  if (_roleName.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Text('Role: $_roleName',
                        style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ),
            ),

            // Password form
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.pageBg,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Set Your Password', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Create a secure password for ${_email}.',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 24),

                  // Password field
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: AppColors.textTertiary),
                      filled: true, fillColor: AppColors.cardBg,
                      prefixIcon: const Icon(LucideIcons.lock, color: AppColors.textTertiary, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? LucideIcons.eye : LucideIcons.eyeOff, size: 18, color: AppColors.textTertiary),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Strength indicator
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _passwordStrength,
                      backgroundColor: AppColors.cardBg,
                      color: _strengthColor,
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_strengthLabel, style: TextStyle(color: _strengthColor, fontSize: 12, fontWeight: FontWeight.w600)),
                      _reqBadge('8+ chars', _passwordCtrl.text.length >= 8),
                      _reqBadge('A-Z', _passwordCtrl.text.contains(RegExp(r'[A-Z]'))),
                      _reqBadge('0-9', _passwordCtrl.text.contains(RegExp(r'[0-9]'))),
                      _reqBadge('!@#', _passwordCtrl.text.contains(RegExp(r'[^A-Za-z0-9]'))),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Confirm
                  TextField(
                    controller: _confirmCtrl,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: const TextStyle(color: AppColors.textTertiary),
                      filled: true, fillColor: AppColors.cardBg,
                      prefixIcon: const Icon(LucideIcons.lock, color: AppColors.textTertiary, size: 18),
                      suffixIcon: _confirmCtrl.text.isNotEmpty
                          ? Icon(
                              _passwordCtrl.text == _confirmCtrl.text ? LucideIcons.checkCircle : LucideIcons.alertCircle,
                              size: 18,
                              color: _passwordCtrl.text == _confirmCtrl.text ? AppColors.primary : AppColors.red,
                            )
                          : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Terms checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                        activeColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.textTertiary),
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text('I agree to the Terms of Service and Privacy Policy',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _canSubmit && !_submitting ? _submit : null,
                      icon: _submitting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(LucideIcons.sparkles, size: 18),
                      label: Text(_submitting ? 'Activating...' : 'Activate My Account'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reqBadge(String text, bool met) {
    return Row(
      children: [
        Icon(met ? LucideIcons.check : LucideIcons.x, size: 12,
          color: met ? AppColors.primary : AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(
          color: met ? AppColors.primary : AppColors.textTertiary, fontSize: 11)),
      ],
    );
  }
}
