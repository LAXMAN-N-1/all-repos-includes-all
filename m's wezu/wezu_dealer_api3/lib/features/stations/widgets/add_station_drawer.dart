import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';

/// 4-step wizard drawer for adding a new station
class AddStationDrawer extends StatefulWidget {
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onSubmit;

  const AddStationDrawer({super.key, required this.onClose, required this.onSubmit});

  @override
  State<AddStationDrawer> createState() => _AddStationDrawerState();
}

class _AddStationDrawerState extends State<AddStationDrawer> {
  int _step = 0;
  bool _submitting = false;
  int _submitProgress = 0;

  // Step 1: Station Identity
  final _nameC = TextEditingController();
  final _codeC = TextEditingController();
  final _descC = TextEditingController();
  String _stationType = 'Hub';
  bool _isAutomated = true;

  // Step 2: Location & Contact
  final _addr1C = TextEditingController();
  final _addr2C = TextEditingController();
  final _cityC = TextEditingController();
  String _state = 'Andhra Pradesh';
  final _pinC = TextEditingController();
  final _contactNameC = TextEditingController();
  final _contactPhoneC = TextEditingController();
  final _contactEmailC = TextEditingController();

  // Step 3: Operational Setup
  final _capacityC = TextEditingController(text: '20');
  final _thresholdC = TextEditingController(text: '5');
  bool _is24x7 = true;
  String _initialStatus = 'Inactive';

  final _steps = ['Station Identity', 'Location & Contact', 'Operational Setup', 'Review & Submit'];

