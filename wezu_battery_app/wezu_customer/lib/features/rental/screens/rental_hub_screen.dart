import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/responsive_wrapper.dart';
import '../../maps/screens/station_locator_screen.dart';
import '../../maps/providers/map_providers.dart';
import '../../maps/models/station.dart';
import '../../maps/services/station_marker_helper.dart';
import '../../maps/widgets/station_image.dart';
import '../../rental/screens/battery_selection_screen.dart';
import '../providers/rental_providers.dart';
import 'active_rental_dashboard.dart';

class RentalHubScreen extends ConsumerWidget {
  const RentalHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? Colors.white : AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Rent a Battery",
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.bell,
                color: isDark ? Colors.white70 : AppColors.textPrimary, size: 22),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding:
            EdgeInsets.symmetric(horizontal: Responsive.horizontalPadding(context)),
        child: ResponsiveWrapper(
          maxWidth: Responsive.contentMaxWidth(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildHeroBanner(isDark),
              const SizedBox(height: 28),
              Text(
                "Choose Your Option",
                style: AppTheme.displaySmall(
                    color: isDark ? Colors.white : AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                context,
                icon: LucideIcons.mapPin,
                title: "Find Station Near You",
                subtitle: "50 stations within 10 km",
                isDark: isDark,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (context) => const StationLocatorScreen())),
                showMapPreview: true,
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                context,
                icon: LucideIcons.search,
                title: "I Know My Station",
                subtitle: "Search by station name or area",
                isDark: isDark,
                onTap: () {},
                showSearchBar: true,
              ),
              const SizedBox(height: 28),
              _buildActiveRentalsCard(isDark, ref),
              const SizedBox(height: 28),
              _buildRentalAlerts(isDark, ref),
              const SizedBox(height: 28),
              _buildNearbyStations(context, isDark, ref),
              const SizedBox(height: 28),
              _buildQuickStats(isDark),
              SizedBox(height: Responsive.isMobile(context) ? 100 : 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.batteryCharging, color: Colors.white, size: 32),
          const SizedBox(height: 16),
          Text(
            "Find Your Perfect Battery",
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Choose from 50+ stations near you\nBatteries starting from ₹99/day",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
    bool showMapPreview = false,
    bool showSearchBar = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusXL),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.glassDecoration(isDark),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.textPrimary)),
                      Text(subtitle,
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isDark ? Colors.white54 : AppColors.textTertiary)),
                    ],
                  ),
                ),
                Icon(LucideIcons.chevronRight,
                    color: isDark ? Colors.white24 : AppColors.textHint, size: 20),
              ],
            ),
            if (showMapPreview) ...[
              const SizedBox(height: 16),
              Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  image: const DecorationImage(
                    image: NetworkImage(
                        'https://images.unsplash.com/photo-1517520287167-4bda64282f5b?auto=format&fit=crop&q=80&w=800'),
                    fit: BoxFit.cover,
                    opacity: 0.6,
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: AppTheme.shadowMedium,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.map, color: AppColors.primary, size: 16),
                        const SizedBox(width: 8),
                        Text("View All Stations →",
                            style: GoogleFonts.outfit(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            if (showSearchBar) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 48,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.search,
                        size: 18,
                        color: isDark ? Colors.white38 : AppColors.textHint),
                    const SizedBox(width: 12),
                    Text("Search stations...",
                        style: GoogleFonts.inter(
                            color: isDark ? Colors.white38 : AppColors.textHint,
                            fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _buildRecentChip("Madhapur", isDark),
                  _buildRecentChip("Jubilee Hills", isDark),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentChip(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.history,
              size: 12, color: isDark ? Colors.white38 : AppColors.textHint),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : AppColors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildActiveRentalsCard(bool isDark, WidgetRef ref) {
    final activeRentalsAsync = ref.watch(activeRentalsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Active Rentals",
            style: AppTheme.displaySmall(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.glassDecoration(isDark),
          child: activeRentalsAsync.when(
            data: (rentals) {
              if (rentals.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Icon(LucideIcons.battery, size: 32,
                            color: isDark ? Colors.white24 : AppColors.textHint),
                        const SizedBox(height: 8),
                        Text("No active rentals",
                            style: GoogleFonts.inter(
                                color: isDark ? Colors.white38 : AppColors.textTertiary)),
                      ],
                    ),
                  ),
                );
              }
              final rental = rentals.first;
              return InkWell(
                onTap: () => Navigator.push(
                    ref.context,
                    MaterialPageRoute(
                        builder: (_) => ActiveRentalDashboard(rental: rental))),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: AppColors.heroGradient,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                        ),
                        child: const Icon(LucideIcons.batteryCharging,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rental.battery.modelNumber,
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w700, fontSize: 15)),
                            Text("SN: ${rental.battery.serialNumber}",
                                style: GoogleFonts.inter(
                                    color: isDark ? Colors.white38 : AppColors.textTertiary,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(LucideIcons.chevronRight,
                          color: AppColors.primary, size: 20),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))),
            error: (err, stack) => Center(child: Text("Error: $err")),
          ),
        ),
      ],
    );
  }

  Widget _buildRentalAlerts(bool isDark, WidgetRef ref) {
    final activeRentalsAsync = ref.watch(activeRentalsProvider);

    return activeRentalsAsync.when(
      data: (rentals) {
        if (rentals.isEmpty) return const SizedBox.shrink();

        final alerts = <Map<String, dynamic>>[];

        for (final rental in rentals) {
          if (rental.endTime == null) continue;
          final now = DateTime.now();
          final returnDeadline = rental.endTime!;
          final hoursLeft = returnDeadline.difference(now).inHours;

          if (hoursLeft <= 2 && hoursLeft >= 0) {
            alerts.add({
              'icon': LucideIcons.alertTriangle,
              'color': Colors.orange,
              'title': 'Return Soon',
              'body':
                  '${rental.battery.modelNumber} due in ${hoursLeft}h',
            });
          } else if (hoursLeft < 0) {
            alerts.add({
              'icon': LucideIcons.alertCircle,
              'color': Colors.red,
              'title': 'Overdue Return',
              'body': '${rental.battery.modelNumber} is past due — late fee applies',
            });
          }
        }

        if (alerts.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Rental Alerts",
              style: AppTheme.displaySmall(
                  color: isDark ? Colors.white : AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            ...alerts.map((alert) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (alert['color'] as Color).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    border: Border.all(
                        color:
                            (alert['color'] as Color).withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      Icon(alert['icon'] as IconData,
                          color: alert['color'] as Color, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(alert['title'] as String,
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: alert['color'] as Color)),
                            Text(alert['body'] as String,
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white70
                                        : AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildNearbyStations(
      BuildContext context, bool isDark, WidgetRef ref) {
    final stationsAsync = ref.watch(nearbyStationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Stations Near You",
              style: AppTheme.displaySmall(
                  color: isDark ? Colors.white : AppColors.textPrimary),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const StationLocatorScreen())),
              child: Text(
                "View All →",
                style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 200,
          child: stationsAsync.when(
            data: (stations) {
              if (stations.isEmpty) {
                return Center(
                  child: Text("No stations found nearby",
                      style: GoogleFonts.outfit(
                          color: isDark ? Colors.white38 : Colors.grey)),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                itemCount: stations.length > 5 ? 5 : stations.length,
                itemBuilder: (context, index) =>
                    _buildStationCard(context, stations[index], isDark),
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (_, __) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.wifiOff,
                      color: isDark ? Colors.white24 : Colors.grey, size: 28),
                  const SizedBox(height: 8),
                  Text("Can't load stations",
                      style: GoogleFonts.inter(
                          color: isDark ? Colors.white38 : Colors.grey,
                          fontSize: 13)),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => ref.invalidate(nearbyStationsProvider),
                    icon: const Icon(LucideIcons.refreshCw, size: 13),
                    label: const Text("Retry"),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        textStyle: GoogleFonts.outfit(fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStationCard(
      BuildContext context, Station station, bool isDark) {
    final statusColor = StationMarkerHelper.getMarkerColor(station);
    final distance = station.distance != null
        ? "${(station.distance! / 1000).toStringAsFixed(1)} km"
        : "Nearby";

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => BatterySelectionScreen(station: station))),
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.grey.withValues(alpha: 0.1)),
          boxShadow: isDark ? [] : AppTheme.shadowLight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusLG)),
              child: Stack(
                children: [
                  StationImage(
                    imageUrl:
                        station.images.isNotEmpty ? station.images.first : "",
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(station.name,
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isDark ? Colors.white : AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(LucideIcons.mapPin, size: 11, color: Colors.grey),
                      const SizedBox(width: 3),
                      Text(distance,
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.grey)),
                      const Spacer(),
                      Text(
                        "${station.availableBatteries} left",
                        style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Quick Stats",
            style: AppTheme.displaySmall(
                color: isDark ? Colors.white : AppColors.textPrimary)),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatItem("Total Rent", "15", "completed", isDark),
            const SizedBox(width: 12),
            _buildStatItem("Batteries", "200+", "available", isDark),
            const SizedBox(width: 12),
            _buildStatItem("Stations", "50+", "near you", isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(
      String label, String value, String subLabel, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.glassDecoration(isDark, radius: AppTheme.radiusMD),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary)),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : AppColors.textPrimary),
                textAlign: TextAlign.center),
            Text(subLabel,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    color: isDark ? Colors.white38 : AppColors.textTertiary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
