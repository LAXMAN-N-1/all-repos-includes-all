import 'package:flutter/material.dart';

import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/admin/data/mock_monitoring.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorLogsScreen extends StatelessWidget {
  const ErrorLogsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("System Error Logs", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AuraColors.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AuraColors.glassBorder),
                ),
                child: ListView.separated(
                  itemCount: mockErrors.length,
                  separatorBuilder: (c, i) => const Divider(color: Colors.white12, height: 1),
                  itemBuilder: (context, index) {
                    final error = mockErrors[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      leading: Icon(
                        error.level == "Critical" ? Icons.dangerous : (error.level == "Error" ? Icons.error : Icons.warning),
                        color: error.level == "Critical" ? Colors.red : (error.level == "Error" ? Colors.orange : Colors.yellow),
                      ),
                      title: Text(error.message, style: const TextStyle(color: Colors.white)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Text(error.timestamp, style: const TextStyle(color: Colors.white30, fontSize: 12)),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                              child: Text(error.source, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                            ),
                          ],
                        ),
                      ),
                      trailing: IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white24), onPressed: () {}),
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
