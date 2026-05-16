import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../maps/models/station.dart';
import '../models/battery.dart';
import '../providers/rental_providers.dart';
import 'battery_detail_screen.dart';
import '../../../core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/responsive_wrapper.dart';

enum BatterySort { price, capacity, health }

class BatterySelectionScreen extends ConsumerStatefulWidget {
  final Station station;

  const BatterySelectionScreen({super.key, required this.station});

  @override
  ConsumerState<BatterySelectionScreen> createState() =>
      _BatterySelectionScreenState();
}

class _BatterySelectionScreenState
    extends ConsumerState<BatterySelectionScreen> {
  BatterySort _currentSort = BatterySort.price;

  Widget _buildTypeTabs(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _buildTypeTab("All", true, isDark),
          const SizedBox(width: 8),
          _buildTypeTab("Standard", false, isDark),
          const SizedBox(width: 8),
          _buildTypeTab("Pro", false, isDark),
          const SizedBox(width: 8),
          _buildTypeTab("High Capacity", false, isDark),
        ],
      ),
    );
  }

  Widget _buildTypeTab(String label, bool isSelected, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryBlue : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100]),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue
                : (isDark ? Colors.white10 : Colors.transparent)),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.white70 : Colors.black87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final batteriesAsync =
        ref.watch(batteriesAtStationProvider(widget.station.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Battery',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStationHeader(isDark),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Choose Battery Type",
              style:
                  GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          _buildTypeTabs(isDark),
          _buildSortSection(isDark),
          Expanded(
            child: batteriesAsync.when(
              data: (batteries) {
                if (batteries.isEmpty) return _buildEmptyState(isDark);

                var sortedBatteries = List<Battery>.from(batteries);
                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: sortedBatteries.length,
                  itemBuilder: (context, index) =>
                      _buildBatteryCard(sortedBatteries[index], isDark),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.mapPin, color: AppTheme.primaryBlue, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.station.name,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortSection(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          Text('Sort: ',
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
          const SizedBox(width: 8),
          _buildSortChip(BatterySort.price, 'Price', isDark),
          const SizedBox(width: 8),
          _buildSortChip(BatterySort.capacity, 'Capacity', isDark),
          const SizedBox(width: 8),
          _buildSortChip(BatterySort.health, 'Health', isDark),
        ],
      ),
    );
  }

  Widget _buildSortChip(BatterySort sort, String label, bool isDark) {
    final isSelected = _currentSort == sort;
    return InkWell(
      onTap: () => setState(() => _currentSort = sort),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.primaryBlue : Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBatteryCard(Battery battery, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Part: Image and Quick Stats
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'battery-img-${battery.id}',
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://images.unsplash.com/photo-1617788138017-80ad40651399?auto=format&fit=crop&q=80&w=200'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Pro Lithium 200", // High-fidelity name
                            style: GoogleFonts.outfit(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "98%", // Battery Health
                              style: GoogleFonts.outfit(
                                  color: Colors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        battery.type, // e.g., Standard Li-ion
                        style:
                            GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _miniStat(LucideIcons.star, "4.9", Colors.amber),
                          const SizedBox(width: 12),
                          _miniStat(LucideIcons.shieldCheck, "1Y Warranty",
                              Colors.blue),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),

          // Bottom Part: Pricing and Action
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "₹99 - ₹149",
                      style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue),
                    ),
                    Text(
                      "per day",
                      style:
                          GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BatteryDetailScreen(
                          battery: battery,
                          stationId: widget.station.id,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    "View Specs →",
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.battery, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'No batteries available',
            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
