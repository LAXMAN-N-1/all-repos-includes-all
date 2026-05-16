import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/theme/app_theme.dart';

class TrialTenantsScreen extends StatelessWidget {
  const TrialTenantsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Active Trials",
                    style: GoogleFonts.outfit(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Monitor organizations currently in their 14-day trial period.",
                    style: TextStyle(color: Colors.white60),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.mail_outline),
                label: const Text("Email All Trials"),
              )
            ],
          ),
          const SizedBox(height: 32),
          // Mock List
          Expanded(
            child: ListView(
              children: [
                _buildTrialCard("CarePoint Pharmacy", "7 days remaining", 0.5),
                _buildTrialCard("MediQuick Inc.", "2 days remaining", 0.9),
                _buildTrialCard("HealthFirst Drugstore", "13 days remaining", 0.1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrialCard(String name, String status, double progress) {
    return Card(
      color: AuraColors.surface,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AuraColors.glassBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AuraColors.primary.withOpacity(0.2),
          child: Text(name[0], style: const TextStyle(color: AuraColors.primary)),
        ),
        title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(status, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress, backgroundColor: Colors.white10, color: AuraColors.secondary),
          ],
        ),
        trailing: OutlinedButton(child: const Text("Convert"), onPressed: (){}),
      ),
    );
  }
}
