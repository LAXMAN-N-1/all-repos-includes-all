import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/toast_service.dart';
import '../../../core/services/users_service.dart';

class MyAccountScreen extends ConsumerStatefulWidget {
  const MyAccountScreen({super.key});

  @override
  ConsumerState<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends ConsumerState<MyAccountScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  
  bool _isSaving = false;
  bool _obscurePass = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize with current user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        _nameCtrl.text = user.name;
        _phoneCtrl.text = user.phone ?? '';
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() => _isSaving = true);
    try {
      final user = ref.read(authProvider).user;
      if (user == null) return;

      await ref.read(usersServiceProvider).updateUser(int.parse(user.id.toString()), {
        'full_name': _nameCtrl.text,
        'phone_number': _phoneCtrl.text,
      });

      // Refresh auth state to update UI
      await ref.read(authProvider.notifier).refreshUser();
      
      if (!mounted) return;
      ToastService.show(context, 'Profile updated successfully', type: ToastType.success);
    } catch (e) {
      if (!mounted) return;
      ToastService.show(context, 'Update failed: $e', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _changePassword() async {
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      ToastService.show(context, 'Passwords do not match', type: ToastType.error);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(usersServiceProvider).forceChangePassword(
        _currentPassCtrl.text,
        _newPassCtrl.text,
      );

      _currentPassCtrl.clear();
      _newPassCtrl.clear();
      _confirmPassCtrl.clear();

      if (!mounted) return;
      ToastService.show(context, 'Password changed successfully', type: ToastType.success);
    } catch (e) {
      if (!mounted) return;
      ToastService.show(context, 'Failed to change password: $e', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    if (user == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Profile Summary
          _buildProfileHeader(user),
          
          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textTertiary,
              indicatorColor: AppColors.primary,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Personal Info'),
                Tab(text: 'Security & Password'),
                Tab(text: 'Access & Permissions'),
              ],
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPersonalInfoTab(),
                _buildSecurityTab(),
                _buildPermissionsTab(user),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Hero(
            tag: 'profile-avatar',
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(user.initials, 
                style: const TextStyle(color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(user.role, 
                        style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Text(user.email, style: const TextStyle(color: AppColors.textTertiary, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('PROFILE DETAILS'),
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(child: _field('Full Name', _nameCtrl, LucideIcons.user)),
              const SizedBox(width: 24),
              Expanded(child: _field('Phone Number', _phoneCtrl, LucideIcons.phone)),
            ],
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Text('Update Profile', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('SECURITY & PASSWORD'),
          const SizedBox(height: 8),
          const Text('Recommended: Use a strong, unique password to secure your account.', 
            style: TextStyle(color: AppColors.textTertiary, fontSize: 13)),
          const SizedBox(height: 32),
          
          SizedBox(
            width: 500,
            child: Column(
              children: [
                _field('Current Password', _currentPassCtrl, LucideIcons.lock, obscure: _obscurePass),
                const SizedBox(height: 20),
                _field('New Password', _newPassCtrl, LucideIcons.key, obscure: _obscurePass),
                const SizedBox(height: 20),
                _field('Confirm New Password', _confirmPassCtrl, LucideIcons.checkCircle, obscure: _obscurePass),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsTab(dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('YOUR ACCESS & PERMISSIONS'),
          const SizedBox(height: 8),
          const Text('These are the permissions assigned to your role. Contact an administrator for changes.', 
            style: TextStyle(color: AppColors.textTertiary, fontSize: 13)),
          const SizedBox(height: 32),
          
          if (user.permissions.isEmpty)
            const Text('No explicit permissions defined.', style: TextStyle(color: AppColors.textSecondary))
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: user.permissions.entries.map<Widget>((entry) {
                return Container(
                  width: 280,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.shield, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(entry.key.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: entry.value.map((p) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(p, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                        )).toList(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.2));
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon, {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.pageBg,
            prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
          ),
        ),
      ],
    );
  }
}
