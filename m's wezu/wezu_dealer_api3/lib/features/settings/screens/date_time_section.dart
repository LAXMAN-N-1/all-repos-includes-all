import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'settings_theme.dart';
import 'settings_common_widgets.dart';

class DateTimeSection extends StatelessWidget {
  final Map<String, dynamic> preferences;
  final Function(String, dynamic) onPreferenceChanged;

  const DateTimeSection({
    super.key,
    required this.preferences,
    required this.onPreferenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date and Time Format', style: SettingsTheme.h1),
        const SizedBox(height: 8),
        Text(
          'Choose your preferred formatting for timestamps and scheduled events.',
          style: SettingsTheme.subline,
        ),
        const SizedBox(height: 32),

        // ── DATE FORMAT ────────────────────────────────────────────────
        SettingsCard(
          title: 'Date Format',
          accentColor: SettingsTheme.secondaryAmber,
          dataStatus: 'Pending Configuration',
          children: [
            SettingsDropdown(
              label: 'Display Format',
              value: preferences['date_format'] ?? 'DD/MM/YYYY',
              items: const ['DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD', 'D MMM, YYYY'],
              onChanged: (val) => onPreferenceChanged('date_format', val),
              isModified: false,
            ),
          ],
        ),
        const SizedBox(height: 32),

        // ── TIME FORMAT ────────────────────────────────────────────────
        SettingsCard(
          title: 'Time Format',
          accentColor: SettingsTheme.primaryGreen,
          dataStatus: 'Pending Configuration',
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('24-Hour Clock', style: SettingsTheme.body),
                      const SizedBox(height: 4),
                      Text(
                        'Use 24-hour time format (e.g., 14:00) instead of 12-hour AM/PM.',
                        style: SettingsTheme.subline,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: preferences['use_24h'] ?? false,
                  onChanged: (val) => onPreferenceChanged('use_24h', val),
                  activeThumbColor: SettingsTheme.primaryGreen,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),

        // ── TIMEZONE ───────────────────────────────────────────────────
        SettingsCard(
          title: 'Timezone',
          accentColor: SettingsTheme.primaryCyan,
          dataStatus: 'Pending Configuration',
          children: [
            Text(
              'Your current detected timezone is based on your browser settings.',
              style: SettingsTheme.subline,
            ),
            const SizedBox(height: 24),
            SettingsDropdown(
              label: 'Custom Timezone',
              value: preferences['timezone'] ?? '(GMT+05:30) India Standard Time',
              items: const [
                '(GMT+00:00) UTC',
                '(GMT+05:30) India Standard Time',
                '(GMT-05:00) Eastern Standard Time',
                '(GMT+08:00) Singapore Standard Time',
                '(GMT+04:00) Gulf Standard Time'
              ],
              onChanged: (val) => onPreferenceChanged('timezone', val),
              isModified: false,
            ),
          ],
        ),
        
        const SizedBox(height: 40),
        const InfoNote(
          message: 'Timezone settings affect how reports and booking exports are displayed.',
          icon: LucideIcons.info,
        ),
      ],
    );
  }
}
