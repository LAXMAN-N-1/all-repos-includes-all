import 'package:flutter/material.dart';

import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/admin/data/mock_master_data.dart';
import 'package:google_fonts/google_fonts.dart';

class InsuranceProvidersScreen extends StatelessWidget {
  const InsuranceProvidersScreen({Key? key}) : super(key: key);

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
                Text("Insurance Providers", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text("Add Provider"),
                  style: ElevatedButton.styleFrom(backgroundColor: AuraColors.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: mockInsurance.length,
                itemBuilder: (context, index) {
                  final ins = mockInsurance[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AuraColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AuraColors.glassBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Row(
                           children: [
                             const Icon(Icons.health_and_safety, color: AuraColors.secondary, size: 28),
                             const SizedBox(width: 12),
                             Expanded(child: Text(ins.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16))),
                           ],
                         ),
                         const Spacer(),
                         Text("Coverage: ${ins.coverageType}", style: const TextStyle(color: Colors.white70)),
                         const SizedBox(height: 4),
                         Text(ins.contact, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                         const SizedBox(height: 12),
                         Align(
                           alignment: Alignment.centerRight,
                           child: Text(ins.status.toUpperCase(), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10)),
                         )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
