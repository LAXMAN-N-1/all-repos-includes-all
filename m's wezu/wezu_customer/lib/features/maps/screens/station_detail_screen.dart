import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../models/station.dart';
import '../providers/favorites_provider.dart';
import '../providers/review_providers.dart';
import '../widgets/review_widgets.dart';
import '../widgets/write_review_bottom_sheet.dart';
import '../widgets/map_app_selection_sheet.dart';
import '../widgets/reservation_confirmation_modal.dart';
import '../providers/reservation_providers.dart';
import '../screens/all_reviews_screen.dart';
import '../services/distance_service.dart';
import '../providers/map_providers.dart';
import '../../rental/screens/battery_selection_screen.dart';
import '../widgets/station_image.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/responsive_wrapper.dart';

class StationDetailScreen extends ConsumerStatefulWidget {
  final Station station;

  const StationDetailScreen({super.key, required this.station});

  @override
  ConsumerState<StationDetailScreen> createState() =>
      _StationDetailScreenState();
}

class _StationDetailScreenState extends ConsumerState<StationDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load reviews for this station
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reviewProvider.notifier).loadReviews(widget.station.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final station = widget.station;
    final isFavorite = ref.watch(favoritesProvider).contains(station.id);

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, isDark, isFavorite),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildStationHeader(isDark),
                      const SizedBox(height: 24),
                      _buildInfoRow(isDark),
                      const SizedBox(height: 32),
                      _buildDivider(isDark),
                      const SizedBox(height: 32),
                      _buildAboutSection(isDark),
                      const SizedBox(height: 32),
                      _buildLocationSection(isDark),
                      const SizedBox(height: 32),
                      _buildDivider(isDark),
                      const SizedBox(height: 32),
                      _buildAmenitiesSection(isDark),
                      const SizedBox(height: 32),
                      _buildDivider(isDark),
                      const SizedBox(height: 32),
                      _buildReviewsSection(isDark),
                      const SizedBox(height: 32),
                      _buildDivider(isDark),
                      const SizedBox(height: 32),
                      _buildBatteryTypesSection(isDark),
                      SizedBox(height: Responsive.isMobile(context) ? 120 : 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildStickyBottomButton(context, isDark),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(
      BuildContext context, bool isDark, bool isFavorite) {
    final station = widget.station;
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: isDark ? AppTheme.backgroundDark : Colors.white,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
              color: Colors.black26, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                color: Colors.black26, shape: BoxShape.circle),
            child:
                const Icon(LucideIcons.share2, color: Colors.white, size: 18),
          ),
          onPressed: () {},
        ),
        // Favorite heart icon with animated toggle
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                color: Colors.black26, shape: BoxShape.circle),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey(isFavorite),
                color: isFavorite ? Colors.red : Colors.white,
                size: 18,
              ),
            ),
          ),
          onPressed: () {
            ref.read(favoritesProvider.notifier).toggleFavorite(station.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isFavorite ? 'Removed from favorites' : 'Added to favorites!',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                ),
                duration: const Duration(seconds: 2),
                backgroundColor: isFavorite ? Colors.grey : Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'station_img_${station.id}',
              child: StationImage(
                imageUrl: station.images.isNotEmpty ? station.images.first : "",
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationHeader(bool isDark) {
    final station = widget.station;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(station.name,
            style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    color: station.status == 'active'
                        ? Colors.green
                        : Colors.orange,
                    shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(
              station.status == 'active'
                  ? "Operational • ${station.is24x7 ? 'Open 24/7' : '${station.openingTime ?? '06:00'} – ${station.closingTime ?? '23:00'}'}"
                  : "Under Maintenance",
              style: GoogleFonts.inter(
                  fontSize: 14,
                  color:
                      station.status == 'active' ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(bool isDark) {
    final station = widget.station;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          if (!isDark)
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
              child: _buildInfoItem(LucideIcons.batteryCharging,
                  "${station.availableBatteries}", "Available", isDark)),
          Expanded(
              child: _buildInfoItem(LucideIcons.star, station.rating.toString(),
                  "Rating", isDark)),
          Expanded(
              child: _buildInfoItem(LucideIcons.indianRupee,
                  "₹${station.pricePerHour.toInt()}", "Per Hour", isDark)),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      IconData icon, String value, String label, bool isDark) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 28),
        const SizedBox(height: 8),
        Text(value,
            style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87)),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12, color: isDark ? Colors.white38 : Colors.black38)),
      ],
    );
  }

  Widget _buildAboutSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.info, size: 20, color: AppTheme.primaryBlue),
            const SizedBox(width: 12),
            Text("About this station",
                style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87)),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          "Premium Wezu battery swapping station with high-speed chargers and climate-controlled storage for maximum battery life.",
          style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.6),
        ),
      ],
    );
  }

  Widget _buildLocationSection(bool isDark) {
    final station = widget.station;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.mapPin,
                    size: 20, color: Colors.redAccent),
                const SizedBox(width: 12),
                Text("Location",
                    style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87)),
              ],
            ),
            Consumer(
              builder: (context, ref, _) {
                final userPosAsync = ref.watch(userLocationProvider);
                return userPosAsync.when(
                  data: (pos) {
                    final meters = DistanceService.calculateDistance(
                      pos.latitude,
                      pos.longitude,
                      station.latitude,
                      station.longitude,
                    );
                    final distStr = DistanceService.formatDistance(meters);
                    final timeMin = DistanceService.estimateTravelTime(meters);
                    return TextButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (_) => MapAppSelectionSheet(
                              latitude: station.latitude,
                              longitude: station.longitude,
                              stationName: station.name),
                        );
                      },
                      icon: const Icon(Icons.navigation,
                          size: 16, color: AppTheme.primaryBlue),
                      label: Text(
                        "$distStr ($timeMin min) • Get Directions",
                        style: GoogleFonts.outfit(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    );
                  },
                  loading: () => const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => TextButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (_) => MapAppSelectionSheet(
                            latitude: station.latitude,
                            longitude: station.longitude,
                            stationName: station.name),
                      );
                    },
                    icon: const Icon(Icons.navigation,
                        size: 16, color: AppTheme.primaryBlue),
                    label: Text("Get Directions",
                        style: GoogleFonts.outfit(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(station.address,
            style: GoogleFonts.inter(
                fontSize: 14, color: isDark ? Colors.white70 : Colors.black54)),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(LucideIcons.clock, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
                "Operating Hours: ${station.is24x7 ? '24/7' : '${station.openingTime ?? '06:00'} – ${station.closingTime ?? '23:00'}'}",
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
            const Spacer(),
            const Icon(LucideIcons.phone, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(station.contactNumber,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection(bool isDark) {
    final station = widget.station;
    final amenityIcons = {
      '24/7 Access': LucideIcons.unlock,
      'Climate Control': LucideIcons.thermometer,
      'Fast Charging': LucideIcons.zap,
      'CCTV Security': LucideIcons.video,
      'Parking': LucideIcons.parkingSquare,
      'Customer Lounge': LucideIcons.coffee,
      'WiFi': LucideIcons.wifi,
      'Restroom': LucideIcons.doorOpen,
      'Security': LucideIcons.shield,
      'Coffee': LucideIcons.coffee,
      'Lounge': LucideIcons.sofa,
    };

    final displayAmenities = station.amenities.isNotEmpty
        ? station.amenities
            .map((a) => (a, amenityIcons[a] ?? LucideIcons.checkCircle2))
            .toList()
        : [
            ("24/7 Access", LucideIcons.unlock),
            ("Climate Control", LucideIcons.thermometer),
            ("Fast Charging", LucideIcons.zap),
            ("CCTV Security", LucideIcons.video),
            ("Parking", LucideIcons.parkingSquare),
            ("Customer Lounge", LucideIcons.coffee)
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("✨ Amenities",
            style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: displayAmenities
              .map((a) => _buildAmenityBadge(a.$1, a.$2, isDark))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAmenityBadge(String label, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.transparent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isDark ? Colors.white38 : Colors.black38),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(bool isDark) {
    final station = widget.station;
    final reviewState = ref.watch(reviewProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("⭐ Reviews & Ratings",
                style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87)),
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AllReviewsScreen(
                            stationId: station.id, stationName: station.name)));
              },
              child: Text("Show All",
                  style: GoogleFonts.outfit(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Rating summary
        RatingSummaryCard(
          averageRating: reviewState.reviews.isNotEmpty
              ? reviewState.averageRating
              : station.rating,
          totalReviews: reviewState.reviews.isNotEmpty
              ? reviewState.totalCount
              : station.totalReviews,
          isDark: isDark,
        ),
        const SizedBox(height: 20),

        // First 3 review cards
        if (reviewState.isLoading)
          const Center(
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator()))
        else if (reviewState.reviews.isEmpty)
          Center(
            child: Column(
              children: [
                const SizedBox(height: 12),
                const Icon(LucideIcons.messageSquare,
                    size: 32, color: Colors.grey),
                const SizedBox(height: 8),
                Text('No reviews yet',
                    style: GoogleFonts.inter(color: Colors.grey)),
              ],
            ),
          )
        else
          ...reviewState.reviews
              .take(3)
              .map((r) => ReviewCard(review: r, isDark: isDark)),

        const SizedBox(height: 16),

        // Write a review button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => WriteReviewBottomSheet(
                    stationId: station.id, stationName: station.name),
              );
            },
            icon: const Icon(LucideIcons.edit3, size: 18),
            label: Text('Write a Review',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppTheme.primaryBlue),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBatteryTypesSection(bool isDark) {
    final station = widget.station;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("🔋 Available Battery Types",
            style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 16),
        _buildTypeItem(station.batteryType,
            "${station.availableBatteries} available", isDark),
      ],
    );
  }

  Widget _buildTypeItem(String title, String count, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(LucideIcons.checkCircle2, size: 16, color: Colors.green),
          const SizedBox(width: 12),
          Text(title, style: GoogleFonts.inter(fontSize: 14)),
          const Spacer(),
          Text(count,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
        color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05));
  }

  Widget _buildStickyBottomButton(BuildContext context, bool isDark) {
    final station = widget.station;
    final reservationState = ref.watch(reservationProvider);
    final hasActiveReservation = reservationState.activeReservation != null;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.backgroundDark.withValues(alpha: 0.98)
              : Colors.white.withValues(alpha: 0.98),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          border: Border(
              top: BorderSide(color: isDark ? Colors.white12 : Colors.black12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (station.availableBatteries > 0) ...[
              ElevatedButton(
                onPressed: hasActiveReservation
                    ? null
                    : () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => ReservationConfirmationModal(
                            station: station,
                            onConfirm: () {
                              ref
                                  .read(reservationProvider.notifier)
                                  .reserveBattery(
                                      station.id, station.batteryType);
                            },
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  disabledBackgroundColor: Colors.grey.withValues(alpha: 0.2),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  hasActiveReservation
                      ? "Active Reservation Exists"
                      : "Reserve Battery (Free)",
                  style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: hasActiveReservation ? Colors.grey : Colors.white),
                ),
              ),
              const SizedBox(height: 12),
            ],
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            BatterySelectionScreen(station: station)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey[100],
                foregroundColor: isDark ? Colors.white : Colors.black87,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Browse Available Batteries",
                      style: GoogleFonts.outfit(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}