  @override
  void dispose() {
    _nameC.dispose(); _codeC.dispose(); _descC.dispose();
    _addr1C.dispose(); _addr2C.dispose(); _cityC.dispose(); _pinC.dispose();
    _contactNameC.dispose(); _contactPhoneC.dispose(); _contactEmailC.dispose();
    _capacityC.dispose(); _thresholdC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 580,
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        border: Border(left: BorderSide(color: AppColors.border)),
      ),
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.shellBg,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.plus, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Add New Station', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Text('Submit for WEZU admin approval', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
            ])),
            IconButton(
              icon: const Icon(LucideIcons.x, size: 18, color: AppColors.textTertiary),
              onPressed: widget.onClose,
            ),
          ]),
        ),

        // Progress indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(children: List.generate(4, (i) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < 3 ? 4 : 0),
              child: Column(children: [
                Row(children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: i <= _step ? AppColors.primary : AppColors.border,
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: i < _step
                        ? const Icon(LucideIcons.check, size: 12, color: Colors.white)
                        : Text('${i + 1}', style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: i <= _step ? Colors.white : AppColors.textMuted,
                          )),
                    ),
                  ),
                  if (i < 3) Expanded(child: Container(
                    height: 2,
                    color: i < _step ? AppColors.primary : AppColors.border,
                  )),
                ]),
                const SizedBox(height: 4),
                Text(_steps[i], style: TextStyle(
                  fontSize: 9, fontWeight: i == _step ? FontWeight.w600 : FontWeight.w400,
                  color: i <= _step ? AppColors.textPrimary : AppColors.textMuted,
                )),
              ]),
            ),
          ))),
        ),

        const Divider(height: 1),

        // Step content
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _submitting ? _buildSubmitting() : _buildStep(),
        )),

        // Footer
        if (!_submitting) Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
          child: Row(children: [
            if (_step > 0)
              OutlinedButton(
                onPressed: () => setState(() => _step--),
                child: const Text('Back'),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: _step < 3 ? () => setState(() => _step++) : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(_step < 3 ? 'Continue' : 'Submit for Approval'),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _step1Identity();
      case 1: return _step2Location();
      case 2: return _step3Operational();
      case 3: return _step4Review();
      default: return const SizedBox.shrink();
    }
  }

  Widget _step1Identity() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _sectionLabel('Station Details'),
    const SizedBox(height: 12),
    _formField(_nameC, 'Station Name *', LucideIcons.building),
    const SizedBox(height: 12),
    _formField(_codeC, 'Station Code (auto-generated)', LucideIcons.hash),
    const SizedBox(height: 16),
    _sectionLabel('Station Type'),
    const SizedBox(height: 10),
    Wrap(spacing: 8, runSpacing: 8, children: ['Hub', 'Express', 'Point', 'Kiosk'].map((t) {
      final sel = _stationType == t;
      return GestureDetector(
        onTap: () => setState(() => _stationType = t),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 130, padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: sel ? AppColors.primary.withValues(alpha: 0.08) : AppColors.pageBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: sel ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(_typeIcon(t), size: 20, color: sel ? AppColors.primary : AppColors.textTertiary),
            const SizedBox(height: 8),
            Text(t, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? AppColors.primary : AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(_typeDesc(t), style: const TextStyle(fontSize: 9, color: AppColors.textTertiary)),
          ]),
        ),
      );
    }).toList()),
    const SizedBox(height: 16),
    _sectionLabel('Automation Mode'),
    const SizedBox(height: 8),
    SwitchListTile(
      value: _isAutomated,
      onChanged: (v) => setState(() => _isAutomated = v),
      title: Text(_isAutomated ? 'Automated' : 'Staffed', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
      subtitle: Text(_isAutomated ? 'Self-service swap station' : 'Staff-assisted operations', style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      activeColor: AppColors.primary,
    ),
    const SizedBox(height: 12),
    _formField(_descC, 'Description (optional)', LucideIcons.fileText, maxLines: 3),
  ]);

  Widget _step2Location() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _sectionLabel('Address'),
    const SizedBox(height: 12),
    _formField(_addr1C, 'Address Line 1 *', LucideIcons.mapPin),
    const SizedBox(height: 12),
    _formField(_addr2C, 'Address Line 2', LucideIcons.mapPin),
    const SizedBox(height: 12),
    Row(children: [
      Expanded(child: _formField(_cityC, 'City *', LucideIcons.building2)),
      const SizedBox(width: 12),
      Expanded(child: _dropdownField('State *', _state, ['Andhra Pradesh', 'Telangana', 'Karnataka', 'Tamil Nadu', 'Maharashtra'], (v) => setState(() => _state = v))),
    ]),
    const SizedBox(height: 12),
    SizedBox(width: 200, child: _formField(_pinC, 'PIN Code', LucideIcons.hash)),
    const SizedBox(height: 20),
    // Map placeholder
    Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.pageBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(LucideIcons.map, size: 28, color: AppColors.textMuted),
        SizedBox(height: 8),
        Text('Map preview will appear here', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ])),
    ),
    const SizedBox(height: 20),
    _sectionLabel('Contact Information'),
    const SizedBox(height: 12),
    _formField(_contactNameC, 'Contact Name', LucideIcons.user),
    const SizedBox(height: 12),
    Row(children: [
      Expanded(child: _formField(_contactPhoneC, 'Phone (+91)', LucideIcons.phone)),
      const SizedBox(width: 12),
      Expanded(child: _formField(_contactEmailC, 'Email', LucideIcons.mail)),
    ]),
  ]);

  Widget _step3Operational() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _sectionLabel('Capacity & Alerts'),
    const SizedBox(height: 12),
    Row(children: [
      Expanded(child: _formField(_capacityC, 'Max Battery Capacity', LucideIcons.batteryFull)),
      const SizedBox(width: 12),
      Expanded(child: _formField(_thresholdC, 'Low Stock Alert Threshold', LucideIcons.alertTriangle)),
    ]),
    const SizedBox(height: 20),
    _sectionLabel('Operating Hours'),
    const SizedBox(height: 8),
    SwitchListTile(
      value: _is24x7,
      onChanged: (v) => setState(() => _is24x7 = v),
      title: const Text('24/7 Operation', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
      subtitle: const Text('Station operates around the clock', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      activeColor: AppColors.primary,
    ),
    const SizedBox(height: 20),
    _sectionLabel('Initial Status'),
    const SizedBox(height: 10),
    Wrap(spacing: 8, children: ['Inactive', 'Operational'].map((st) {
      final sel = _initialStatus == st;
      return ChoiceChip(
        label: Text(st),
        selected: sel,
        onSelected: (_) => setState(() => _initialStatus = st),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        checkmarkColor: AppColors.primary,
      );
    }).toList()),
  ]);

  Widget _step4Review() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel('Review Your Station'),
      const SizedBox(height: 16),
      _reviewRow('Station Name', _nameC.text.isEmpty ? 'Not set' : _nameC.text),
      _reviewRow('Type', _stationType),
      _reviewRow('Mode', _isAutomated ? 'Automated' : 'Staffed'),
      _reviewRow('Address', _addr1C.text.isEmpty ? 'Not set' : '${_addr1C.text}, ${_cityC.text}'),
      _reviewRow('State', _state),
      _reviewRow('PIN Code', _pinC.text.isEmpty ? 'Not set' : _pinC.text),
      _reviewRow('Contact', _contactNameC.text.isEmpty ? 'Not set' : _contactNameC.text),
      _reviewRow('Phone', _contactPhoneC.text.isEmpty ? 'Not set' : _contactPhoneC.text),
      _reviewRow('Capacity', '${_capacityC.text} batteries'),
      _reviewRow('Operating', _is24x7 ? '24/7' : 'Custom Hours'),
      _reviewRow('Initial Status', _initialStatus),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cyanMuted.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cyan.withValues(alpha: 0.2)),
        ),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(LucideIcons.info, size: 14, color: AppColors.cyan),
            SizedBox(width: 8),
            Text('What Happens Next', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.cyan)),
          ]),
          SizedBox(height: 8),
          Text('• Station record will be created\n• Sent to WEZU admin for approval\n• You\'ll be notified once approved', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.6)),
        ]),
      ),
    ]);
  }

  Widget _buildSubmitting() {
    final bool isDone = _submitProgress >= 1;
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const SizedBox(height: 100),
      SizedBox(width: 60, height: 60, child: !isDone
          ? const CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary)
          : const Icon(LucideIcons.checkCircle, size: 48, color: AppColors.primary)),
      const SizedBox(height: 24),
      Text(
        !isDone ? 'Submitting Station for Approval...' : 'Station Request Sent!',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
      const SizedBox(height: 8),
      Text(
        !isDone ? 'This will only take a moment.' : 'WEZU admins will review your request shortly.',
        style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
      ),
      if (isDone) ...[
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: widget.onClose,
          child: const Text('Close'),
        ),
      ],
    ]);
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _submitProgress = 0;
    });
    
    try {
      await widget.onSubmit({
        'name': _nameC.text,
        'station_code': _codeC.text,
        'station_type': _stationType.toLowerCase(),
        'automation_mode': _isAutomated ? 'automated' : 'staffed',
        'address': _addr1C.text,
        'city': _cityC.text,
        'state': _state,
        'pin_code': _pinC.text,
        'contact_name': _contactNameC.text,
        'contact_phone': _contactPhoneC.text,
        'contact_email': _contactEmailC.text,
        'max_capacity': int.tryParse(_capacityC.text) ?? 20,
        'low_stock_threshold': int.tryParse(_thresholdC.text) ?? 5,
        'is_24x7': _is24x7,
        'initial_status': _initialStatus,
      });
      if (mounted) {
        setState(() => _submitProgress = 1);
        // Wait 1.5s then auto-close if possible, or just stay on success
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) widget.onClose();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add station: $e')));
      }
    }
  }

  // ── Helpers ──

  Widget _sectionLabel(String text) => Text(text, style: const TextStyle(
    fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 0.5,
  ));

  Widget _formField(TextEditingController c, String label, IconData icon, {int maxLines = 1}) => TextField(
    controller: c,
    maxLines: maxLines,
    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
      prefixIcon: Icon(icon, size: 15, color: AppColors.textTertiary),
      filled: true, fillColor: AppColors.pageBg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    ),
  );

  Widget _dropdownField(String label, String value, List<String> items, Function(String) onChange) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
      onChanged: (v) { if (v != null) onChange(v); },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
        filled: true, fillColor: AppColors.pageBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
      dropdownColor: AppColors.cardBg,
    );
  }

  Widget _reviewRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
    ]),
  );

  IconData _typeIcon(String t) {
    switch (t) {
      case 'Hub': return LucideIcons.warehouse;
      case 'Express': return LucideIcons.zap;
      case 'Point': return LucideIcons.mapPin;
      case 'Kiosk': return LucideIcons.monitor;
      default: return LucideIcons.building;
    }
  }

  String _typeDesc(String t) {
    switch (t) {
      case 'Hub': return 'Full-service station';
      case 'Express': return 'Quick swap only';
      case 'Point': return 'Small pickup point';
      case 'Kiosk': return 'Self-service booth';
      default: return '';
    }
  }
}
