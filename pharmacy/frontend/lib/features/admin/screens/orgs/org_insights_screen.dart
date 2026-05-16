import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/theme/app_theme.dart';

class OrgInsightsScreen extends StatelessWidget {
  const OrgInsightsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Organization Insights",
            style: GoogleFonts.outfit(
              fontSize: 24, 
              fontWeight: FontWeight.bold, 
              color: Colors.white
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Deep dive into tenant usage patterns and growth metrics.",
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 32),
          
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 1.5,
              children: [
                _buildInsightCard("Most Active Region", "North America", Icons.public, Colors.blue),
                _buildInsightCard("Top Feature Used", "Inventory AI", Icons.auto_awesome, Colors.purple),
                _buildInsightCard("Avg. Users / Org", "12.5", Icons.group, Colors.green),
                _buildInsightCard("Retention Rate", "94%", Icons.favorite, Colors.pink),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AuraColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AuraColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const Spacer(),
          Text(value, style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}
