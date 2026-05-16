import 'package:flutter/material.dart';

import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/admin/data/mock_security_integrations.dart';
import 'package:google_fonts/google_fonts.dart';

class IntegrationsHubScreen extends StatelessWidget {
  const IntegrationsHubScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Integrations Marketplace", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text("Connect third-party tools and services", style: TextStyle(color: Colors.white60)),
            const SizedBox(height: 32),

            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  childAspectRatio: 1.3,
                ),
                itemCount: mockIntegrations.length,
                itemBuilder: (context, index) {
                  return _buildIntegrationCard(mockIntegrations[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntegrationCard(IntegrationService service) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AuraColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AuraColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                child: Text(service.logoSymbol, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
              ),
              _buildConnectionBadge(service.isConnected),
            ],
          ),
          const SizedBox(height: 16),
          Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
          Text(service.category, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          
          const Spacer(),
          
          SizedBox(
            width: double.infinity,
            child: service.isConnected
                ? OutlinedButton(onPressed: () {}, child: const Text("Configure"))
                : ElevatedButton(
                    onPressed: () {}, 
                    style: ElevatedButton.styleFrom(backgroundColor: AuraColors.primary, foregroundColor: Colors.white),
                    child: const Text("Connect")
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionBadge(bool connected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (connected ? Colors.green : Colors.grey).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 6, color: connected ? Colors.green : Colors.grey),
          const SizedBox(width: 4),
          Text(connected ? "Active" : "Inactive", style: TextStyle(color: connected ? Colors.green : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
