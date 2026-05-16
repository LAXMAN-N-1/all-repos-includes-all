import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../../../core/providers/roles_provider.dart';
import '../../../core/services/users_service.dart';
import '../../../core/services/toast_service.dart';
import '../../stations/providers/stations_provider.dart';

/// 4-Step User Creation Wizard Drawer
class InviteUserScreen extends ConsumerStatefulWidget {
  const InviteUserScreen({super.key});
  @override
  ConsumerState<InviteUserScreen> createState() => _InviteUserScreenState();
}

class _InviteUserScreenState extends ConsumerState<InviteUserScreen> {
  int _currentStep = 0;
  bool _isSubmitting = false;
  bool _showSuccess = false;
  bool _accountActive = true;

  // Step 1: Personal Info
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool? _emailAvailable;

  // Step 2: Role & Access
  String? _selectedRoleId;
  String? _selectedRoleName;
  List<String> _selectedStationIds = [];

  // Step 3: Credentials
  String _credentialMode = 'manual'; // manual | invite
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _forceChange = true;
  bool _obscurePassword = true;
  bool _revealPasswordInReview = false;
  final _inviteMessageCtrl = TextEditingController();

  // Step 4 is review only

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _deptCtrl.dispose();
    _notesCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _inviteMessageCtrl.dispose();
    super.dispose();
  }

  double get _passwordStrength {
    final p = _passwordCtrl.text;
    if (p.isEmpty) return 0;
    double score = 0;
    if (p.length >= 8) score += 0.25;
    if (p.contains(RegExp(r'[A-Z]'))) score += 0.2;
    if (p.contains(RegExp(r'[a-z]'))) score += 0.2;
    if (p.contains(RegExp(r'[0-9]'))) score += 0.2;
    if (p.contains(RegExp(r'[^A-Za-z0-9]'))) score += 0.2;
    return score;
  }

  bool _hasReq(int type) {
    final p = _passwordCtrl.text;
    switch (type) {
      case 0:
        return p.length >= 8;
      case 1:
        return p.contains(RegExp(r'[A-Z]'));
      case 2:
        return p.contains(RegExp(r'[a-z]'));
      case 3:
        return p.contains(RegExp(r'[0-9]'));
      case 4:
        return p.contains(RegExp(r'[^A-Za-z0-9]'));
      default:
        return false;
    }
  }

  String get _strengthLabel {
    final s = _passwordStrength;
    if (s <= 0.25) return 'Weak';
    if (s <= 0.5) return 'Fair';
    if (s <= 0.75) return 'Strong';
    return 'Very Strong';
  }

  Color get _strengthColor {
    final s = _passwordStrength;
    if (s <= 0.25) return AppColors.red;
    if (s <= 0.5) return AppColors.amber;
    if (s <= 0.75) return AppColors.primary;
    return AppColors.cyan;
  }

  Future<void> _checkEmail() async {
    if (_emailCtrl.text.isEmpty) return;
    try {
      final result =
          await ref.read(usersServiceProvider).checkEmail(_emailCtrl.text);
      setState(() => _emailAvailable = result['available'] == true);
    } catch (_) {
      setState(() => _emailAvailable = null);
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {

      final data = {
        'full_name': _nameCtrl.text,
        'email': _emailCtrl.text,
        'phone_number': _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text : null,
        'department': _deptCtrl.text.isNotEmpty ? _deptCtrl.text : null,
        'notes': _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
        'role_id': int.parse(_selectedRoleId!),
        'credential_mode': _credentialMode,
        'force_password_change': _forceChange,
        'invitation_message':
            _inviteMessageCtrl.text.isNotEmpty ? _inviteMessageCtrl.text : null,
        'initial_status': _accountActive ? 'active' : 'inactive',
      };

      if (_credentialMode == 'manual') {
        data['password'] = _passwordCtrl.text;
      }
      if (_selectedStationIds.isNotEmpty) {
        data['station_ids'] = _selectedStationIds.map(int.parse).toList();
      }

      await ref.read(usersServiceProvider).createUser(data);

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _showSuccess = true;
      });
    } catch (e) {
      if (!mounted) return;
      ToastService.show(context, 'Failed to create user: $e',
          type: ToastType.error);
      setState(() => _isSubmitting = false);
    }
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _nameCtrl.text.isNotEmpty &&
            _emailCtrl.text.isNotEmpty &&
            (_emailAvailable == true);
      case 1:
        if (_selectedRoleName == 'Station Manager') {
          return _selectedStationIds.isNotEmpty;
        }
        return _selectedRoleId != null;
      case 2:
        if (_credentialMode == 'manual') {
          return _passwordCtrl.text.length >= 8 &&
              _passwordCtrl.text == _confirmPasswordCtrl.text;
        }
        return true;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.6),
      body: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 600,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.shellBg,
            border: Border(left: BorderSide(color: AppColors.border)),
          ),
          child: _showSuccess
              ? _buildSuccessView()
              : Column(
                  children: [
                    _buildHeader(),
                    _buildStepIndicator(),
                    Expanded(
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(32),
                            child: _buildCurrentStep(),
                          ),
                          if (_isSubmitting) _buildSubmittingOverlay(),
                        ],
                      ),
                    ),
                    _buildFooter(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create New User',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text('Fill all steps to create login access for this user',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.x,
                color: AppColors.textTertiary, size: 20),
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    const steps = [
      'Personal Info',
      'Role & Access',
      'Login Credentials',
      'Review & Create'
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? AppColors.primary
                        : isActive
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : AppColors.pageBg,
                    border: Border.all(
                        color: isActive ? AppColors.primary : AppColors.border),
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(LucideIcons.check,
                            size: 14, color: Colors.white)
                        : Text('${i + 1}',
                            style: TextStyle(
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.textTertiary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    steps[i],
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.textTertiary,
                      fontSize: 12,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (i < steps.length - 1) ...[
                  const SizedBox(width: 8),
                  Expanded(
                      child: Container(
                          height: 1,
                          color:
                              isDone ? AppColors.primary : AppColors.border)),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      case 3:
        return _buildStep4();
      default:
        return const SizedBox();
    }
  }

  // ── Step 1: Personal Information ──────────────────────

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('WHO IS THIS USER?',
            style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Full Name *'),
                  const SizedBox(height: 8),
                  _textField(_nameCtrl, 'e.g. Ravi Kumar',
                      icon: LucideIcons.user),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Column(
              children: [
                _label('Profile Photo'),
                const SizedBox(height: 8),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Center(
                    child: _nameCtrl.text.isEmpty
                        ? const Icon(LucideIcons.camera,
                            color: AppColors.textTertiary, size: 20)
                        : Text(_nameCtrl.text[0].toUpperCase(),
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        _label('Email Address *'),
        const SizedBox(height: 8),
        _textField(
          _emailCtrl,
          'user@company.com',
          icon: LucideIcons.mail,
          onChanged: (_) {
            _emailAvailable = null;
            setState(() {});
          },
          onEditingComplete: _checkEmail,
          suffix: _emailAvailable == null
              ? null
              : Icon(
                  _emailAvailable!
                      ? LucideIcons.checkCircle
                      : LucideIcons.alertCircle,
                  size: 18,
                  color: _emailAvailable! ? AppColors.primary : AppColors.red,
                ),
        ),
        const SizedBox(height: 20),
        _label('Phone Number'),
        const SizedBox(height: 8),
        _textField(_phoneCtrl, '+91 XXXXX XXXXX', icon: LucideIcons.phone),
        const SizedBox(height: 20),
        _label('Department / Team'),
        const SizedBox(height: 8),
        _textField(_deptCtrl, 'e.g. Operations, Finance',
            icon: LucideIcons.building),
        const SizedBox(height: 20),
        _label('Internal Notes'),
        const SizedBox(height: 8),
        _textField(_notesCtrl, 'Notes visible only to admins (optional)',
            icon: LucideIcons.fileText, maxLines: 3),
      ],
    );
  }

  // ── Step 2: Role Assignment ───────────────────────────

  Widget _buildStep2() {
    final rolesAsync = ref.watch(rolesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('WHAT CAN THIS USER DO?',
            style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2)),
        const SizedBox(height: 16),
        rolesAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) =>
              Text('Error: $e', style: const TextStyle(color: AppColors.red)),
          data: (roles) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: roles.map((r) {
                  final isSelected = _selectedRoleId == r.id;
                  Color roleColor;
                  try {
                    roleColor = Color(
                        int.parse((r.colorHex).replaceFirst('#', '0xFF')));
                  } catch (_) {
                    roleColor = AppColors.primary;
                  }

                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedRoleId = r.id;
                      _selectedRoleName = r.name;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 260,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? roleColor.withValues(alpha: 0.08)
                            : AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? roleColor : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: roleColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(LucideIcons.shield,
                                color: roleColor, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                                if (r.description.isNotEmpty)
                                  Text(r.description,
                                      style: const TextStyle(
                                          color: AppColors.textTertiary,
                                          fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(LucideIcons.checkCircle,
                                color: roleColor, size: 18),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_selectedRoleName == 'Station Manager') ...[
                const SizedBox(height: 32),
                _label('Station Assignment *'),
                const SizedBox(height: 12),
                _buildStationSelector(),
              ],
              const SizedBox(height: 32),
              _toggleRow(
                title: 'Account Active Status',
                subtitle: 'User can log in immediately after creation',
                value: _accountActive,
                onChanged: (v) => setState(() => _accountActive = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 3: Credentials ───────────────────────────────

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SET LOGIN DETAILS',
            style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2)),
        const SizedBox(height: 16),

        // Info bar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.info, color: AppColors.amber, size: 16),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'These credentials will be used by the user to log in. Store them securely or share directly with the user.',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _label('Login Username / Email'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.lock,
                  color: AppColors.textTertiary, size: 18),
              const SizedBox(width: 12),
              Text(_emailCtrl.text,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 14)),
              const Spacer(),
              const Icon(LucideIcons.checkCircle,
                  color: AppColors.primary, size: 16),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text('The email address is used as the login username.',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
        const SizedBox(height: 24),

        _label('Password Setup Mode'),
        const SizedBox(height: 12),
        Row(
          children: [
            _modeCard('manual', LucideIcons.key, 'Set Password Now',
                'Immediate login access'),
            const SizedBox(width: 12),
            _modeCard('invite', LucideIcons.mail, 'Send Invite Link',
                'User sets their own password'),
          ],
        ),
        const SizedBox(height: 28),

        if (_credentialMode == 'invite') ...[
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(LucideIcons.mail, size: 32, color: AppColors.cyan),
                ),
                const SizedBox(height: 16),
                Text('An invitation link will be sent to ${_emailCtrl.text}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text('The link expires in 72 hours.',
                    style:
                        TextStyle(color: AppColors.textTertiary, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _label('Customize invitation message (optional)'),
          const SizedBox(height: 8),
          _textField(_inviteMessageCtrl, 'Add a personal note...', maxLines: 3),
        ],

        if (_credentialMode == 'manual') ...[
          _label('Password *'),
          const SizedBox(height: 8),
          _textField(
            _passwordCtrl,
            'Create a strong password',
            icon: LucideIcons.lock,
            obscure: _obscurePassword,
            suffix: IconButton(
              icon: Icon(
                  _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                  size: 18,
                  color: AppColors.textTertiary),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 12),

          // Strength bar & checklist
          Text('Password Strength: $_strengthLabel',
              style: TextStyle(
                  color: _strengthColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(4, (index) {
              final isActive = _passwordStrength > (index * 0.25);
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: isActive ? _strengthColor : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _passReq('8+ characters', _hasReq(0)),
              _passReq('Uppercase', _hasReq(1)),
              _passReq('Lowercase', _hasReq(2)),
              _passReq('Number', _hasReq(3)),
              _passReq('Special', _hasReq(4)),
            ],
          ),
          const SizedBox(height: 24),

          _label('Confirm Password *'),
          const SizedBox(height: 8),
          _textField(
            _confirmPasswordCtrl,
            'Confirm your password',
            icon: LucideIcons.lock,
            obscure: true,
            suffix: _confirmPasswordCtrl.text.isNotEmpty &&
                    _passwordCtrl.text == _confirmPasswordCtrl.text
                ? const Icon(LucideIcons.checkCircle,
                    size: 18, color: AppColors.primary)
                : null,
          ),
          const SizedBox(height: 24),

          // Force change toggle
          _toggleRow(
            title: 'Force password change on first login',
            subtitle: 'User must set a new password after logging in',
            value: _forceChange,
            onChanged: (v) => setState(() => _forceChange = v),
            isPrimary: true,
          ),
          const SizedBox(height: 16),

          Center(
            child: TextButton.icon(
              onPressed: () {
                final text =
                    'Username: ${_emailCtrl.text}\nPassword: ${_passwordCtrl.text}';
                Clipboard.setData(ClipboardData(text: text));
                ToastService.show(context, 'Credentials copied to clipboard');
              },
              icon: const Icon(LucideIcons.copy, size: 16),
              label: const Text('Copy Credentials'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
        ],
      ],
    );
  }

  Widget _passReq(String label, bool met) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(met ? LucideIcons.checkCircle : LucideIcons.circle,
            size: 12, color: met ? AppColors.primary : AppColors.textTertiary),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                color: met ? Colors.white : AppColors.textTertiary,
                fontSize: 11)),
      ],
    );
  }

  Widget _toggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isPrimary = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor:
                isPrimary ? AppColors.primary : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _modeCard(String mode, IconData icon, String title, String subtitle) {
    final isSelected = _credentialMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _credentialMode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textTertiary,
                      size: 20),
                  const Spacer(),
                  if (isSelected)
                    const Icon(LucideIcons.checkCircle,
                        color: AppColors.primary, size: 18),
                ],
              ),
              const SizedBox(height: 12),
              Text(title,
                  style: TextStyle(
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: const TextStyle(
                      color: AppColors.textTertiary, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 4: Review ────────────────────────────────────

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('REVIEW & CREATE',
            style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2)),
        const SizedBox(height: 20),

        // Profile Preview Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  _nameCtrl.text.isNotEmpty
                      ? _nameCtrl.text[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_nameCtrl.text,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (_selectedRoleName != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(_selectedRoleName!,
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          ),
                        const SizedBox(width: 8),
                        Text(_emailCtrl.text,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Two-column summary
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _summarySection('Personal Details', [
                _summaryRow('Department',
                    _deptCtrl.text.isEmpty ? '—' : _deptCtrl.text),
                _summaryRow(
                    'Phone', _phoneCtrl.text.isEmpty ? '—' : _phoneCtrl.text),
                _summaryRow('Internal Note',
                    _notesCtrl.text.isEmpty ? 'None' : _notesCtrl.text),
              ]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _summarySection('Access Details', [
                _summaryRow('Role', _selectedRoleName ?? 'Not Selected'),
                _summaryRow(
                    'Stations',
                    _selectedStationIds.isEmpty
                        ? 'All stations'
                        : '${_selectedStationIds.length} stations'),
                _summaryRow('Status', 'Immediate Access'),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Credentials Summary
        _summarySection(
            'Login Credentials',
            [
              _summaryRow('Username', _emailCtrl.text),
              Row(
                children: [
                  Expanded(
                      child: _summaryRow(
                          'Password',
                          _credentialMode == 'invite'
                              ? 'Link will be sent'
                              : (_revealPasswordInReview
                                  ? _passwordCtrl.text
                                  : '••••••••'))),
                  if (_credentialMode == 'manual')
                    IconButton(
                      icon: Icon(
                          _revealPasswordInReview
                              ? LucideIcons.eyeOff
                              : LucideIcons.eye,
                          size: 16,
                          color: AppColors.primary),
                      onPressed: () => setState(() =>
                          _revealPasswordInReview = !_revealPasswordInReview),
                    ),
                ],
              ),
              _summaryRow('Reset Required', _forceChange ? 'Yes' : 'No'),
            ],
            dark: true),
      ],
    );
  }

  Widget _summarySection(String title, List<Widget> children,
      {bool dark = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? Colors.black.withValues(alpha: 0.2) : AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 10)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            TextButton.icon(
              icon: const Icon(LucideIcons.arrowLeft, size: 16),
              label: const Text('Back'),
              onPressed: () => setState(() => _currentStep--),
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary),
            )
          else
            const SizedBox(),
          Row(
            children: [
              TextButton(
                onPressed: () => context.pop(),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              if (_currentStep < 3)
                ElevatedButton(
                  onPressed:
                      _canProceed ? () => setState(() => _currentStep++) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                  child: const Text('Next'),
                )
              else
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(LucideIcons.check, size: 16),
                  label: Text(_isSubmitting
                      ? 'Creating...'
                      : 'Create User & Send Access'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Shared Widgets ────────────────────────────────────

  Widget _label(String text) {
    return Text(text,
        style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500));
  }

  Widget _textField(
    TextEditingController ctrl,
    String hint, {
    IconData? icon,
    Widget? suffix,
    bool obscure = false,
    int maxLines = 1,
    void Function(String)? onChanged,
    VoidCallback? onEditingComplete,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      onChanged: (v) {
        onChanged?.call(v);
        setState(() {});
      },
      onEditingComplete: onEditingComplete,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.pageBg,
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.textTertiary, size: 18)
            : null,
        suffixIcon: suffix,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border)),
      ),
    );
  }

  Widget _buildStationSelector() {
    final stationsAsync = ref.watch(stationsProvider);
    return stationsAsync.isLoading
        ? const Center(
            child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary)))
        : stationsAsync.stations.isEmpty
            ? const Text('No stations found',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 13))
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: stationsAsync.stations.map((s) {
                  final isSelected =
                      _selectedStationIds.contains(s.id.toString());
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedStationIds.remove(s.id.toString());
                        } else {
                          _selectedStationIds.add(s.id.toString());
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.cardBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.mapPin,
                              size: 14,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textTertiary),
                          const SizedBox(width: 8),
                          Text(s.name,
                              style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
  }

  Widget _buildSubmittingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 24),
            const Text('Creating User Account...',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Configuring access and security...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
              child:
                  const Icon(LucideIcons.check, color: Colors.black, size: 40),
            ),
            const SizedBox(height: 32),
            const Text('User Created Successfully!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('${_nameCtrl.text} has been added as ${_selectedRoleName}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 15)),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('View Team Members',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _showSuccess = false;
                  _currentStep = 0;
                  _nameCtrl.clear();
                  _emailCtrl.clear();
                  _phoneCtrl.clear();
                  _deptCtrl.clear();
                  _notesCtrl.clear();
                  _passwordCtrl.clear();
                  _confirmPasswordCtrl.clear();
                  _selectedRoleId = null;
                  _selectedRoleName = null;
                  _selectedStationIds.clear();
                });
              },
              child: const Text('Create Another User'),
            ),
          ],
        ),
      ),
    );
  }
}
