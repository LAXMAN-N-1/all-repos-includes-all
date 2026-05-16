import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'settings_theme.dart';
import 'settings_common_widgets.dart';

class AppearanceSection extends StatelessWidget {
  final Map<String, dynamic> preferences;
  final Function(String, dynamic) onPreferenceChanged;

  const AppearanceSection({
    super.key,
    required this.preferences,
    required this.onPreferenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Appearance', style: SettingsTheme.h1),
        const SizedBox(height: 8),
        Text(
          'Customize how Wezu Portal looks on your device.',
          style: SettingsTheme.subline,
        ),
        const SizedBox(height: 32),

        // ── THEME PREFERENCE ─────────────────────────────────────────
        SettingsCard(
          title: 'Color Mode',
          accentColor: SettingsTheme.primaryCyan,
          dataStatus: 'Pending Configuration',
          children: [
            Text(
              'Choose how the portal appears. System mode will follow your operating system settings.',
              style: SettingsTheme.subline,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildThemeOption(
                  context,
                  label: 'Light',
                  icon: LucideIcons.sun,
                  isActive: preferences['theme'] == 'light',
                  onTap: () => onPreferenceChanged('theme', 'light'),
                ),
                const SizedBox(width: 16),
                _buildThemeOption(
                  context,
                  label: 'Dark',
                  icon: LucideIcons.moon,
                  isActive: preferences['theme'] == 'dark',
                  onTap: () => onPreferenceChanged('theme', 'dark'),
                ),
                const SizedBox(width: 16),
                _buildThemeOption(
                  context,
                  label: 'System',
                  icon: LucideIcons.monitor,
                  isActive: preferences['theme'] == 'system',
                  onTap: () => onPreferenceChanged('theme', 'system'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),

        // ── ACCENT COLOR ──────────────────────────────────────────────
        SettingsCard(
          title: 'Accent Color',
          accentColor: SettingsTheme.primaryGreen,
          dataStatus: 'Pending Configuration',
          children: [
            Text(
              'Customize the portal\'s glow and interactive highlights.',
              style: SettingsTheme.subline,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildColorSwatch(
                  color: SettingsTheme.primaryGreen,
                  label: 'Emerald',
                  isActive: preferences['accent_color'] == 'green',
                  onTap: () => onPreferenceChanged('accent_color', 'green'),
                ),
                _buildColorSwatch(
                  color: SettingsTheme.primaryCyan,
                  label: 'Cyan',
                  isActive: preferences['accent_color'] == 'cyan',
                  onTap: () => onPreferenceChanged('accent_color', 'cyan'),
                ),
                _buildColorSwatch(
                  color: SettingsTheme.secondaryAmber,
                  label: 'Amber',
                  isActive: preferences['accent_color'] == 'amber',
                  onTap: () => onPreferenceChanged('accent_color', 'amber'),
                ),
                _buildColorSwatch(
                  color: const Color(0xFF3B82F6),
                  label: 'Royal',
                  isActive: preferences['accent_color'] == 'blue',
                  onTap: () => onPreferenceChanged('accent_color', 'blue'),
                ),
                _buildColorSwatch(
                  color: const Color(0xFFA855F7),
                  label: 'Purple',
                  isActive: preferences['accent_color'] == 'purple',
                  onTap: () => onPreferenceChanged('accent_color', 'purple'),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 40),
        const InfoNote(
          message: 'These settings are stored locally on this device and don\'t sync across teams yet.',
          icon: LucideIcons.info,
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isActive ? SettingsTheme.primaryCyan.withValues(alpha: 0.1) : SettingsTheme.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? SettingsTheme.primaryCyan : SettingsTheme.borderSubtle,
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isActive ? SettingsTheme.primaryCyan : SettingsTheme.mutedGray,
                size: 24,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: SettingsTheme.h3.copyWith(
                  color: isActive ? SettingsTheme.primaryCyan : SettingsTheme.textHigh,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorSwatch({
    required Color color,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: SettingsTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color : SettingsTheme.borderSubtle,
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 10)] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)],
              ),
              child: isActive ? const Icon(LucideIcons.check, size: 16, color: Colors.black) : null,
            ),
            const SizedBox(height: 8),
            Text(label, style: SettingsTheme.subline.copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
