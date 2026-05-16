import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'settings_theme.dart';
import 'settings_common_widgets.dart';

class InventoryAlertsSection extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final Map<String, String> initialValues;
  final Map<String, bool> toggles;
  final Function(String, bool) onToggle;
  final VoidCallback onAddCustom;
  final bool isRealTime;

  const InventoryAlertsSection({
    super.key,
    required this.controllers,
    required this.initialValues,
    required this.toggles,
    required this.onToggle,
    required this.onAddCustom,
    this.isRealTime = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsCard(
          title: 'System Alert Rules',
          accentColor: SettingsTheme.secondaryAmber,
          dataStatus: isRealTime ? 'Real-time Data' : 'Pending Configuration',
          children: [
            _buildThresholdRow('Low Stock Alert', 'alert_low_stock_val', unit: 'Units'),
            _buildThresholdRow('Maintenance Due', 'alert_maintenance_val', unit: 'Cycles'),
            _buildThresholdRow('Offline Timeout', 'alert_offline_val', unit: 'Mins'),
            _buildThresholdRow('Anomaly Detected', 'alert_anomaly_val', unit: 'Signals'),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onAddCustom, 
              icon: const Icon(LucideIcons.plus, size: 16), 
              label: const Text('Add Custom Alert Rule'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SettingsTheme.backgroundDark, 
                foregroundColor: Colors.white, 
                minimumSize: const Size(double.infinity, 54), 
                side: const BorderSide(color: SettingsTheme.borderSubtle), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        SettingsCard(
          title: 'Preferred Notification Channels',
          accentColor: SettingsTheme.primaryGreen,
          dataStatus: isRealTime ? 'Real-time Data' : 'Pending Configuration',
          children: [
            _buildNotificationRow('Low Stock Alerts', 'low_stock_push', 'low_stock_email'),
            _buildNotificationRow('Maintenance Reminders', 'maintenance_push', 'maintenance_email'),
            _buildNotificationRow('Rental Reminders', 'rental_reminders_push', 'rental_reminders_email'),
            _buildNotificationRow('Payment Confirmation', 'payment_push', 'payment_email'),
            _buildNotificationRow('Swap Suggestions', 'swap_suggestions_push', 'swap_suggestions_email'),
          ],
        ),
      ],
    );
  }

  Widget _buildThresholdRow(String label, String key, {required String unit}) {
    final controller = controllers[key];
    final isModified = controller != null && controller.text != (initialValues[key] ?? '');
    
    return SettingsFieldRow(
      label: label, 
      controller: controller, 
      isModified: isModified, 
      isMono: true,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      suffix: Text(unit, style: SettingsTheme.subline.copyWith(color: SettingsTheme.primaryCyan, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildNotificationRow(String label, String pushKey, String emailKey) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Text(label, style: SettingsTheme.h3.copyWith(fontSize: 15, fontWeight: FontWeight.w600)), 
                    const SizedBox(height: 2),
                    Text('Configure delivery methods', style: SettingsTheme.subline.copyWith(fontSize: 11))
                  ]
                )
              ),
              const SizedBox(width: 16),
              _LabeledSwitch(
                label: 'Push',
                value: toggles[pushKey] ?? true,
                onChanged: (v) => onToggle(pushKey, v),
              ),
              const SizedBox(width: 20),
              _LabeledSwitch(
                label: 'Email',
                value: toggles[emailKey] ?? false,
                onChanged: (v) => onToggle(emailKey, v),
              ),
            ],
          ),
        ),
        Divider(color: SettingsTheme.borderSubtle.withValues(alpha: 0.5), height: 1),
      ],
    );
  }
}

class _LabeledSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _LabeledSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: SettingsTheme.subline.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: value ? SettingsTheme.primaryGreen : SettingsTheme.mutedGray,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 32,
          child: Switch(
            value: value,
            activeTrackColor: SettingsTheme.primaryGreen.withValues(alpha: 0.2),
            activeThumbColor: SettingsTheme.primaryGreen,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.05),
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}

