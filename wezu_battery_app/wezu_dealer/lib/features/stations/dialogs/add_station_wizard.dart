import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/colors.dart';

class AddStationWizard extends StatefulWidget {
  final Future<bool> Function(Map<String, dynamic>) onSubmit;

  const AddStationWizard({super.key, required this.onSubmit});

  @override
  State<AddStationWizard> createState() => _AddStationWizardState();
}

class _AddStationWizardState extends State<AddStationWizard> {
  int _currentStep = 0;
  bool _isSubmitting = false;

  final _nameC = TextEditingController();
  final _addressC = TextEditingController();
  final _cityC = TextEditingController();
  final _slotsC = TextEditingController(text: '10');
  final _phoneC = TextEditingController();

  void _next() {
    if (_currentStep == 0) {
      if (_nameC.text.isEmpty || _addressC.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter name and address')));
        return;
      }
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _prev() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    
    final data = {
      "name": _nameC.text.trim(),
      "address": _addressC.text.trim(),
      "city": _cityC.text.trim(),
      "latitude": 0.0,
      "longitude": 0.0,
      "total_slots": int.tryParse(_slotsC.text.trim()) ?? 10,
      "contact_phone": _phoneC.text.trim().isEmpty ? null : _phoneC.text.trim(),
    };

    final success = await widget.onSubmit(data);
    
    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Station submitted successfully'),
          backgroundColor: AppColors.primary,
        ));
      } else {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 500,
        decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.pageBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(LucideIcons.plusCircle, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Add New Station', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        Text('Deploy a new battery swapping station', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(LucideIcons.x, size: 20), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            
            // Stepper progress
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  _stepIndicator(0, 'Basic Info'),
                  Expanded(child: Container(height: 2, color: _currentStep > 0 ? AppColors.primary : AppColors.border)),
                  _stepIndicator(1, 'Capacity & Contact'),
                ],
              ),
            ),
            
            // Form body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _currentStep == 0 ? _buildStep1() : _buildStep2(),
            ),
            
            // Footer (Actions)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(onPressed: _prev, child: const Text('Back'))
                  else
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: _isSubmitting 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_currentStep == 0 ? 'Next' : 'Submit Station'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepIndicator(int stepIndex, String label) {
    final isActive = _currentStep >= stepIndex;
    return Column(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.pageBg,
            shape: BoxShape.circle,
            border: Border.all(color: isActive ? AppColors.primary : AppColors.border, width: 2),
          ),
          child: Center(
            child: Text('${stepIndex + 1}', style: TextStyle(color: isActive ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 11, color: isActive ? AppColors.primary : AppColors.textSecondary, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Station Name *'),
        _field(_nameC, 'e.g., Downtown Metro Hub', LucideIcons.building),
        const SizedBox(height: 16),
        _label('Street Address *'),
        _field(_addressC, 'Full street address', LucideIcons.mapPin),
        const SizedBox(height: 16),
        _label('City'),
        _field(_cityC, 'e.g., Delhi', LucideIcons.map),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Total Battery Slots *'),
                  _field(_slotsC, 'e.g., 12', LucideIcons.grid, isNumber: true),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Contact Phone'),
                  _field(_phoneC, '+91...', LucideIcons.phone),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.primary.withValues(alpha: 0.2))),
          child: const Row(
            children: [
              Icon(LucideIcons.info, color: AppColors.primary, size: 20),
              SizedBox(width: 12),
              Expanded(child: Text('Upon submission, the station will be created in an INACTIVE state. Hardware binding is required before bringing it online.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: c,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
        prefixIcon: Icon(icon, size: 16, color: AppColors.textTertiary),
        filled: true, fillColor: AppColors.pageBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
    );
  }
}
