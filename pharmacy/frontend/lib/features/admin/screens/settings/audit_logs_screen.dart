import 'package:flutter/material.dart';

import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/admin/data/mock_settings.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AuditLogsScreen extends StatelessWidget {
  const AuditLogsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Audit Trails", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
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
                       DataColumn(label: Text("Timestamp")),
                       DataColumn(label: Text("Admin User")),
                       DataColumn(label: Text("Action")),
                       DataColumn(label: Text("Target")),
                       DataColumn(label: Text("Status")),
                    ],
                    rows: mockAuditLogs.map((log) => DataRow(
                      cells: [
                        DataCell(Text(DateFormat('MMM dd, hh:mm a').format(log.timestamp))),
                        DataCell(Text(log.adminName)),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                          child: Text(log.action, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                        )),
                        DataCell(Text(log.target)),
                        DataCell(Text(log.status, style: TextStyle(color: log.status == "Success" ? Colors.green : Colors.red))),
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
}
