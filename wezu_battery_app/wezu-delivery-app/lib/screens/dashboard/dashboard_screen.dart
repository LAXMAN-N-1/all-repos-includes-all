import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dashboard_view_model.dart';
import '../../models/order_model.dart';
import '../../widgets/dashboard/station_card.dart';
import '../../widgets/dashboard/activity_tile.dart';
import '../../utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // No Scaffold or AppBar here - handled by MainScreen
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. SUMMARY SECTION (Single Row)
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      'Swaps',
                      '${viewModel.todaysSwaps}',
                      Icons.swap_horiz,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryItem(
                      'Wallet',
                      '₹${viewModel.walletBalance.toStringAsFixed(0)}',
                      Icons.account_balance_wallet,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryItem(
                      'Active',
                      '${viewModel.activeSwapCount}',
                      Icons.electric_bolt,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryItem(
                      'Done',
                      '${viewModel.completedDeliveries}',
                      Icons.check_circle,
                      Colors.purple,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 2. NEARBY STATIONS SECTION
              const Text(
                'Nearby Stations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF233D4C),
                ),
              ),
              const SizedBox(height: 12),
              // Vertical list
              if (viewModel.nearbyStations.isEmpty)
                const Text('No stations nearby.')
              else
                ...viewModel.nearbyStations.map((station) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: StationCard(
                      name: station['name'] as String? ?? 'Station',
                      distance: station['distance'] as String? ?? '0 km',
                      batteriesAvailable: station['batteries'] as int? ?? 0,
                      onNavigate: () =>
                          _launchMap('EV station ${station['name'] ?? ''}'),
                    ),
                  );
                }),

              const SizedBox(height: 12),

              // 3. RECENT ACTIVITY SECTION
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF233D4C),
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: viewModel.recentActivity.length,
                itemBuilder: (context, index) {
                  final activity = viewModel.recentActivity[index];
                  return ActivityTile(
                    id: activity.id,
                    date: activity.timestamp,
                    amount: activity.amount,
                    status: _getActivityStatus(activity.status),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF233D4C),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getActivityStatus(OrderStatus? status) {
    if (status == null) return 'Unknown';
    switch (status) {
      case OrderStatus.delivered:
        return 'Completed';
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.pickingUp:
        return 'Picking Up';
      case OrderStatus.delivering:
        return 'Delivering';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Future<void> _launchMap(String query) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
