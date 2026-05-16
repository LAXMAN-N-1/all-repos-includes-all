import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../../../core/services/users_service.dart';
import '../../../core/services/toast_service.dart';
import '../../../core/providers/auth_provider.dart';

/// Screen shown after login when force_password_change is required.
class ForceChangePasswordScreen extends ConsumerStatefulWidget {
  const ForceChangePasswordScreen({super.key});

  @override
  ConsumerState<ForceChangePasswordScreen> createState() => _ForceChangePasswordScreenState();
}

class _ForceChangePasswordScreenState extends ConsumerState<ForceChangePasswordScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _submitting = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  double get _passwordStrength {
    final p = _newCtrl.text;
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
    return _currentCtrl.text.isNotEmpty &&
           _newCtrl.text.length >= 8 &&
           _newCtrl.text == _confirmCtrl.text &&
           _passwordStrength >= 0.5;
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await ref.read(usersServiceProvider).forceChangePassword(
        _currentCtrl.text,
        _newCtrl.text,
      );
      if (!mounted) return;
      ToastService.show(context, 'Password changed successfully!', type: ToastType.success);
      context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      ToastService.show(context, 'Failed: $e', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userName = authState.user?.name ?? 'there';

    return Scaffold(
      backgroundColor: AppColors.shellBg,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header icon
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.shieldAlert, color: AppColors.amber, size: 28),
                ),
                const SizedBox(height: 20),
                const Text('Password Change Required',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Hey $userName, your administrator has set a temporary password. Please create a new one to continue.',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Current password
                TextField(
                  controller: _currentCtrl,
                  obscureText: _obscureCurrent,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    labelStyle: const TextStyle(color: AppColors.textTertiary),
                    filled: true, fillColor: AppColors.pageBg,
                    prefixIcon: const Icon(LucideIcons.lock, color: AppColors.textTertiary, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureCurrent ? LucideIcons.eye : LucideIcons.eyeOff, size: 18, color: AppColors.textTertiary),
                      onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 20),

                // New password
                TextField(
                  controller: _newCtrl,
                  obscureText: _obscureNew,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: const TextStyle(color: AppColors.textTertiary),
                    filled: true, fillColor: AppColors.pageBg,
                    prefixIcon: const Icon(LucideIcons.key, color: AppColors.textTertiary, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureNew ? LucideIcons.eye : LucideIcons.eyeOff, size: 18, color: AppColors.textTertiary),
                      onPressed: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 8),

                // Strength bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _passwordStrength,
                    backgroundColor: AppColors.pageBg,
                    color: _strengthColor,
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(_strengthLabel, style: TextStyle(color: _strengthColor, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 16),

                // Confirm password
                TextField(
                  controller: _confirmCtrl,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    labelStyle: const TextStyle(color: AppColors.textTertiary),
                    filled: true, fillColor: AppColors.pageBg,
                    prefixIcon: const Icon(LucideIcons.lock, color: AppColors.textTertiary, size: 18),
                    suffixIcon: _confirmCtrl.text.isNotEmpty
                        ? Icon(
                            _newCtrl.text == _confirmCtrl.text ? LucideIcons.checkCircle : LucideIcons.alertCircle,
                            size: 18,
                            color: _newCtrl.text == _confirmCtrl.text ? AppColors.primary : AppColors.red,
                          )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _canSubmit && !_submitting ? _submit : null,
                    icon: _submitting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(LucideIcons.check, size: 16),
                    label: Text(_submitting ? 'Changing...' : 'Change Password & Continue'),
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
        ),
      ),
    );
  }
}
