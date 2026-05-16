import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'settings_theme.dart';
import 'settings_common_widgets.dart';

import '../../onboarding/models/kyc_status_state.dart';

class VerificationStatusSection extends StatelessWidget {
  final KycStatusState kycState;
  const VerificationStatusSection({super.key, required this.kycState});

  @override
  Widget build(BuildContext context) {
    final status = kycState.status;
    final isRealTime = !kycState.isLoading && kycState.error == null;
    final dataStatusLabel = isRealTime ? 'Real-time Data' : 'Pending Configuration';

    // Baseline state: everything is pending/not started
    List<(String, String)> steps = [
      ('Business Registration', 'pending'),
      ('GST Verification', 'pending'),
      ('PAN Verification', 'pending'),
      ('Bank Account', 'pending'),
      ('Address Proof', 'pending'),
      ('Field Visit', 'pending'),
      ('Training Completion', 'pending'),
    ];

    if (status != null) {
      final currentStatus = status.status.toUpperCase();
      
      if (currentStatus == 'APPROVED' || currentStatus == 'ACTIVE') {
        steps = steps.map((s) => (s.$1, 'completed')).toList();
      } else if (currentStatus == 'REJECTED' || currentStatus == 'FAILED') {
        steps = [
          ('Business Registration', 'completed'),
          ('GST Verification', 'completed'),
          ('PAN Verification', 'completed'),
          ('Bank Account', 'completed'),
          ('Address Proof', 'completed'),
          ('Field Visit', 'failed'),
          ('Training Completion', 'pending'),
        ];
      } else if (currentStatus == 'DOC_SUBMITTED' || currentStatus == 'AUTO_CHECKS' || currentStatus == 'MANUAL_REVIEW') {
        steps = [
          ('Business Registration', 'completed'),
          ('GST Verification', 'completed'),
          ('PAN Verification', 'completed'),
          ('Bank Account', 'pending'),
          ('Address Proof', 'pending'),
          ('Field Visit', 'pending'),
          ('Training Completion', 'pending'),
        ];
      }
    }

    return SettingsCard(
      title: 'Identification Checklist',
      accentColor: SettingsTheme.primaryGreen,
      dataStatus: dataStatusLabel,
      children: [
        ...steps.map((s) => _buildChecklistItem(s.$1, s.$2)),
        const SizedBox(height: 32),
        if (status?.status.toUpperCase() == 'APPROVED' || status?.status.toUpperCase() == 'ACTIVE')
          ElevatedButton.icon(
            onPressed: () {}, 
            icon: const Icon(LucideIcons.download, size: 16), 
            label: const Text('Download Verification Certificate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: SettingsTheme.primaryCyan, 
              foregroundColor: Colors.black, 
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
          ),
      ],
    );
  }

  Widget _buildChecklistItem(String label, String status) {
    IconData icon = LucideIcons.clock;
    Color color = SettingsTheme.secondaryAmber;
    if (status == 'completed') { icon = LucideIcons.checkCircle2; color = SettingsTheme.primaryGreen; }
    if (status == 'failed') { icon = LucideIcons.xCircle; color = SettingsTheme.errorRed; }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 16),
          Text(label, style: SettingsTheme.body),
          const Spacer(),
          Text(status.toUpperCase(), style: SettingsTheme.subline.copyWith(color: color, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}
