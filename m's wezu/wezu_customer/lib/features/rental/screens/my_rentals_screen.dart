import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/rental_providers.dart';
import '../models/rental.dart';
import '../../../core/utils/time_utils.dart';
import 'active_rental_dashboard.dart';
import 'rental_return_screen.dart';

class MyRentalsScreen extends ConsumerStatefulWidget {
  const MyRentalsScreen({super.key});

  @override
  ConsumerState<MyRentalsScreen> createState() => _MyRentalsScreenState();
}

class _MyRentalsScreenState extends ConsumerState<MyRentalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final activeRentals = ref.watch(activeRentalsProvider);
    final historyRentals = ref.watch(rentalHistoryProvider);
    final activeCount = activeRentals.asData?.value.length ?? 0;
    final historyCount = historyRentals.asData?.value.length ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("Rentals",
            style:
                GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(LucideIcons.history), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(context, isDark, activeCount, historyCount),
          const SizedBox(height: 16),
          _buildTabBar(isDark),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActiveTab(context, activeRentals, isDark),
                _buildHistoryTab(context, historyRentals, isDark),
                _buildCancelledTab(context, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    bool isDark,
    int activeCount,
    int historyCount,
  ) {
    final totalCount = activeCount + historyCount;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.shadowMedium,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _buildSummaryItem(
              "Total Rentals",
              '$totalCount',
              LucideIcons.battery,
            ),
          ),
          Expanded(
              child: _buildSummaryItem("Eco Saving", "12kg", LucideIcons.leaf)),
          Expanded(
            child: _buildSummaryItem(
              "Active",
              '$activeCount',
              LucideIcons.zap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 10)),
      ],
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowLight,
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primaryBlue,
          borderRadius: BorderRadius.circular(14),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: "Active"),
          Tab(text: "History"),
          Tab(text: "Closed"),
        ],
      ),
    );
  }

  Widget _buildActiveTab(BuildContext context,
      AsyncValue<List<Rental>> activeRentals, bool isDark) {
    return activeRentals.when(
      data: (rentals) => rentals.isEmpty
          ? _buildEmptyState("No active subscriptions", LucideIcons.battery)
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: rentals.length,
              itemBuilder: (context, index) => _buildRentalCard(
                  context, rentals[index], isDark,
                  isActive: true),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Error: $e")),
    );
  }

  Widget _buildHistoryTab(BuildContext context,
      AsyncValue<List<Rental>> historyRentals, bool isDark) {
    return historyRentals.when(
      data: (rentals) => rentals.isEmpty
          ? _buildEmptyState("No rental history yet", LucideIcons.history)
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: rentals.length,
              itemBuilder: (context, index) => _buildRentalCard(
                  context, rentals[index], isDark,
                  isActive: false),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Error: $e")),
    );
  }

  Widget _buildCancelledTab(BuildContext context, bool isDark) {
    return _buildEmptyState("No cancelled items", LucideIcons.xCircle);
  }

  Widget _buildRentalCard(BuildContext context, Rental rental, bool isDark,
      {required bool isActive}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.shadowLight,
        border: Border.all(
            color: isActive
                ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                : Colors.transparent),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(LucideIcons.batteryCharging,
                    color: AppTheme.primaryBlue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rental.battery.modelName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isActive
                          ? "Expires: ${TimeUtils.shortDateFromDt(rental.startTime.add(Duration(days: rental.durationDays)))}"
                          : "Completed: ${TimeUtils.dateOnlyFromDt(rental.endTime ?? rental.startTime)}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("ID: #${rental.id}",
                      style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  const SizedBox(height: 4),
                  _buildStatusTag(rental.status, isActive),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: _buildMetric(LucideIcons.zap,
                      "${rental.battery.capacityAh}Ah", "Capacity")),
              Expanded(
                  child:
                      _buildMetric(LucideIcons.trendingUp, "72V", "Voltage")),
              Expanded(
                  child: _buildMetric(LucideIcons.clock,
                      "${rental.durationDays} Days", "Duration")),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RentalReturnScreen(rental: rental),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Plan Return"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ActiveRentalDashboard(rental: rental),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Open"),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.download, size: 16),
                label: const Text("Invoice", style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusTag(String status, bool isActive) {
    final color = isActive ? Colors.green : Colors.blueGrey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMetric(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
