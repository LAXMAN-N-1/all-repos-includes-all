import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'settings_theme.dart';
import 'settings_common_widgets.dart';
import '../models/settings_extra_models.dart';

class RentalSettingsSection extends StatelessWidget {
  final List<TextEditingController> controllers;
  final Map<String, dynamic> initialValues;
  final RentalSettingsDto? data;
  final bool isRealTime;

  const RentalSettingsSection({
    super.key,
    required this.controllers,
    required this.initialValues,
    this.data,
    this.isRealTime = false,
  });

  @override
  Widget build(BuildContext context) {
    // If no data yet, use initial values or defaults
    final dailyRate = data?.dailyRate?.toString() ?? initialValues['daily_rate']?.toString() ?? '150.0';
    final securityDeposit = data?.securityDeposit?.toString() ?? initialValues['security_deposit']?.toString() ?? '2000.0';
    final lateFeeHourly = data?.lateFeeHourly?.toString() ?? initialValues['late_fee_hourly']?.toString() ?? '25.0';
    final gracePeriod = data?.gracePeriodHours?.toString() ?? initialValues['grace_period_hours']?.toString() ?? '2';
    final maxRentals = data?.maxConcurrentRentals.toString() ?? initialValues['max_concurrent_rentals']?.toString() ?? '1';
    final minBattery = data?.minBatteryCheckout.toString() ?? initialValues['min_battery_checkout']?.toString() ?? '80';

    return Column(
      children: [
        // ── Pricing Settings ───────────────────────────────────
        SettingsCard(
          title: 'Pricing & Deposits',
          accentColor: SettingsTheme.primaryCyan,
          dataStatus: isRealTime ? 'Real-time Data' : 'Pending Configuration',
          children: [
             _buildTextField(
              label: 'Default Daily Rental Rate (₹)',
              controller: controllers[0]..text = dailyRate,
              icon: LucideIcons.indianRupee,
              hint: 'e.g. 150.00',
            ),
            const SizedBox(height: 24),
            _buildTextField(
              label: 'Standard Security Deposit (₹)',
              controller: controllers[1]..text = securityDeposit,
              icon: LucideIcons.shieldCheck,
              hint: 'e.g. 2000.00',
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Late Fees & Penalties ──────────────────────────────
        SettingsCard(
          title: 'Late Fees & Grace Periods',
          accentColor: SettingsTheme.secondaryAmber,
          dataStatus: isRealTime ? 'Real-time Data' : 'Pending Configuration',
          children: [
             _buildTextField(
              label: 'Hourly Late Fee Penalty (₹)',
              controller: controllers[2]..text = lateFeeHourly,
              icon: LucideIcons.clock,
              hint: 'e.g. 25.00',
            ),
            const SizedBox(height: 24),
            _buildTextField(
              label: 'Grace Period (Hours)',
              controller: controllers[3]..text = gracePeriod,
              icon: LucideIcons.hourglass,
              hint: 'e.g. 2',
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Operational Policies ──────────────────────────────
        SettingsCard(
          title: 'Rental Policies',
          accentColor: SettingsTheme.primaryGreen,
          dataStatus: isRealTime ? 'Real-time Data' : 'Pending Configuration',
          children: [
             _buildTextField(
              label: 'Max Concurrent Rentals per User',
              controller: controllers[4]..text = maxRentals,
              icon: LucideIcons.layers,
              hint: 'e.g. 1',
            ),
            const SizedBox(height: 24),
            _buildTextField(
              label: 'Min Battery % for Checkout',
              controller: controllers[5]..text = minBattery,
              icon: LucideIcons.batteryCharging,
              hint: 'e.g. 80',
            ),
            const SizedBox(height: 32),
            _buildToggleRow(
              'Allow Rental Extensions',
              'Users can extend their rental period from the mobile app.',
              data?.allowExtension ?? true,
              (val) {}, // State managed by parent save flow
            ),
            const Divider(color: Colors.white10, height: 48),
            _buildToggleRow(
              'Allow Rental Pause',
              'Users can temporarily pause active rentals at a reduced rate.',
              data?.allowPause ?? false,
              (val) {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: SettingsTheme.label),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          style: SettingsTheme.body,
          decoration: SettingsTheme.inputDecoration(hint ?? '', icon),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
        ),
      ],
    );
  }

  Widget _buildToggleRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: SettingsTheme.body.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: SettingsTheme.subline),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: SettingsTheme.primaryGreen,
          activeTrackColor: SettingsTheme.primaryGreen.withValues(alpha: 0.2),
        ),
      ],
    );
  }
}
