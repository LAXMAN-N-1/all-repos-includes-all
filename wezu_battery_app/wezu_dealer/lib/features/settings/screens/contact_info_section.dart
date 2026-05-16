import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'settings_theme.dart';
import 'settings_common_widgets.dart';

class ContactInfoSection extends StatefulWidget {
  final Map<String, TextEditingController> controllers;
  final Map<String, String> initialValues;
  final VoidCallback onOpenEmailFlow;
  final VoidCallback onOpenHolidayCalendar;

  const ContactInfoSection({
    super.key,
    required this.controllers,
    required this.initialValues,
    required this.onOpenEmailFlow,
    required this.onOpenHolidayCalendar,
  });

  @override
  State<ContactInfoSection> createState() => _ContactInfoSectionState();
}

class _ContactInfoSectionState extends State<ContactInfoSection> {
  bool _syncWhatsApp = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsCard(
          title: 'Contact Channels',
          accentColor: SettingsTheme.primaryCyan,
          dataStatus: 'Real-time Data',
          children: [
            _buildReadOnlyRow(
              'Primary Email', 
              widget.controllers['contact_email']?.text ?? 'dealer@wezu.co', 
              action: 'Change Email', 
              onAction: widget.onOpenEmailFlow
            ),
            _buildField(
              'Primary Phone', 
              'phone_primary',
              maxLength: 10,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              counterText: '',
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            _buildField(
              'Alternate Phone', 
              'phone_alternate', 
              placeholder: 'Optional backup...',
              maxLength: 10,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              counterText: '',
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            _buildField(
              'WhatsApp Phone', 
              'phone_whatsapp', 
              maxLength: 10,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              counterText: '',
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              suffix: SyncSwitch(
                value: _syncWhatsApp, 
                onChanged: (v) {
                  setState(() => _syncWhatsApp = v);
                  if (v) widget.controllers['phone_whatsapp']?.text = widget.controllers['phone_primary']?.text ?? '';
                }
              )
            ),
            const Divider(height: 48, color: SettingsTheme.borderSubtle),
            _buildField(
              'Support Email', 
              'support_email', 
              placeholder: 'Customer-facing email...',
              maxLength: 254,
              keyboardType: TextInputType.emailAddress,
            ),
            _buildField(
              'Support Phone', 
              'support_phone', 
              placeholder: 'Customer helpline...',
              maxLength: 10,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              counterText: '',
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
        const SizedBox(height: 32),
        SettingsCard(
          title: 'Business Operating Hours',
          accentColor: SettingsTheme.secondaryAmber,
          dataStatus: 'Real-time Data',
          children: [
            const BusinessHoursGrid(),
            const SizedBox(height: 32),
            TextButton.icon(
              onPressed: widget.onOpenHolidayCalendar,
              icon: const Icon(LucideIcons.calendar, size: 16),
              label: const Text('Manage Holiday Calendar'),
              style: TextButton.styleFrom(foregroundColor: SettingsTheme.primaryCyan),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildField(String label, String key, {
    Widget? suffix, 
    String? placeholder, 
    TextInputType? keyboardType, 
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    MaxLengthEnforcement? maxLengthEnforcement,
    String? counterText,
  }) {
    final controller = widget.controllers[key];
    final isModified = controller != null && controller.text != (widget.initialValues[key] ?? '');
    
    // All contact fields are now connected to the backend
    final status = 'Real-time Data';

    return SettingsFieldRow(
      label: label,
      controller: controller,
      isModified: isModified,
      placeholder: placeholder,
      suffix: suffix,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      maxLengthEnforcement: maxLengthEnforcement,
      counterText: counterText,
      dataStatus: status,
    );
  }

  Widget _buildReadOnlyRow(String label, String value, {required String action, required VoidCallback onAction}) {
    final isNarrow = MediaQuery.of(context).size.width < 600;
    
    final isRealTime = label.toLowerCase().contains('email') || label.toLowerCase().contains('phone');
    final status = isRealTime ? 'Real-time Data' : 'Pending Configuration';
    
    final labelWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: SettingsTheme.h3.copyWith(color: SettingsTheme.mutedGray)),
        const SizedBox(height: 4),
        DataStatusTag(status: status),
      ],
    );
    final valueStyle = value.isNotEmpty 
        ? SettingsTheme.h3.copyWith(color: SettingsTheme.primaryCyan, fontWeight: FontWeight.bold)
        : SettingsTheme.body.copyWith(color: SettingsTheme.mutedGray);

    final valueWidget = Text(
      value.isNotEmpty ? value : 'No email set', 
      style: valueStyle,
    );

    final actionWidget = TextButton(
      onPressed: onAction, 
      child: Text(
        action, 
        style: SettingsTheme.subline.copyWith(
          color: SettingsTheme.primaryCyan, 
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        )
      )
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: isNarrow 
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              labelWidget,
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: valueWidget),
                  actionWidget,
                ],
              ),
            ],
          )
        : Row(
            children: [
              SizedBox(width: 220, child: labelWidget),
              Expanded(child: Align(alignment: Alignment.centerLeft, child: valueWidget)),
              const SizedBox(width: 16),
              actionWidget,
            ],
          ),
    );
  }
}

