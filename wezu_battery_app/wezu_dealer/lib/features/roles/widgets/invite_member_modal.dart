import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/providers/users_provider.dart';
import '../../../../core/providers/roles_provider.dart';
import '../../../../core/services/users_service.dart';
import '../../../../core/services/toast_service.dart';

class InviteMemberModal extends ConsumerStatefulWidget {
  const InviteMemberModal({super.key});

  @override
  ConsumerState<InviteMemberModal> createState() => _InviteMemberModalState();
}

class _InviteMemberModalState extends ConsumerState<InviteMemberModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  String? _selectedRoleId;
  String _credentialMode = 'invite'; // 'invite' or 'manual'
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRoleId == null) {
      ToastService.show(context, 'Please select a role', type: ToastType.error);
      _tabController.animateTo(1);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final svc = ref.read(usersServiceProvider);
      await svc.createUser({
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'role_id': int.tryParse(_selectedRoleId ?? ''),
        'department':
            _deptCtrl.text.trim().isEmpty ? null : _deptCtrl.text.trim(),
        'credential_mode': _credentialMode,
        'password': _credentialMode == 'manual' ? _passwordCtrl.text : null,
      });

      if (mounted) {
        ToastService.show(context, 'Member added successfully',
            type: ToastType.success);
        ref.invalidate(usersProvider);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ToastService.show(context, 'Error: $e', type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rolesAsync = ref.watch(rolesProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Container(
        width: 500,
        decoration: BoxDecoration(
          color: AppColors.pageBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 40,
                offset: const Offset(0, 20)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),

            // Tab Bar
            _buildTabBar(),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: SizedBox(
                    height: 380,
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildBasicInfoTab(),
                        _buildAccessTab(rolesAsync),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.userPlus,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Team Member',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text('Invite a new person to your dealer dashboard',
                  style:
                      TextStyle(color: AppColors.textTertiary, fontSize: 12)),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(LucideIcons.x,
                color: AppColors.textTertiary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textTertiary,
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.tab,
      tabs: const [
        Tab(text: 'Basic Details'),
        Tab(text: 'Access & Security'),
      ],
    );
  }

  Widget _buildBasicInfoTab() {
    return Column(
      children: [
        _buildTextField(
            'FULL NAME', _nameCtrl, LucideIcons.user, 'e.g. John Doe'),
        const SizedBox(height: 20),
        _buildTextField(
            'EMAIL ADDRESS', _emailCtrl, LucideIcons.mail, 'john@example.com',
            isEmail: true),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
                child: _buildTextField(
                    'PHONE NUMBER', _phoneCtrl, LucideIcons.phone, '+91 ...')),
            const SizedBox(width: 16),
            Expanded(
                child: _buildTextField('DEPARTMENT', _deptCtrl,
                    LucideIcons.briefcase, 'e.g. Operations')),
          ],
        ),
      ],
    );
  }

  Widget _buildAccessTab(AsyncValue rolesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SELECT ROLE',
            style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        rolesAsync.when(
          data: (roles) => Wrap(
            spacing: 10,
            runSpacing: 10,
            children: roles
                .map<Widget>((r) => _RoleOption(
                      role: r,
                      isSelected: _selectedRoleId == r.id.toString(),
                      onSelect: () =>
                          setState(() => _selectedRoleId = r.id.toString()),
                    ))
                .toList(),
          ),
          loading: () => const LinearProgressIndicator(),
          error: (e, _) =>
              Text('Error: $e', style: const TextStyle(color: Colors.red)),
        ),
        const SizedBox(height: 24),
        const Text('CREDENTIALS',
            style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildCredentialToggle(),
        if (_credentialMode == 'manual') ...[
          const SizedBox(height: 20),
          _buildTextField('INITIAL PASSWORD', _passwordCtrl, LucideIcons.lock,
              'min 8 characters',
              isPassword: true),
        ],
      ],
    );
  }

  Widget _buildTextField(
      String label, TextEditingController ctrl, IconData icon, String hint,
      {bool isEmail = false, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 16, color: AppColors.textTertiary),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Required';
            if (isEmail && !v.contains('@')) return 'Invalid email';
            if (isPassword && v.length < 8) return 'Short password';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCredentialToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: AppColors.cardBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _ToggleBtn(
              label: 'Invite via Email',
              icon: LucideIcons.atSign,
              isSelected: _credentialMode == 'invite',
              onTap: () => setState(() => _credentialMode = 'invite')),
          _ToggleBtn(
              label: 'Set Manually',
              icon: LucideIcons.keyboard,
              isSelected: _credentialMode == 'manual',
              onTap: () => setState(() => _credentialMode = 'manual')),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Add Member'),
          ),
        ],
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  final dynamic role;
  final bool isSelected;
  final VoidCallback onSelect;

  const _RoleOption(
      {required this.role, required this.isSelected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.shield,
                size: 14,
                color: isSelected ? AppColors.primary : AppColors.textTertiary),
            const SizedBox(width: 8),
            Text(role.name,
                style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleBtn(
      {required this.label,
      required this.icon,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: isSelected ? AppColors.cardBgHover : Colors.transparent,
              borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 14,
                  color:
                      isSelected ? AppColors.primary : AppColors.textTertiary),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textTertiary,
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }
}
