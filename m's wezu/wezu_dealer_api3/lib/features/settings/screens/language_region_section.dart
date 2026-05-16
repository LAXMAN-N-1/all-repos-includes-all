import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'settings_theme.dart';
import 'settings_common_widgets.dart';

class LanguageRegionSection extends StatelessWidget {
  final Map<String, dynamic> preferences;
  final Function(String, dynamic) onPreferenceChanged;

  const LanguageRegionSection({
    super.key,
    required this.preferences,
    required this.onPreferenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Language and Region', style: SettingsTheme.h1),
        const SizedBox(height: 8),
        Text(
          'Manage your language preferences and regional settings for localized content.',
          style: SettingsTheme.subline,
        ),
        const SizedBox(height: 32),

        // ── LANGUAGE PREFERENCE ──────────────────────────────────────
        SettingsCard(
          title: 'Preferred Language',
          accentColor: SettingsTheme.primaryGreen,
          dataStatus: 'Pending Configuration',
          children: [
            Text(
              'Select the language you want to use across the Wezu Portal.',
              style: SettingsTheme.subline,
            ),
            const SizedBox(height: 24),
            _buildLanguageOption(
              label: 'English (US)',
              sublabel: 'Default',
              isActive: preferences['language'] == 'en',
              onTap: () => onPreferenceChanged('language', 'en'),
            ),
            const SizedBox(height: 12),
            _buildLanguageOption(
              label: 'Hindi (हिन्दी)',
              sublabel: 'North India',
              isActive: preferences['language'] == 'hi',
              onTap: () => onPreferenceChanged('language', 'hi'),
            ),
            const SizedBox(height: 12),
            _buildLanguageOption(
              label: 'Kannada (ಕನ್ನಡ)',
              sublabel: 'South India',
              isActive: preferences['language'] == 'kn',
              onTap: () => onPreferenceChanged('language', 'kn'),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // ── REGION PREFERENCE ────────────────────────────────────────
        SettingsCard(
          title: 'Regional Settings',
          accentColor: SettingsTheme.primaryCyan,
          dataStatus: 'Pending Configuration',
          children: [
            SettingsDropdown(
              label: 'Country/Region',
              value: preferences['region'] ?? 'India',
              items: const ['India', 'United States', 'United Kingdom', 'United Arab Emirates', 'Singapore'],
              onChanged: (val) => onPreferenceChanged('region', val),
              isModified: false,
            ),
            const SizedBox(height: 8),
            Text(
              'This affects your currency symbols, tax formats, and address requirements.',
              style: SettingsTheme.subline.copyWith(fontSize: 10),
            ),
          ],
        ),
        
        const SizedBox(height: 40),
        const InfoNote(
          message: 'Changes to language and region may require a portal refresh to fully apply.',
          icon: LucideIcons.info,
        ),
      ],
    );
  }

  Widget _buildLanguageOption({
    required String label,
    required String sublabel,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? SettingsTheme.primaryGreen.withValues(alpha: 0.05) : SettingsTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? SettingsTheme.primaryGreen : SettingsTheme.borderSubtle,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isActive ? LucideIcons.checkCircle2 : LucideIcons.circle,
              color: isActive ? SettingsTheme.primaryGreen : SettingsTheme.mutedGray.withValues(alpha: 0.3),
              size: 20,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: SettingsTheme.h3.copyWith(color: isActive ? SettingsTheme.primaryGreen : SettingsTheme.textHigh)),
                const SizedBox(height: 2),
                Text(sublabel, style: SettingsTheme.subline.copyWith(fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
