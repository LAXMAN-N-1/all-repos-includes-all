import 'package:flutter/material.dart';
import 'package:frontend/features/admin/screens/admin_layout.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/admin/data/mock_analytics.dart';
import 'package:google_fonts/google_fonts.dart';

class ExportCenterScreen extends StatelessWidget {
  const ExportCenterScreen({Key? key}) : super(key: key);

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
                Text("Export Center", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  label: const Text("New Export"),
                  style: ElevatedButton.styleFrom(backgroundColor: AuraColors.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AuraColors.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AuraColors.glassBorder),
                ),
                child: ListView.separated(
                  itemCount: mockExports.length,
                  separatorBuilder: (c, i) => const Divider(color: Colors.white12, height: 1),
                  itemBuilder: (context, index) {
                    final job = mockExports[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.file_present, color: Colors.white70),
                      ),
                      title: Text(job.type, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text("ID: ${job.id} • ${job.sizeMB} MB", style: const TextStyle(color: Colors.white30, fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStatusBadge(job.status),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.download_rounded),
                            color: job.status == "Completed" ? AuraColors.primary : Colors.grey,
                            onPressed: job.status == "Completed" ? () {} : null,
                          ),
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
  
  Widget _buildStatusBadge(String status) {
    Color color = status == "Completed" ? Colors.green : (status == "Processing" ? Colors.blue : Colors.grey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
