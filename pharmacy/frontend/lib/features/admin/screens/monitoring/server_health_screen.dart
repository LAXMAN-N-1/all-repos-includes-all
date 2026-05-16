import 'package:flutter/material.dart';

import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/admin/data/mock_monitoring.dart';
import 'package:google_fonts/google_fonts.dart';

class ServerHealthScreen extends StatelessWidget {
  const ServerHealthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Server Health", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),

            // Server Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 350,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  childAspectRatio: 1.1,
                ),
                itemCount: mockServers.length,
                itemBuilder: (context, index) {
                  return _buildServerCard(mockServers[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerCard(ServerNode server) {
    Color statusColor = server.status == "Online" ? Colors.green 
        : server.status == "Warning" ? Colors.orange : Colors.red;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AuraColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(color: statusColor.withOpacity(0.1), blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.dns, color: statusColor),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                child: Text(server.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(server.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
          Text(server.region, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          
          const Spacer(),
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),
          
          _buildUsageRow("CPU Load", server.cpuUsage),
          const SizedBox(height: 8),
          _buildUsageRow("Memory", server.memoryUsage),
          const SizedBox(height: 8),
         Text("Uptime: ${server.uptimeDays} days", style: const TextStyle(color: Colors.white30, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildUsageRow(String label, double usage) {
    return Row(
      children: [
        SizedBox(width: 70, child: Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12))),
        Expanded(
          child: LinearProgressIndicator(
            value: usage / 100,
            backgroundColor: Colors.white10,
            color: usage > 90 ? Colors.red : (usage > 70 ? Colors.orange : Colors.blue),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text("${usage.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
