import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/admin/data/mock_monitoring.dart';
import 'package:google_fonts/google_fonts.dart';

class DatabaseHealthScreen extends StatelessWidget {
  const DatabaseHealthScreen({Key? key}) : super(key: key);

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
                  Text("Database Cluster", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text("Real-time metrics for PostgreSQL and Redis instances.", style: TextStyle(color: Colors.white60)),
                ],
              ),
              OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.refresh), label: const Text("Refresh"))
            ],
          ),
          const SizedBox(height: 32),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                childAspectRatio: 1.4,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
              ),
              itemCount: mockDBMetrics.length,
              itemBuilder: (context, index) {
                return _buildDBCard(mockDBMetrics[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDBCard(DatabaseMetric db) {
    final bool isHealthy = db.status == "Healthy";
    final Color statusColor = isHealthy ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AuraColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AuraColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storage, color: statusColor, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(db.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(db.status, style: TextStyle(color: statusColor, fontSize: 12)),
                ],
              ),
            ],
          ),
          const Spacer(),
          
          _buildMetricRow("Connections", "${db.connections}"),
          const SizedBox(height: 8),
          _buildMetricRow("Cache Hit Ratio", "${db.cacheHitRatio}%"),
           const SizedBox(height: 8),
          _buildMetricRow("Active Queries", "${db.activeQueries}"),
          
          const Spacer(),
          const Text("Disk Usage", style: TextStyle(color: Colors.white30, fontSize: 10)),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: db.diskUsage / db.diskLimit,
            backgroundColor: Colors.white10,
            color: AuraColors.primary,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${db.diskUsage} GB", style: const TextStyle(color: Colors.white54, fontSize: 10)),
              Text("Limit: ${db.diskLimit} GB", style: const TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
