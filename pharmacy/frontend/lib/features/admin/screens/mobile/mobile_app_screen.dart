import 'package:flutter/material.dart';

import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/admin/data/mock_final_modules.dart';
import 'package:google_fonts/google_fonts.dart';

class MobileAppScreen extends StatelessWidget {
  const MobileAppScreen({Key? key}) : super(key: key);

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
                Text("Mobile App Management", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload),
                  label: const Text("Publish New Version"),
                  style: ElevatedButton.styleFrom(backgroundColor: AuraColors.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 32),

            Expanded(
              child: ListView.separated(
                itemCount: mockAppVersions.length,
                separatorBuilder: (c, i) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final ver = mockAppVersions[index];
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AuraColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AuraColors.glassBorder),
                    ),
                    child: Row(
                      children: [
                         Icon(ver.platform == "Android" ? Icons.android : Icons.apple, size: 32, color: Colors.white),
                         const SizedBox(width: 24),
                         Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text("v${ver.version}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                             Text("Released: ${ver.releaseDate}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                           ],
                         ),
                         const SizedBox(width: 32),
                         Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text("Adoption Rate", style: TextStyle(color: Colors.white54, fontSize: 12)),
                             const SizedBox(height: 4),
                             SizedBox(
                               width: 100,
                               child: LinearProgressIndicator(
                                 value: ver.adoptionRate / 100,
                                 color: AuraColors.success,
                                 backgroundColor: Colors.white10,
                               ),
                             ),
                             const SizedBox(height: 4),
                             Text("${ver.adoptionRate}%", style: TextStyle(color: Colors.white, fontSize: 12)),
                           ],
                         ),
                         const Spacer(),
                         if (ver.isMandatory)
                           Chip(label: Text("Mandatory", style: TextStyle(fontSize: 10)), backgroundColor: Colors.red.withOpacity(0.2), labelStyle: TextStyle(color: Colors.red)),
                         const SizedBox(width: 16),
                         OutlinedButton(onPressed: () {}, child: Text("Details")),
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
