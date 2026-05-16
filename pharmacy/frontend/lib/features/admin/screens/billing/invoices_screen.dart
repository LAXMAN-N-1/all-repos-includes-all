import 'package:flutter/material.dart';

import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/admin/data/mock_billing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Invoices History", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),
            
            // Invoices Table
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AuraColors.glassBorder),
                  borderRadius: BorderRadius.circular(12),
                  color: AuraColors.surface.withOpacity(0.5),
                ),
                child: SingleChildScrollView(
                  child: DataTable(
                    headingTextStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                    dataTextStyle: const TextStyle(color: Colors.white),
                    columns: const [
                       DataColumn(label: Text("Invoice ID")),
                       DataColumn(label: Text("Organization")),
                       DataColumn(label: Text("Date")),
                       DataColumn(label: Text("Amount")),
                       DataColumn(label: Text("Status")),
                       DataColumn(label: Text("Actions")),
                    ],
                    rows: mockInvoices.map((inv) => DataRow(
                      cells: [
                        DataCell(Text(inv.id, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(inv.orgName)),
                        DataCell(Text(DateFormat('MMM dd, yyyy').format(inv.date))),
                        DataCell(Text("\$${inv.amount.toStringAsFixed(2)}")),
                        DataCell(_buildStatusBadge(inv.status)),
                        DataCell(IconButton(icon: const Icon(Icons.download, size: 18), onPressed: () {})),
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
    switch (status) {
      case "Paid": color = Colors.green; break;
      case "Failed": color = Colors.red; break;
      case "Refunded": color = Colors.orange; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
