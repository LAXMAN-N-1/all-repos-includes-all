import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_theme.dart';
import '../providers/profile_provider.dart';

class ChangeBankDrawer extends ConsumerStatefulWidget {
  const ChangeBankDrawer({super.key});

  @override
  ConsumerState<ChangeBankDrawer> createState() => _ChangeBankDrawerState();
}

class _ChangeBankDrawerState extends ConsumerState<ChangeBankDrawer> {
  int _currentStep = 1;
  final _accountNumberCtrl = TextEditingController();
  final _confirmAccountCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _holderNameCtrl = TextEditingController();
  
  bool _isUploading = false;
  String? _uploadedFileName;

  @override
  void dispose() {
    _accountNumberCtrl.dispose();
    _confirmAccountCtrl.dispose();
    _ifscCtrl.dispose();
    _bankNameCtrl.dispose();
    _holderNameCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      if (_currentStep == 2) {
        if (_accountNumberCtrl.text != _confirmAccountCtrl.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account numbers do not match'), backgroundColor: SettingsTheme.errorRed),
          );
          return;
        }
        if (_accountNumberCtrl.text.isEmpty || _ifscCtrl.text.isEmpty || _bankNameCtrl.text.isEmpty || _holderNameCtrl.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill all bank details'), backgroundColor: SettingsTheme.errorRed),
          );
          return;
        }
      }
      setState(() => _currentStep++);
    } else {
      _handleSubmit();
    }
  }

  Future<void> _handleSubmit() async {
    final success = await ref.read(profileProvider.notifier).updateBankAccount(
      accountNumber: _accountNumberCtrl.text,
      ifscCode: _ifscCtrl.text,
      accountHolderName: _holderNameCtrl.text,
      bankName: _bankNameCtrl.text,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: SettingsTheme.primaryGreen,
            content: Text('Bank account update request submitted! Verification takes 2-3 business days.'),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: SettingsTheme.errorRed,
            content: Text('Failed to update bank account. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 450,
      backgroundColor: SettingsTheme.shellDark,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(32),
                children: [
                  if (_currentStep == 1) _buildStep1(),
                  if (_currentStep == 2) _buildStep2(),
                  if (_currentStep == 3) _buildStep3(),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: SettingsTheme.borderSubtle))),
      child: Row(
        children: [
          const Icon(LucideIcons.landmark, color: SettingsTheme.primaryCyan),
          const SizedBox(width: 16),
          Text('Change Bank Account', style: SettingsTheme.h2),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context), 
            icon: const Icon(LucideIcons.x, color: SettingsTheme.mutedGray),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 4,
      width: double.infinity,
      color: SettingsTheme.borderSubtle,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 450 * (_currentStep / 3),
            color: SettingsTheme.primaryCyan,
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 1: Security Verification', style: SettingsTheme.h3),
        const SizedBox(height: 12),
        Text(
          'For security reasons, we need to verify your identity before allowing bank detail changes.',
          style: SettingsTheme.subline,
        ),
        const SizedBox(height: 32),
        _buildInfoTile(
          LucideIcons.shieldCheck, 
          'A verification code will be sent to your primary phone number ending in ••88.',
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: SettingsTheme.primaryCyan,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Send Verification Code', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 2: New Bank Details', style: SettingsTheme.h3),
        const SizedBox(height: 32),
        _buildLabel('Account Holder Name'),
        _buildField(_holderNameCtrl, 'Enter name as per bank records'),
        const SizedBox(height: 24),
        _buildLabel('Bank Name'),
        _buildField(_bankNameCtrl, 'e.g. HDFC Bank'),
        const SizedBox(height: 24),
        _buildLabel('Account Number'),
        _buildField(
          _accountNumberCtrl, 
          'Enter new account number',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 24),
        _buildLabel('Confirm Account Number'),
        _buildField(
          _confirmAccountCtrl, 
          'Re-enter account number',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 24),
        _buildLabel('IFSC Code'),
        _buildField(_ifscCtrl, 'e.g. HDFC0001234'),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 3: Document Upload', style: SettingsTheme.h3),
        const SizedBox(height: 12),
        Text(
          'Upload a cancelled cheque or a clear bank statement for verification.',
          style: SettingsTheme.subline,
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () async {
            try {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
              );
              
              if (result != null && result.files.single.name.isNotEmpty) {
                setState(() {
                  _uploadedFileName = result.files.single.name;
                });
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error picking file: $e'), backgroundColor: SettingsTheme.errorRed),
                );
              }
            }
          },
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: SettingsTheme.backgroundDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _uploadedFileName != null ? SettingsTheme.primaryGreen : SettingsTheme.borderSubtle,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isUploading)
                  const CircularProgressIndicator(color: SettingsTheme.primaryCyan)
                else if (_uploadedFileName != null) ...[
                  const Icon(LucideIcons.fileCheck, color: SettingsTheme.primaryGreen, size: 40),
                  const SizedBox(height: 12),
                  Text(_uploadedFileName!, style: SettingsTheme.body),
                  const SizedBox(height: 4),
                  Text('Tap to replace', style: SettingsTheme.subline.copyWith(fontSize: 10)),
                ] else ...[
                  const Icon(LucideIcons.uploadCloud, color: SettingsTheme.mutedGray, size: 40),
                  const SizedBox(height: 12),
                  Text('Upload PDF/PNG/JPG', style: SettingsTheme.body),
                  const SizedBox(height: 4),
                  Text('Max size: 5MB', style: SettingsTheme.subline.copyWith(fontSize: 10)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    if (_currentStep == 1) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: SettingsTheme.borderSubtle))),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => setState(() => _currentStep--),
              child: const Text('Back', style: TextStyle(color: SettingsTheme.mutedGray)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _uploadedFileName == null && _currentStep == 3 ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentStep == 3 ? SettingsTheme.primaryGreen : SettingsTheme.primaryCyan,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_currentStep == 3 ? 'Submit Request' : 'Continue', 
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SettingsTheme.primaryCyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SettingsTheme.primaryCyan.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: SettingsTheme.primaryCyan, size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: SettingsTheme.body.copyWith(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8), 
    child: Text(label.toUpperCase(), style: SettingsTheme.subline.copyWith(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
  );

  Widget _buildField(TextEditingController ctrl, String hint, {TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) => TextField(
    controller: ctrl,
    style: SettingsTheme.body,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    decoration: InputDecoration(
      hintText: hint, 
      hintStyle: SettingsTheme.subline, 
      filled: true, 
      fillColor: SettingsTheme.backgroundDark, 
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SettingsTheme.borderSubtle)), 
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SettingsTheme.primaryCyan)), 
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
