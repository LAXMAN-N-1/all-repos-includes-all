import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/responsive_wrapper.dart';
import '../../auth/providers/auth_provider.dart';
import '../../maps/screens/station_locator_screen.dart';
import '../../purchase/screens/shop_home_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../rental/screens/active_rental_dashboard.dart';
import '../../rental/screens/my_rentals_screen.dart';
import '../../rental/screens/rent_battery_screen.dart';
import '../../rental/providers/rental_providers.dart';
import '../../rental/models/rental.dart';
import '../../maps/providers/map_providers.dart';
import '../../maps/widgets/active_reservation_card.dart';
import '../../maps/services/station_marker_helper.dart';
import '../../maps/models/station.dart';
import '../../maps/widgets/station_image.dart';
import '../../wallet/screens/wezu_pass_screen.dart';
import '../providers/dashboard_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _statsController = PageController(viewportFraction: 0.9);

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(authProvider);
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(activeRentalsProvider);
          ref.invalidate(nearbyStationsProvider);
          await Future.delayed(const Duration(milliseconds: 800));
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            _buildHeader(context, user, isDark),
            SliverToBoxAdapter(
              child: ResponsiveWrapper(
                maxWidth: Responsive.contentMaxWidth(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const ActiveReservationCard(),
                    const SizedBox(height: 8),
                    _buildQuickStats(context),
                    const SizedBox(height: 24),
                    _buildMainActions(context),
                    const SizedBox(height: 32),
                    _buildActiveRentalsSection(context, ref),
                    const SizedBox(height: 32),
                    _buildOffersCarousel(context),
                    const SizedBox(height: 32),
                    _buildNearbyStations(context),
                    const SizedBox(height: 32),
                    _buildShopByCategory(context),
                    const SizedBox(height: 32),
                    _buildYourActivity(context),
                    const SizedBox(height: 32),
                    _buildQuickActionsGrid(context),
                    SizedBox(height: Responsive.isMobile(context) ? 100 : 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, user, bool isDark) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 110,
      collapsedHeight: 70,
      backgroundColor: isDark ? AppTheme.backgroundDark : Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "WEZU",
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              _buildAppBarIcon(LucideIcons.bell, badgeCount: 2, onTap: () {}),
            ],
          ),
          const SizedBox(height: 4),
          ref.watch(userLocationStreamProvider).when(
                data: (pos) => Row(
                  children: [
                    const Icon(LucideIcons.mapPin,
                        size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "Lat: ${pos.latitude.toStringAsFixed(4)}, Lon: ${pos.longitude.toStringAsFixed(4)}",
                        style:
                            GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                loading: () => const Text("Detecting location...",
                    style: TextStyle(fontSize: 10, color: Colors.grey)),
                error: (_, __) => Row(
                  children: [
                    const Icon(LucideIcons.mapPin,
                        size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "Location Unavailable",
                      style:
                          GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
        ],
      ),
      actions: [
        _buildAppBarIcon(LucideIcons.shoppingCart, badgeCount: 3, onTap: () {}),
        const SizedBox(width: 12),
        // Assuming _buildUserAvatar is defined elsewhere or will be added
        // For now, using a placeholder if it's not defined
        // _buildUserAvatar(context, user),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
            child: Text(
              user?.email?.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(
                  color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildAppBarIcon(IconData icon,
      {int? badgeCount, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 24),
          if (badgeCount != null && badgeCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  badgeCount.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return statsAsync.when(
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => _buildStatsCards(context, null),
      data: (stats) => _buildStatsCards(context, stats),
    );
  }

  Widget _buildStatsCards(BuildContext context, DashboardStats? stats) {
    return SizedBox(
      height: 120,
      child: PageView(
        controller: _statsController,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildStatsCard(
            "Active Rentals",
            stats != null ? "${stats.activeRentals}" : "0",
            stats != null && stats.activeRentals > 0
                ? "View rentals"
                : "No active rentals",
            gradient: [const Color(0xFF2563EB), const Color(0xFF3B82F6)],
            icon: LucideIcons.batteryCharging,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyRentalsScreen()),
            ),
          ),
          _buildStatsCard(
            "Wallet Balance",
            stats != null ? "₹${stats.walletBalance.toStringAsFixed(0)}" : "₹0",
            "+ Add Money",
            gradient: [const Color(0xFF10B981), const Color(0xFF34D399)],
            icon: LucideIcons.wallet,
            onTap: () => Navigator.pushNamed(context, AppRoutes.payments),
          ),
          _buildStatsCard(
            "Reward Points",
            stats != null ? "${stats.rewardPoints} pts" : "0 pts",
            "Redeem",
            gradient: [const Color(0xFFF59E0B), const Color(0xFFFBBF24)],
            icon: LucideIcons.star,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(String label, String value, String actionText,
      {required List<Color> gradient,
      required IconData icon,
      VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: gradient[0].withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            Icon(icon, color: Colors.white.withValues(alpha: 0.3), size: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildMainActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  "Rent Battery",
                  "Starting ₹50/day",
                  [const Color(0xFF2563EB), const Color(0xFF0EA5E9)],
                  LucideIcons.battery,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RentBatteryScreen())),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  "Shop Batteries",
                  "50+ Products",
                  [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
                  LucideIcons.shoppingBag,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ShopHomeScreen())),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            "Wezu Pass",
            "Unlimited Swaps - ₹299/month",
            [const Color(0xFF8B5CF6), const Color(0xFFD946EF)],
            LucideIcons.crown,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const WezuPassScreen())),
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
      String title, String subtitle, List<Color> colors, IconData icon,
      {required VoidCallback onTap, bool fullWidth = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: fullWidth ? 100 : 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: colors[0].withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (fullWidth)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Text(subtitle,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  Icon(icon, color: Colors.white, size: 32),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 32),
                  const SizedBox(height: 12),
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  Text(subtitle,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveRentalsSection(BuildContext context, WidgetRef ref) {
    final activeRentalsAsync = ref.watch(activeRentalsProvider);

    return activeRentalsAsync.when(
      data: (rentals) {
        if (rentals.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Active Rentals", action: "View All >"),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: rentals.length,
                itemBuilder: (context, index) {
                  final rental = rentals[index];
                  final expiryDate =
                      rental.startTime.add(Duration(days: rental.durationDays));
                  final remaining = expiryDate.difference(DateTime.now());
                  String statusText;
                  if (remaining.isNegative) {
                    statusText = "Expired";
                  } else if (remaining.inDays > 0) {
                    statusText = "${remaining.inDays} days left";
                  } else {
                    statusText = "${remaining.inHours}h left";
                  }

                  final isCritical = remaining.inHours < 6;

                  return _buildRentalCard(
                    context,
                    rental.battery.type,
                    "Station ID: ${rental.pickupStationId}",
                    statusText,
                    rental,
                    isCritical: isCritical,
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: CircularProgressIndicator(),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildRentalCard(BuildContext context, String type, String station,
      String status, Rental rental,
      {bool isCritical = false}) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ActiveRentalDashboard(rental: rental)),
      ),
      child: Container(
        width: Responsive.horizontalCardWidth(context,
            mobileRatio: 0.75, maxWidth: 340),
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isCritical
                  ? Colors.red.withValues(alpha: 0.2)
                  : Colors.blue.withValues(alpha: 0.1)),
          boxShadow: AppTheme.shadowLight,
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(LucideIcons.battery, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(type,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis)),
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isCritical ? Colors.red : Colors.green)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                          color: isCritical ? Colors.red : Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(LucideIcons.mapPin, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(station,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ActiveRentalDashboard(rental: rental)),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child:
                        const Text("Monitor", style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ActiveRentalDashboard(rental: rental)),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Extend", style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersCarousel(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView(
            children: [
              _buildOfferBanner(
                  "50% OFF First Rental", "Claim Offer", Colors.indigo),
              _buildOfferBanner(
                  "Refer and Earn Rewards", "Invite Now", Colors.purple),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOfferBanner(String text, String cta, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage(
              "https://images.unsplash.com/photo-1593941707882-a5bba14938c7?q=80&w=2072&auto=format&fit=crop"),
          fit: BoxFit.cover,
          opacity: 0.4,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(text,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: color,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(cta),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyStations(BuildContext context) {
    final stationsAsync = ref.watch(nearbyStationsProvider);

    return Column(
      children: [
        _buildSectionHeader("Stations Near You", action: "View on Map >",
            onAction: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const StationLocatorScreen()));
        }),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: stationsAsync.when(
            data: (stations) {
              if (stations.isEmpty) {
                return Center(
                  child: Text("No stations found nearby",
                      style: GoogleFonts.outfit(color: Colors.grey)),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: stations.length,
                itemBuilder: (context, index) {
                  final station = stations[index];
                  // Calculate distance if needed, but for now using mock proximities or assuming API sorts
                  return _buildStationCard(station);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text("Error: $e")),
          ),
        ),
      ],
    );
  }

  Widget _buildStationCard(Station station) {
    final statusColor = StationMarkerHelper.getMarkerColor(station);
    final statusLabel = StationMarkerHelper.getStatusLabel(station);
    final distance = station.distance != null
        ? "${(station.distance! / 1000).toStringAsFixed(1)} km"
        : "Nearby";

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const StationLocatorScreen())), // Could pass initial station
      child: Container(
        width: Responsive.horizontalCardWidth(context,
            mobileRatio: 0.6, maxWidth: 280),
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.shadowLight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: StationImage(
                imageUrl: station.images.isNotEmpty ? station.images.first : "",
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(station.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(LucideIcons.star,
                          color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(station.rating.toString(),
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 8),
                      Text("($distance)",
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${station.availableBatteries} available • $statusLabel",
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
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

  Widget _buildShopByCategory(BuildContext context) {
    return Column(
      children: [
        _buildSectionHeader("Shop Batteries", action: "View All >"),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: Responsive.gridColumns(context),
          padding: EdgeInsets.all(Responsive.horizontalPadding(context)),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildCategoryTile(
                "Power Banks", LucideIcons.batteryCharging, Colors.blue),
            _buildCategoryTile(
                "Electric Vehicle", LucideIcons.car, Colors.green),
            _buildCategoryTile("Solar Storage", LucideIcons.sun, Colors.orange),
            _buildCategoryTile("Inverters", LucideIcons.zap, Colors.purple),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryTile(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          color.withValues(alpha: 0.1),
          color.withValues(alpha: 0.05)
        ]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildYourActivity(BuildContext context) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Column(
      children: [
        _buildSectionHeader("Your Activity"),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
            ),
            child: statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => _buildActivityContent(null),
              data: _buildActivityContent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityContent(DashboardStats? stats) {
    final totalRentals = stats?.totalRentals ?? 0;
    final carbonKg = stats?.carbonSavedKg ?? 0.0;
    return Column(
      children: [
        _buildActivityRow(
          LucideIcons.battery,
          "Total Rentals",
          "$totalRentals",
          totalRentals > 0 ? "Keep going!" : "Start your first rental",
        ),
        const Divider(height: 32),
        _buildActivityRow(
          LucideIcons.leaf,
          "Carbon Saved",
          "${carbonKg.toStringAsFixed(1)} kg CO₂",
          "Goal: 100 kg",
        ),
      ],
    );
  }

  Widget _buildActivityRow(
      IconData icon, String label, String value, String sub) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryBlue),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(sub,
            style: const TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: Responsive.quickActionColumns(context),
      padding: EdgeInsets.all(Responsive.horizontalPadding(context)),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildQuickAction(LucideIcons.box, "My Orders"),
        _buildQuickAction(LucideIcons.heart, "Favorites"),
        _buildQuickAction(LucideIcons.gift, "Offers"),
        _buildQuickAction(LucideIcons.helpCircle, "Support"),
        _buildQuickAction(LucideIcons.map, "History"),
        _buildQuickAction(LucideIcons.settings, "Settings"),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            shape: BoxShape.circle,
            boxShadow: AppTheme.shadowLight,
          ),
          child: Icon(icon, color: AppTheme.primaryBlue),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildSectionHeader(String title,
      {String? action, VoidCallback? onAction}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(title,
                  style: GoogleFonts.outfit(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis)),
          if (action != null)
            TextButton(
                onPressed: onAction ?? () {},
                child: Text(action,
                    style: const TextStyle(color: AppTheme.primaryBlue))),
        ],
      ),
    );
  }
}
