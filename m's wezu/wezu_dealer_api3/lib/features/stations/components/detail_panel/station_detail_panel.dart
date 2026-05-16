import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../core/theme/colors.dart';
import '../../models/station_state.dart';

import 'tabs/overview_tab.dart';
import 'tabs/batteries_tab.dart';
import 'tabs/maintenance_tab.dart';
// import 'tabs/analytics_tab.dart';
// import 'tabs/settings_tab.dart';

class StationDetailPanel extends StatefulWidget {
  final StationDto station;
  final VoidCallback onClose;
  final Function(String, dynamic)? onUpdateStation;

  const StationDetailPanel({
    super.key,
    required this.station,
    required this.onClose,
    this.onUpdateStation,
  });

  @override
  State<StationDetailPanel> createState() => _StationDetailPanelState();
}

class _StationDetailPanelState extends State<StationDetailPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(-5, 0))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Area
          Container(
            padding: const EdgeInsets.only(left: 24, right: 16, top: 20, bottom: 16),
            decoration: const BoxDecoration(
              color: AppColors.pageBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(LucideIcons.mapPin, size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                
                // Name & Location
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.station.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.station.address.isNotEmpty ? widget.station.address : 'No address provided',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                
                // View Full Details button
                Tooltip(
                  message: 'Open full detail view',
                  child: InkWell(
                    onTap: () => context.go('/stations/${widget.station.id}'),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.externalLink, size: 14, color: AppColors.primary),
                          SizedBox(width: 6),
                          Text('View Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Close button
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textSecondary),
                  onPressed: widget.onClose,
                  tooltip: 'Close Panel',
                  splashRadius: 20,
                ),
              ],
            ),
          ),
          
          // Tab Bar
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textTertiary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Batteries'),
                Tab(text: 'Maintenance'),
                Tab(text: 'Analytics'),
                Tab(text: 'Settings'),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                OverviewTab(station: widget.station, onUpdate: widget.onUpdateStation),
                const BatteriesTab(batteries: []),
                MaintenanceTab(history: const [], lastMaintenance: widget.station.lastMaintenanceDate),
                _linkTab(
                  text: 'Open station analytics in the full detail view.',
                  icon: LucideIcons.barChart2,
                ),
                _linkTab(
                  text: 'Open station settings in the full detail view.',
                  icon: LucideIcons.settings,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _linkTab({required String text, required IconData icon}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.textTertiary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textTertiary, fontSize: 13)),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => context.go('/stations/${widget.station.id}'),
            icon: const Icon(LucideIcons.externalLink, size: 14),
            label: const Text('Open Full Station View'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
