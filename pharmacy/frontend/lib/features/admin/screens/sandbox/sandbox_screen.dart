import 'package:flutter/material.dart';

import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/admin/data/mock_final_modules.dart';
import 'package:google_fonts/google_fonts.dart';

class SandboxScreen extends StatelessWidget {
  const SandboxScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Developer Sandbox", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text("Test environment for API and feature validation", style: TextStyle(color: Colors.white60)),
            const SizedBox(height: 32),

            // Tools Grid
            Row(
              children: [
                _buildToolCard("Reset Test Org", Icons.restart_alt, Colors.orange),
                const SizedBox(width: 20),
                _buildToolCard("Mock Payment", Icons.credit_card, Colors.green),
                const SizedBox(width: 20),
                _buildToolCard("Trigger Webhook", Icons.webhook, Colors.blue),
                const SizedBox(width: 20),
                _buildToolCard("Chaos Monkey", Icons.warning_amber, Colors.red),
              ],
            ),
            const SizedBox(height: 32),
            
            Text("Recent Sandbox Events", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
            const SizedBox(height: 16),
            
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AuraColors.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AuraColors.glassBorder),
                ),
                child: ListView.separated(
                  itemCount: mockSandboxEvents.length,
                  separatorBuilder: (c, i) => const Divider(color: Colors.white12, height: 1),
                  itemBuilder: (context, index) {
                    final evt = mockSandboxEvents[index];
                    return ListTile(
                      leading: Icon(Icons.code, color: Colors.white54),
                      title: Text(evt.action, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(evt.id, style: const TextStyle(color: Colors.white30, fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(evt.status.toUpperCase(), style: TextStyle(color: evt.status == "Success" ? Colors.green : Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          Text(evt.timestamp, style: const TextStyle(color: Colors.white54, fontSize: 12)),
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

  Widget _buildToolCard(String title, IconData icon, Color color) {
    return Expanded(
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AuraColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AuraColors.glassBorder),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
