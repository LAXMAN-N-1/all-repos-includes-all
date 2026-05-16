import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'settings_theme.dart';
import 'settings_common_widgets.dart';

class BankPayoutsSection extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final Map<String, String> initialValues;
  final VoidCallback onOpenChangeBankDrawer;
  final bool isRealTime;

  const BankPayoutsSection({
    super.key,
    required this.controllers,
    required this.initialValues,
    required this.onOpenChangeBankDrawer,
    this.isRealTime = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── BANK ACCOUNT DETAILS ──────────────────────────────────
        _SettingsCard(
          title: 'Linked Bank Account',
          accentColor: SettingsTheme.primaryCyan,
          dataStatus: isRealTime ? 'Connected | Real-time' : 'Pending Configuration',
          children: [
            _buildBankDetailsCard(context),
            const SizedBox(height: 32),
            _buildPayoutConfiguration(context),
          ],
        ),
      ],
    );
  }

  Widget _buildBankDetailsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SettingsTheme.shellDark,
            SettingsTheme.backgroundDark.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SettingsTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(LucideIcons.landmark, color: SettingsTheme.primaryCyan, size: 28),
              _buildVerifiedBadge(),
            ],
          ),
          const SizedBox(height: 24),
          Text('Primary Account', style: SettingsTheme.subline.copyWith(fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(controllers['bank_account_mask']?.text ?? '**** **** ****', 
              style: SettingsTheme.h2.copyWith(letterSpacing: 2, fontSize: 22)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('IFSC CODE', style: SettingsTheme.subline.copyWith(fontSize: 10)),
                    Text(controllers['ifsc_code']?.text ?? '-', style: SettingsTheme.body.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: onOpenChangeBankDrawer,
                icon: const Icon(LucideIcons.edit3, size: 14),
                label: const Text('Change Bank'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SettingsTheme.textHigh,
                  side: const BorderSide(color: SettingsTheme.borderSubtle),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: SettingsTheme.primaryCyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SettingsTheme.primaryCyan.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.checkCircle2, color: SettingsTheme.primaryCyan, size: 14),
          SizedBox(width: 6),
          Text('VERIFIED', style: TextStyle(color: SettingsTheme.primaryCyan, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildPayoutConfiguration(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 64, color: SettingsTheme.borderSubtle),
        Text('Payout Configuration', style: SettingsTheme.h3),
        const SizedBox(height: 24),
        
        // Payout Schedule Dropdown
        _buildResponsiveDropdownRow(
          context,
          'Payout Schedule',
          'payout_schedule',
          ['Daily', 'Weekly', 'Bi-Weekly', 'Monthly'],
        ),
        const SizedBox(height: 24),

        // Minimum Threshold
        _buildResponsiveThresholdRow(context, 'Minimum Payout Balance', 'payout_threshold'),
        
        const SizedBox(height: 12),
        Text(
          'Automated payouts are triggered once your wallet balance exceeds this threshold on your scheduled payout day.',
          style: SettingsTheme.subline.copyWith(fontSize: 12, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildResponsiveDropdownRow(BuildContext context, String label, String key, List<String> options) {
    final isNarrow = MediaQuery.of(context).size.width < 600;
    final value = controllers[key]?.text ?? options.first;
    final isModified = value != (initialValues[key] ?? options.first);

    return UnsavedWrapper(
      isModified: isModified,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isNarrow) ...[
            Text(label, style: SettingsTheme.h3.copyWith(color: SettingsTheme.mutedGray)),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              if (!isNarrow) ...[
                SizedBox(width: 200, child: Text(label, style: SettingsTheme.h3.copyWith(color: SettingsTheme.mutedGray))),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: SettingsTheme.backgroundDark.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: SettingsTheme.borderSubtle),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: value,
                      items: options.map((String opt) => DropdownMenuItem(
                        value: opt,
                        child: Text(opt, style: SettingsTheme.body),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) controllers[key]?.text = val;
                      },
                      dropdownColor: SettingsTheme.shellDark,
                      icon: const Icon(LucideIcons.chevronDown, size: 16, color: SettingsTheme.mutedGray),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveThresholdRow(BuildContext context, String label, String key) {
    final isNarrow = MediaQuery.of(context).size.width < 600;
    final controller = controllers[key];
    final isModified = controller?.text != (initialValues[key] ?? '');

    return UnsavedWrapper(
      isModified: isModified,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isNarrow) ...[
            Text(label, style: SettingsTheme.h3.copyWith(color: SettingsTheme.mutedGray)),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              if (!isNarrow) ...[
                SizedBox(width: 200, child: Text(label, style: SettingsTheme.h3.copyWith(color: SettingsTheme.mutedGray))),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: SettingsTheme.body,
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: SettingsTheme.body.copyWith(color: SettingsTheme.primaryGreen),
                    filled: true,
                    fillColor: SettingsTheme.backgroundDark.withValues(alpha: 0.3),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: SettingsTheme.borderSubtle)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: SettingsTheme.primaryGreen)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── LOCAL UI COMPONENTS ───────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color accentColor;
  final String? dataStatus;
  const _SettingsCard({required this.title, required this.children, required this.accentColor, this.dataStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SettingsTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SettingsTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 2,
            width: double.infinity,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: SettingsTheme.h2),
                    if (dataStatus != null) ...[
                      const SizedBox(width: 12),
                      DataStatusTag(status: dataStatus!),
                    ],
                  ],
                ),
                const SizedBox(height: 32),
                ...children,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
