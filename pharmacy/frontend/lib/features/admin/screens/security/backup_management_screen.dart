import 'package:flutter/material.dart';

import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/admin/data/mock_security_integrations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BackupManagementScreen extends StatelessWidget {
  const BackupManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Backup & Restore", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    const Text("Manage system snapshots and disaster recovery", style: TextStyle(color: Colors.white60)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.backup),
                  label: const Text("Trigger Backup"),
                  style: ElevatedButton.styleFrom(backgroundColor: AuraColors.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Backup Schedule Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AuraColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AuraColors.glassBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule, color: Colors.white70),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Automated Schedule", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Daily at 02:00 AM UTC • Retention: 30 Days", style: TextStyle(color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                  const Spacer(),
                  OutlinedButton(onPressed: () {}, child: const Text("Configure")),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Backups List
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AuraColors.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AuraColors.glassBorder),
                ),
                child: ListView.separated(
                  itemCount: mockBackups.length,
                  separatorBuilder: (c, i) => const Divider(color: Colors.white12, height: 1),
                  itemBuilder: (context, index) {
                    final backup = mockBackups[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      leading: Icon(
                        backup.status == "Success" ? Icons.check_circle : Icons.error,
                        color: backup.status == "Success" ? Colors.green : Colors.red,
                      ),
                      title: Text(backup.type, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text("${DateFormat('MMM dd, hh:mm a').format(backup.timestamp)} • ${backup.size}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (backup.status == "Success")
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.restore, size: 16),
                              label: const Text("Restore"),
                            ),
                          const SizedBox(width: 8),
                          IconButton(icon: const Icon(Icons.download, size: 20), onPressed: () {}),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