// ── CUSTOM ALERT DRAWER ─────────────────────────────────────────
class CustomAlertDrawer extends StatefulWidget {
  const CustomAlertDrawer({super.key});

  @override
  State<CustomAlertDrawer> createState() => _CustomAlertDrawerState();
}

class _CustomAlertDrawerState extends State<CustomAlertDrawer> {
  final _nameCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  
  String _condition = 'Battery Percentage';
  String _operator = 'is Less Than (<)';
  
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _smsEnabled = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  void _handleCreate() {
    if (_nameCtrl.text.isEmpty || _valueCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SettingsTheme.primaryGreen,
        content: Text('Alert Rule "${_nameCtrl.text}" created successfully!'),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 400,
      backgroundColor: SettingsTheme.shellDark,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: SettingsTheme.borderSubtle))),
              child: Row(
                children: [
                  const Icon(LucideIcons.bellPlus, color: SettingsTheme.primaryGreen),
                  const SizedBox(width: 16),
                  Text('New Custom Alert', style: SettingsTheme.h2),
                  const Spacer(),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x, color: SettingsTheme.mutedGray)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildLabel('Rule Name'),
                  _buildField(_nameCtrl, 'e.g. Critical Battery Alert'),
                  const SizedBox(height: 24),
                  _buildLabel('Trigger Condition'),
                  _buildDropdown(
                    value: _condition,
                    items: ['Battery Percentage', 'Station Temperature', 'Offline Duration'],
                    onChanged: (v) => setState(() => _condition = v!),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    value: _operator,
                    items: ['is Less Than (<)', 'is Greater Than (>)', 'is Equal To (=)'],
                    onChanged: (v) => setState(() => _operator = v!),
                  ),
                  const SizedBox(height: 12),
                  _buildField(_valueCtrl, 'Value (e.g. 15)', isNumber: true),
                  const SizedBox(height: 24),
                  _buildLabel('Notification Channels'),
                  _buildChannelToggle('Push Notification', _pushEnabled, (v) => setState(() => _pushEnabled = v)),
                  _buildChannelToggle('Email Alert', _emailEnabled, (v) => setState(() => _emailEnabled = v)),
                  _buildChannelToggle('SMS (Premium)', _smsEnabled, (v) => setState(() => _smsEnabled = v)),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: _handleCreate,
                    style: ElevatedButton.styleFrom(backgroundColor: SettingsTheme.primaryGreen, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                    child: const Text('Create Alert Rule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(label.toUpperCase(), style: SettingsTheme.subline.copyWith(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)));

  Widget _buildField(TextEditingController ctrl, String hint, {bool isNumber = false}) => TextField(
    controller: ctrl, 
    keyboardType: isNumber ? TextInputType.number : TextInputType.text, 
    inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
    style: SettingsTheme.body,
    decoration: InputDecoration(hintText: hint, hintStyle: SettingsTheme.subline, filled: true, fillColor: SettingsTheme.backgroundDark, enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SettingsTheme.borderSubtle)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SettingsTheme.primaryCyan)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
  );

  Widget _buildDropdown({required String value, required List<String> items, required ValueChanged<String?> onChanged}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: SettingsTheme.backgroundDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: SettingsTheme.borderSubtle)),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value, items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: SettingsTheme.body))).toList(), onChanged: onChanged, dropdownColor: SettingsTheme.surfaceDark, icon: const Icon(LucideIcons.chevronDown, size: 16, color: SettingsTheme.mutedGray), isExpanded: true,
      ),
    ),
  );

  Widget _buildChannelToggle(String label, bool value, ValueChanged<bool> onChanged) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4), 
    child: Row(children: [Text(label, style: SettingsTheme.body), const Spacer(), Switch(value: value, activeTrackColor: SettingsTheme.primaryCyan.withValues(alpha: 0.3), activeThumbColor: SettingsTheme.primaryCyan, onChanged: onChanged)]),
  );
}
