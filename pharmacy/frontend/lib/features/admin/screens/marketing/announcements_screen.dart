import 'package:flutter/material.dart';

import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/admin/data/mock_marketing_training.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({Key? key}) : super(key: key);

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
                    Text("Marketing Announcements", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    const Text("Broadcast updates to your tenants", style: TextStyle(color: Colors.white60)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.campaign),
                  label: const Text("New Campaign"),
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
                child: SingleChildScrollView(
                  child: DataTable(
                    headingTextStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                    dataTextStyle: const TextStyle(color: Colors.white),
                    columns: const [
                       DataColumn(label: Text("Campaign Title")),
                       DataColumn(label: Text("Type")),
                       DataColumn(label: Text("Status")),
                       DataColumn(label: Text("Reach")),
                       DataColumn(label: Text("Date")),
                       DataColumn(label: Text("Actions")),
                    ],
                    rows: mockAnnouncements.map((anc) => DataRow(
                      cells: [
                        DataCell(Text(anc.title, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(anc.type)),
                        DataCell(_buildStatusBadge(anc.status)),
                        DataCell(Row(
                          children: [
                            const Icon(Icons.visibility, size: 14, color: Colors.white54),
                            const SizedBox(width: 4),
                            Text("${anc.views}"),
                          ],
                        )),
                        DataCell(Text(DateFormat('MMM dd, yyyy').format(anc.date))),
                        DataCell(IconButton(icon: const Icon(Icons.more_horiz, color: Colors.white54), onPressed: () {})),
                      ],
                    )).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch(status) {
      case "Active": color = Colors.green; break;
      case "Draft": color = Colors.grey; break;
      case "Scheduled": color = Colors.blue; break;
      default: color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
