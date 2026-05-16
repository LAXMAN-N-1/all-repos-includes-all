import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../../../core/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late final AnimationController _c;

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _gstController = TextEditingController();
  final _panController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _addressController = TextEditingController();

  // Step 3: Infrastructure
  final _floorAreaController = TextEditingController();
  final _parkingSlotsController = TextEditingController();
  String _powerSupply = '3-Phase';
  bool _hasVentilation = false;
  String _operatingHours = '24x7';

  String? _error;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
  }

  @override
  void dispose() {
    _emailController.dispose(); _phoneController.dispose();
    _nameController.dispose(); _passwordController.dispose();
    _businessNameController.dispose(); _gstController.dispose();
    _panController.dispose(); _cityController.dispose();
    _stateController.dispose(); _pincodeController.dispose();
    _addressController.dispose(); _floorAreaController.dispose();
    _parkingSlotsController.dispose(); _c.dispose();
    super.dispose();
  }

  bool _validateStep() {
    switch (_currentStep) {
      case 0:
        if (_nameController.text.isEmpty || _emailController.text.isEmpty ||
            _phoneController.text.isEmpty || _passwordController.text.isEmpty) {
          setState(() => _error = 'Please fill all required fields');
          return false;
        }
        if (_passwordController.text.length < 8) {
          setState(() => _error = 'Password must be at least 8 characters');
          return false;
        }
        break;
      case 1:
        if (_businessNameController.text.isEmpty || _cityController.text.isEmpty ||
            _stateController.text.isEmpty || _pincodeController.text.isEmpty ||
            _addressController.text.isEmpty) {
          setState(() => _error = 'Please fill all required fields');
          return false;
        }
        break;
    }
    setState(() => _error = null);
    return true;
  }

  Future<void> _submitRegistration() async {
    if (!_validateStep()) return;

    final success = await ref.read(authProvider.notifier).register(
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      fullName: _nameController.text.trim(),
      password: _passwordController.text,
      businessName: _businessNameController.text.trim(),
      contactPerson: _nameController.text.trim(),
      addressLine1: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state_: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
      gstNumber: _gstController.text.isNotEmpty ? _gstController.text.trim() : null,
      panNumber: _panController.text.isNotEmpty ? _panController.text.trim() : null,
    );

    if (mounted) {
      if (success) {
        context.go('/onboarding');
      } else {
        setState(() => _error = ref.read(authProvider).error ?? 'Registration failed');
      }
    }
  }

  void _nextStep() {
    if (!_validateStep()) return;
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _submitRegistration();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() { _currentStep--; _error = null; });
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              decoration: BoxDecoration(
                color: AppColors.shellBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40, offset: const Offset(0, 12))],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Left: Progress ──
                  SizedBox(
                    width: 280,
                    child: Container(
                      padding: const EdgeInsets.all(36),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                        color: AppColors.primary.withValues(alpha: 0.03),
                        border: Border(right: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(color: AppColors.primaryGlow, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withValues(alpha: 0.3))),
                            child: const Icon(LucideIcons.batteryCharging, size: 22, color: AppColors.primary),
                          ),
                          const SizedBox(height: 28),
                          const Text('Join WEZU\nNetwork', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.2)),
                          const SizedBox(height: 12),
                          const Text('Power the future of mobility by becoming an authorized battery swapping dealer.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
                          const SizedBox(height: 40),
                          _StepIndicator(index: 0, current: _currentStep, title: 'Account Setup', sub: 'Basic details & login'),
                          _StepIndicator(index: 1, current: _currentStep, title: 'Business Details', sub: 'GST, Location & Address'),
                          _StepIndicator(index: 2, current: _currentStep, title: 'Infrastructure', sub: 'Space & power check'),
                        ],
                      ),
                    ),
                  ),

                  // ── Right: Form ──
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_getStepTitle(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          const SizedBox(height: 6),
                          Text(_getStepSubtitle(), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                              ),
                              child: Row(children: [
                                const Icon(LucideIcons.alertCircle, size: 14, color: AppColors.red),
                                const SizedBox(width: 8),
                                Expanded(child: Text(_error!, style: const TextStyle(fontSize: 12, color: AppColors.red))),
                              ]),
                            ),
                          ],
                          const SizedBox(height: 32),
                          if (_currentStep == 0) _buildStep0(),
                          if (_currentStep == 1) _buildStep1(),
                          if (_currentStep == 2) _buildStep2(),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(onPressed: _prevStep, child: Text(
                                _currentStep == 0 ? 'Back to Login' : 'Previous Step',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              )),
                              ElevatedButton(
                                onPressed: authState.isLoading ? null : _nextStep,
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14)),
                                child: authState.isLoading
                                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : Text(_currentStep == 2 ? 'Submit Application' : 'Continue',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getStepTitle() => ['Create Account', 'Business Details', 'Infrastructure Check'][_currentStep];
  String _getStepSubtitle() => [
    'We need your basic information to set up your login profile.',
    'Provide information about your registered business.',
    'Tell us about the space where you plan to host the swapping station.',
  ][_currentStep];

  Widget _buildStep0() => Column(children: [
    _field('Full Name *', _nameController, LucideIcons.user),
    const SizedBox(height: 16),
    Row(children: [
      Expanded(child: _field('Email Address *', _emailController, LucideIcons.mail)),
      const SizedBox(width: 16),
      Expanded(child: _field('Phone Number *', _phoneController, LucideIcons.phone)),
    ]),
    const SizedBox(height: 16),
    _field('Password * (min 8 characters)', _passwordController, LucideIcons.lock, obscure: true),
  ]);

  Widget _buildStep1() => Column(children: [
    _field('Registered Business Name *', _businessNameController, LucideIcons.building),
    const SizedBox(height: 16),
    Row(children: [
      Expanded(child: _field('GST Number (Optional)', _gstController, LucideIcons.fileText)),
      const SizedBox(width: 16),
      Expanded(child: _field('PAN Number (Optional)', _panController, LucideIcons.creditCard)),
    ]),
    const SizedBox(height: 16),
    _field('Address *', _addressController, LucideIcons.mapPin),
    const SizedBox(height: 16),
    Row(children: [
      Expanded(child: _field('City *', _cityController, LucideIcons.building)),
      const SizedBox(width: 16),
      Expanded(child: _field('State *', _stateController, LucideIcons.map)),
      const SizedBox(width: 16),
      Expanded(child: _field('Pincode *', _pincodeController, LucideIcons.hash)),
    ]),
  ]);

  Widget _buildStep2() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Expanded(child: _field('Floor Area (sq ft)', _floorAreaController, LucideIcons.maximize)),
      const SizedBox(width: 16),
      Expanded(child: _field('Parking Slots', _parkingSlotsController, LucideIcons.car)),
    ]),
    const SizedBox(height: 16),
    Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('POWER SUPPLY', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
        initialValue: _powerSupply,
          items: ['Single Phase', '3-Phase', '3-Phase + Backup'].map((e) =>
            DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: (v) => setState(() => _powerSupply = v ?? '3-Phase'),
          decoration: InputDecoration(
            prefixIcon: const Icon(LucideIcons.zap, color: AppColors.textTertiary, size: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          dropdownColor: AppColors.cardBg,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
        ),
      ])),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('OPERATING HOURS', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
        initialValue: _operatingHours,
          items: ['24x7', '6 AM - 10 PM', '8 AM - 8 PM', 'Custom'].map((e) =>
            DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: (v) => setState(() => _operatingHours = v ?? '24x7'),
          decoration: InputDecoration(
            prefixIcon: const Icon(LucideIcons.clock, color: AppColors.textTertiary, size: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          dropdownColor: AppColors.cardBg,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
        ),
      ])),
    ]),
    const SizedBox(height: 16),
    CheckboxListTile(
      value: _hasVentilation,
      onChanged: (v) => setState(() => _hasVentilation = v ?? false),
      title: const Text('Adequate ventilation and safety equipment', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.primary,
    ),
    const SizedBox(height: 12),
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.primary.withValues(alpha: 0.15))),
      child: Row(children: [
        const Icon(LucideIcons.info, size: 16, color: AppColors.primary),
        const SizedBox(width: 10),
        const Expanded(child: Text('After submission, our team will review your application and schedule a field visit within 3-5 business days.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5))),
      ]),
    ),
  ]);

  Widget _field(String label, TextEditingController controller, IconData icon, {bool obscure = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelMedium),
      const SizedBox(height: 8),
      TextField(
        controller: controller, obscureText: obscure,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: label.replaceAll('*', '').trim(),
          prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 16),
        ),
      ),
    ]);
  }
}

class _StepIndicator extends StatelessWidget {
  final int index, current; final String title, sub;
  const _StepIndicator({required this.index, required this.current, required this.title, required this.sub});

  @override
  Widget build(BuildContext context) {
    final isCompleted = current > index;
    final isActive = current == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 28, height: 28, margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? AppColors.primary : (isActive ? AppColors.primaryGlow : Colors.transparent),
            border: Border.all(color: isCompleted || isActive ? AppColors.primary : AppColors.border, width: 2),
          ),
          child: isCompleted
              ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
              : Center(child: Text('${index + 1}', style: TextStyle(
                  color: isActive ? AppColors.primary : AppColors.textTertiary, fontWeight: FontWeight.w700, fontSize: 12))),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(
            color: isActive || isCompleted ? AppColors.textPrimary : AppColors.textTertiary,
            fontWeight: isActive || isCompleted ? FontWeight.w700 : FontWeight.w400, fontSize: 13)),
          const SizedBox(height: 3),
          Text(sub, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ])),
      ]),
    );
  }
}
