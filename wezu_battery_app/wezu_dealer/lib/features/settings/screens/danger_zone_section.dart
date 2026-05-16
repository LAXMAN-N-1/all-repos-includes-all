import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'settings_theme.dart';
import 'settings_common_widgets.dart';

class DangerZoneSection extends StatelessWidget {
  final String businessName;
  final VoidCallback onDeactivate;
  final VoidCallback onExportData;
  final VoidCallback onDeleteAccount;

  const DangerZoneSection({
    super.key,
    required this.businessName,
    required this.onDeactivate,
    required this.onExportData,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Danger Zone', style: SettingsTheme.h1),
            const SizedBox(width: 16),
            const DataStatusTag(status: 'Pending Configuration'),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Destructive actions that cannot be easily undone. Please proceed with extreme caution.',
          style: SettingsTheme.subline,
        ),
        const SizedBox(height: 32),

        // 🚨 Distinct Red Border Card
        Container(
          decoration: BoxDecoration(
            color: SettingsTheme.errorRed.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SettingsTheme.errorRed.withValues(alpha: 0.3)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.alertTriangle, color: SettingsTheme.errorRed, size: 20),
                  const SizedBox(width: 12),
                  Text('Destructive Actions', style: SettingsTheme.h2.copyWith(color: SettingsTheme.errorRed)),
                  const SizedBox(width: 12),
                  const DataStatusTag(status: 'Pending Configuration'),
                ],
              ),
              const SizedBox(height: 24),
              
              _buildDangerItem(
                title: 'Deactivate Account',
                description: 'Temporarily pause your account. Your data remains recoverable.',
                buttonLabel: 'Deactivate',
                onPressed: onDeactivate,
                isGhost: true,
                isAmber: false,
              ),
              
              const Divider(height: 48, color: SettingsTheme.borderSubtle),
              
              _buildDangerItem(
                title: 'Export All Data',
                description: 'Download a copy of all your business data (GDPR compliant).',
                buttonLabel: 'Request Export',
                onPressed: onExportData,
                isGhost: true,
                isAmber: true,
              ),
              
              const Divider(height: 48, color: SettingsTheme.borderSubtle),
              
              _buildDangerItem(
                title: 'Delete Account',
                description: 'Permanently remove your business profile and all associated data. This action is final.',
                buttonLabel: 'Delete Account',
                onPressed: onDeleteAccount,
                isGhost: false,
                isAmber: false,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 40),
        InfoNote(
          message: 'Account deletion is subject to our data retention policy and legal requirements.',
          icon: LucideIcons.info,
        ),
      ],
    );
  }

  Widget _buildDangerItem({
    required String title,
    required String description,
    required String buttonLabel,
    required VoidCallback onPressed,
    required bool isGhost,
    required bool isAmber,
  }) {
    final color = isAmber ? SettingsTheme.primaryCyan : SettingsTheme.errorRed; // Note: amber not in theme, using cyan for "Export" or we can use custom color

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: SettingsTheme.h3),
              const SizedBox(height: 4),
              Text(description, style: SettingsTheme.body.copyWith(color: SettingsTheme.mutedGray, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(width: 24),
        if (isGhost)
          OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(color: color.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
          )
        else
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: SettingsTheme.errorRed,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}
