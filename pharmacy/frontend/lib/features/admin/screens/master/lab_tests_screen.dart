import 'package:flutter/material.dart';

import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/admin/data/mock_master_data.dart';
import 'package:google_fonts/google_fonts.dart';

class LabTestsScreen extends StatelessWidget {
  const LabTestsScreen({Key? key}) : super(key: key);

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
                Text("Lab Tests Catalog", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text("Add Test"),
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
                       DataColumn(label: Text("Code")),
                       DataColumn(label: Text("Test Name")),
                       DataColumn(label: Text("Category")),
                       DataColumn(label: Text("Sample")),
                       DataColumn(label: Text("TAT")),
                       DataColumn(label: Text("Std. Price")),
                    ],
                    rows: mockLabTests.map((test) => DataRow(
                      cells: [
                        DataCell(Text(test.code, style: const TextStyle(fontFamily: 'monospace'))),
                        DataCell(Text(test.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(test.category)),
                        DataCell(Text(test.sampleType)),
                        DataCell(Text(test.tat)),
                        DataCell(Text("\$${test.price}")),
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