// ── BUSINESS HOURS GRID ─────────────────────────────────────────
class BusinessHoursGrid extends StatefulWidget {
  const BusinessHoursGrid({super.key});
  @override
  State<BusinessHoursGrid> createState() => _BusinessHoursGridState();
}

class _BusinessHoursGridState extends State<BusinessHoursGrid> {
  final Map<String, (bool, String, String)> _hours = {
    'Monday': (true, '06:00 AM', '10:00 PM'),
    'Tuesday': (true, '06:00 AM', '10:00 PM'),
    'Wednesday': (true, '06:00 AM', '10:00 PM'),
    'Thursday': (true, '06:00 AM', '10:00 PM'),
    'Friday': (true, '06:00 AM', '10:00 PM'),
    'Saturday': (true, '06:00 AM', '10:00 PM'),
    'Sunday': (false, '06:00 AM', '10:00 PM'),
  };

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 600;
    
    return Column(
      children: _hours.entries.map((e) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: isNarrow 
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(e.key, style: SettingsTheme.body.copyWith(color: e.value.$1 ? SettingsTheme.textHigh : SettingsTheme.mutedGray)),
                    const Spacer(),
                    Switch(
                      value: e.value.$1, 
                      activeTrackColor: SettingsTheme.primaryGreen.withValues(alpha: 0.3), 
                      activeThumbColor: SettingsTheme.primaryGreen, 
                      onChanged: (v) => setState(() => _hours[e.key] = (v, e.value.$2, e.value.$3))
                    ),
                  ],
                ),
                if (e.value.$1) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTimeToggle(e.value.$2)),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('to', style: TextStyle(color: SettingsTheme.mutedGray))),
                      Expanded(child: _buildTimeToggle(e.value.$3)),
                    ],
                  ),
                ] else 
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('Closed', style: SettingsTheme.subline.copyWith(color: SettingsTheme.errorRed)),
                  ),
                const SizedBox(height: 8),
              ],
            )
          : Row(
              children: [
                SizedBox(width: 120, child: Text(e.key, style: SettingsTheme.body.copyWith(color: e.value.$1 ? SettingsTheme.textHigh : SettingsTheme.mutedGray))),
                const Spacer(),
                if (e.value.$1) ...[
                  _buildTimeToggle(e.value.$2),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('to', style: TextStyle(color: SettingsTheme.mutedGray))),
                  _buildTimeToggle(e.value.$3),
                ] else 
                  Text('Closed', style: SettingsTheme.subline.copyWith(color: SettingsTheme.errorRed)),
                const SizedBox(width: 24),
                Switch(
                  value: e.value.$1, 
                  activeThumbColor: SettingsTheme.primaryGreen, 
                  onChanged: (v) => setState(() => _hours[e.key] = (v, e.value.$2, e.value.$3))
                ),
              ],
            ),
      )).toList(),
    );
  }

  Widget _buildTimeToggle(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: SettingsTheme.backgroundDark, borderRadius: BorderRadius.circular(8), border: Border.all(color: SettingsTheme.borderSubtle)),
      child: Center(child: Text(time, style: SettingsTheme.mono)),
    );
  }
}
