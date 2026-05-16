import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../rental/models/rental.dart';
import '../../../core/constants/app_colors.dart';
import 'dart:math' as math;
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/responsive_wrapper.dart';

class HealthMonitorScreen extends ConsumerWidget {
  final Rental rental;

  const HealthMonitorScreen({super.key, required this.rental});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final battery = rental.battery;
    
    // Determine status colors based on backend logic (simulated here for display)
    final bool isTempCritical = battery.currentTemp > 50;
    final bool isTempWarning = battery.currentTemp > 40;
    final Color tempColor = isTempCritical ? Colors.red : (isTempWarning ? Colors.orange : Colors.green);
    
    final bool isHealthLow = battery.healthPercentage < 80;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Health Monitor"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Trigger refresh logic
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(battery.modelNumber),
              const SizedBox(height: 24),
              _buildHealthHero(battery.healthPercentage, isHealthLow),
              const SizedBox(height: 24),
              _buildMetricGrid(battery, tempColor, isTempCritical),
              const SizedBox(height: 24),
              if (isHealthLow) _buildHealthAlert(),
              const SizedBox(height: 24),
              _buildHistoricalGraphPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String modelName) {
    return Column(
      children: [
        Text(
          modelName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.circle, size: 8, color: Colors.green),
            const SizedBox(width: 6),
            Text(
              "Live Telemetry • Synced Just Now",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthHero(double health, bool isLow) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            width: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: health / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[100],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isLow ? Colors.orange : Colors.green,
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${health.toInt()}%",
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text("Health", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.trending_down, color: Colors.grey[600], size: 20),
              const SizedBox(width: 4),
              Text(
                "Degradation: -0.5% this week",
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMetricGrid(dynamic battery, Color tempColor, bool isCritical) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: "Charge",
            value: "${battery.currentCharge.toInt()}%",
            icon: Icons.battery_charging_full,
            color: Colors.blue,
            content: LinearProgressIndicator(
              value: battery.currentCharge / 100,
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            title: "Temp",
            value: "${battery.currentTemp}°C",
            icon: Icons.thermostat,
            color: tempColor,
            content: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: tempColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isCritical ? "CRITICAL" : (battery.currentTemp > 40 ? "WARNING" : "NORMAL"),
                style: TextStyle(
                  color: tempColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey[400]),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget _buildHealthAlert() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Health below 80%. Consider swapping soon.",
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("SWAP"),
          )
        ],
      ),
    );
  }

  Widget _buildHistoricalGraphPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("7-Day Health Trend", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final height = 40 + (math.Random().nextInt(50).toDouble());
                return Container(
                  width: 20,
                  height: height,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}