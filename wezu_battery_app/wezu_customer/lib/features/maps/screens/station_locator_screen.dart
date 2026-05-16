import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import '../../../core/theme/app_theme.dart';
import '../providers/map_providers.dart';
import '../providers/filter_providers.dart';
import '../providers/favorites_provider.dart';
import '../models/station.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart' as gmc;
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/filter_bottom_sheet.dart';
// import '../widgets/active_reservation_card.dart';
import '../services/navigation_service.dart';
import '../services/station_marker_helper.dart';
import 'station_detail_screen.dart';
import '../../rental/screens/battery_selection_screen.dart';
import '../widgets/station_image.dart';

// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

class StationLocatorScreen extends ConsumerStatefulWidget {
  const StationLocatorScreen({super.key});

  @override
  ConsumerState<StationLocatorScreen> createState() =>
      _StationLocatorScreenState();
}

class _StationLocatorScreenState extends ConsumerState<StationLocatorScreen> {
  gmaps.GoogleMapController? _mapController;
  late gmc.ClusterManager<Station> _clusterManager;
  Set<gmaps.Marker> _markers = {};
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _refreshTimer;
  Timer? _labelTimer;
  DateTime _lastUpdated = DateTime.now();
  String _lastUpdatedLabel = 'Updated just now';
  bool _showSearchThisArea = false;
  gmaps.LatLng? _lastSearchLocation;

  @override
  void initState() {
    super.initState();
    _clusterManager = _initClusterManager([]);
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      ref.invalidate(nearbyStationsProvider);
      setState(() {
        _lastUpdated = DateTime.now();
        _lastUpdatedLabel = 'Updated just now';
      });
    });
    // Update label every 10 seconds
    _labelTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      final diff = DateTime.now().difference(_lastUpdated).inSeconds;
      setState(() {
        if (diff < 10) {
          _lastUpdatedLabel = 'Updated just now';
        } else if (diff < 60) {
          _lastUpdatedLabel = 'Updated ${diff}s ago';
        } else {
          _lastUpdatedLabel = 'Updated ${(diff / 60).floor()}m ago';
        }
      });
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _labelTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stationsAsync = ref.watch(nearbyStationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchQuery = ref.watch(searchQueryProvider);

    ref.listen(nearbyStationsProvider, (previous, next) {
      next.whenData((stations) {
        _clusterManager.setItems(stations);
        _clusterManager.updateMap();
      });
    });

    // Auto-center map on user location when it first arrives
    ref.listen(userLocationProvider, (previous, next) {
      next.whenData((position) {
        if (_mapController != null) {
          _mapController?.animateCamera(
            gmaps.CameraUpdate.newLatLngZoom(
              gmaps.LatLng(position.latitude, position.longitude),
              14.0,
            ),
          );
        }
      });
    });

    // Auto-zoom to nearest station when filter results change
    ref.listen(nearbyStationsProvider, (previous, next) {
      next.whenData((stations) {
        if (stations.isNotEmpty) {
          // If we had a previous list and it changed (e.g. from filter),
          // or if it's the first time we got results
          final prevLength = previous?.value?.length ?? 0;
          if (stations.length != prevLength) {
            _zoomToNearestStation();
          }
        }
      });
    });

    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Map
          _buildMap(context, isDark),

          // 2. Search Bar / "Search this area" Bar
          _buildTopSearchBar(context, isDark),

          // 3. Active Reservation Overlay (Removed from here as requested)

          // 4. Status Overlay (Bottom)
          _buildBottomStatusOverlay(context, stationsAsync, isDark),

          // 5. Search This Area Button (Handled by Top Search Bar UI change)

          // 6. Vertical FAB group (Right side)
          _buildMyLocationButton(context, isDark),

          // 7. Bottom Sheet with Station List
          _buildDraggableSheet(context, stationsAsync, isDark, searchQuery),
        ],
      ),
    );
  }

  Widget _buildMap(BuildContext context, bool isDark) {
    final posAsync = ref.watch(userLocationProvider);

    // Use fallback location if GPS fails
    final position = posAsync.when(
      data: (pos) => pos,
      loading: () => defaultLocation, // Hyderabad fallback
      error: (_, __) => defaultLocation, // Hyderabad fallback
    );

    return gmaps.GoogleMap(
      onMapCreated: (controller) {
        try {
          _mapController = controller;
          _clusterManager.setMapId(controller.mapId);
          if (isDark) {
            try {
              // ignore: deprecated_member_use
              controller.setMapStyle(AppTheme.mapStyleDark);
            } catch (e) {
              debugPrint("Error applying map style: $e");
            }
          }

          // Initial marker load
          ref.read(nearbyStationsProvider).whenData((stations) {
            _clusterManager.setItems(stations);
            _clusterManager.updateMap();
          });
        } catch (e) {
          debugPrint("onMapCreated Error: $e");
        }
      },
      initialCameraPosition: gmaps.CameraPosition(
        target: gmaps.LatLng(position.latitude, position.longitude),
        zoom: 14.0,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      markers: _markers,
      onCameraMove: (position) {
        _clusterManager.onCameraMove(position);
        _handleCameraMove(position);
      },
      onCameraIdle: _clusterManager.updateMap,
      onTap: (_) => ref.read(selectedStationProvider.notifier).state = null,
    );
  }

  Widget _buildTopSearchBar(BuildContext context, bool isDark) {
    final filterCount =
        ref.watch(filterNotifierProvider.notifier).activeFilterCount;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: GestureDetector(
        onTap: () {
          if (_showSearchThisArea) {
            _performSearchThisArea();
          } else {
            // Focus search field or show filters
            _showFilterSheet(context);
          }
        },
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Icon(LucideIcons.search, color: Colors.grey, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _showSearchThisArea
                      ? "Search this area"
                      : "Search stations...",
                  style: GoogleFonts.outfit(
                    color: _showSearchThisArea
                        ? AppTheme.primaryBlue
                        : Colors.grey,
                    fontSize: 15,
                    fontWeight: _showSearchThisArea
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (filterCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    filterCount.toString(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              IconButton(
                icon: const Icon(LucideIcons.sliders,
                    color: AppTheme.primaryBlue, size: 20),
                onPressed: () => _showFilterSheet(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _performSearchThisArea() {
    setState(() {
      _showSearchThisArea = false;
      if (_mapController != null) {
        _mapController!.getVisibleRegion().then((bounds) {
          final center = gmaps.LatLng(
            (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
            (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
          );
          _lastSearchLocation = center;
          ref.invalidate(nearbyStationsProvider);
        });
      }
    });
  }

  Widget _buildBottomStatusOverlay(BuildContext context,
      AsyncValue<List<Station>> stationsAsync, bool isDark) {
    return Positioned(
      bottom: 250, // Above the draggable sheet handle
      left: 0,
      right: 0,
      child: Column(
        children: [
          // "Updated Xs ago" pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.shadowMedium,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.refreshCw,
                    size: 14, color: Colors.white70),
                const SizedBox(width: 8),
                Text(_lastUpdatedLabel,
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // "8 stations found" pill (centered and bold like screenshot)
          stationsAsync.when(
            data: (stations) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(30),
                boxShadow: AppTheme.shadowHeavy,
              ),
              child: Text(
                "${stations.length} stations found",
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildMyLocationButton(BuildContext context, bool isDark) {
    return Positioned(
      right: 16,
      bottom: 250,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search FAB
          FloatingActionButton.small(
            heroTag: "search_fab",
            onPressed: () {}, // Search logic
            backgroundColor: Colors.white,
            elevation: 2,
            child: const Icon(LucideIcons.search,
                color: AppTheme.primaryBlue, size: 18),
          ),
          const SizedBox(height: 12),
          // Location FAB
          FloatingActionButton.small(
            heroTag: "location_fab",
            onPressed: _goToCurrentLocation,
            backgroundColor: Colors.white,
            elevation: 2,
            child: const Icon(LucideIcons.navigation,
                color: AppTheme.primaryBlue, size: 18),
          ),
          const SizedBox(height: 12),
          // View Expand FAB (Fullscreen-like)
          FloatingActionButton.small(
            heroTag: "expand_fab",
            onPressed: () {}, // Expand logic
            backgroundColor: Colors.white,
            elevation: 2,
            child: const Icon(LucideIcons.maximize,
                color: AppTheme.primaryBlue, size: 18),
          ),
        ],
      ),
    );
  }

  // Removed _buildFindNearestButton as it's merged into the vertical group

  Widget _buildDraggableSheet(
      BuildContext context,
      AsyncValue<List<Station>> stationsAsync,
      bool isDark,
      String searchQuery) {
    final selectedStation = ref.watch(selectedStationProvider);

    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.45,
      minChildSize: 0.12,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.12, 0.45, 0.95],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: AppTheme.shadowHeavy,
          ),
          child: Column(
            children: [
              // Handlebar
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: selectedStation != null
                    ? _buildSelectedStationDetails(
                        context, selectedStation, isDark)
                    : stationsAsync.when(
                        data: (stations) {
                          // Apply search filter
                          final filtered = searchQuery.isEmpty
                              ? stations
                              : stations
                                  .where((s) =>
                                      s.name.toLowerCase().contains(
                                          searchQuery.toLowerCase()) ||
                                      s.address
                                          .toLowerCase()
                                          .contains(searchQuery.toLowerCase()))
                                  .toList();
                          return _buildStationList(
                              context, filtered, scrollController, isDark);
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, s) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.alertCircle,
                                    size: 40, color: Colors.orange),
                                const SizedBox(height: 16),
                                Text(
                                  "Using offline station data",
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "We're having trouble reaching the server, but you can still see stations on the map.",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                      color: Colors.grey, fontSize: 13),
                                ),
                                const SizedBox(height: 16),
                                // Instead of a center retry, we'll just provide a small retry button
                                TextButton.icon(
                                  onPressed: () =>
                                      ref.invalidate(nearbyStationsProvider),
                                  icon: const Icon(LucideIcons.refreshCw,
                                      size: 14),
                                  label: const Text("Retry Connection"),
                                  style: TextButton.styleFrom(
                                      foregroundColor: AppTheme.primaryBlue),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedStationDetails(
      BuildContext context, Station station, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(station.name,
                        style: GoogleFonts.outfit(
                            fontSize: 22, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(
                      station.status == 'active'
                          ? "Operational • ${station.is24x7 ? 'Open 24/7' : '${station.openingTime ?? '06:00'} – ${station.closingTime ?? '23:00'}'}"
                          : "Under Maintenance",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: station.status == 'active'
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.x, color: Colors.grey),
                onPressed: () =>
                    ref.read(selectedStationProvider.notifier).state = null,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Station Image
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.network(
              station.images.isNotEmpty
                  ? station.images.first
                  : "https://images.unsplash.com/photo-1593941707882-a5bba14938c7?w=600",
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                color: isDark ? const Color(0xFF1E293B) : Colors.grey[200],
                child: const Center(
                    child:
                        Icon(LucideIcons.image, size: 48, color: Colors.grey)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Real Data Info Tiles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _infoTile(LucideIcons.batteryCharging,
                  "${station.availableBatteries}", "Available"),
              _infoTile(LucideIcons.star, station.rating.toString(), "Rating"),
              _infoTile(
                  LucideIcons.mapPin,
                  station.distance != null
                      ? "${(station.distance! / 1000).toStringAsFixed(1)} km"
                      : "--",
                  "Distance"),
            ],
          ),
          const SizedBox(height: 20),
          // Address
          Row(
            children: [
              const Icon(LucideIcons.mapPin, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(station.address,
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(LucideIcons.indianRupee, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Text("₹${station.pricePerHour.toInt()}/hr",
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 32),
          // Action Buttons Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    NavigationService.navigateTo(
                        station.latitude, station.longitude,
                        label: station.name);
                  },
                  icon: const Icon(Icons.navigation, size: 18),
                  label: Text("Get Directions",
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                BatterySelectionScreen(station: station)));
                  },
                  icon: const Icon(LucideIcons.batteryCharging, size: 18),
                  label: Text("Pick Up",
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _navigateToStationDetail(context, station),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text("View Full Details",
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 24),
        const SizedBox(height: 8),
        Text(value,
            style:
                GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStationList(BuildContext context, List<Station> stations,
      ScrollController scrollController, bool isDark) {
    final currentSort = ref.watch(stationSortProvider);

    return Column(
      children: [
        // Active Reservation Card (Removed from here as requested)

        // Sort & Info Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${stations.length} station${stations.length != 1 ? 's' : ''} nearby",
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(_lastUpdatedLabel,
                      style:
                          GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
                ],
              ),
              TextButton.icon(
                onPressed: () => _showFilterSheet(context),
                icon: const Icon(LucideIcons.sliders, size: 14),
                label: const Text("Filter"),
                style:
                    TextButton.styleFrom(foregroundColor: AppTheme.primaryBlue),
              ),
            ],
          ),
        ),

        // Interactive Sort Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text("Sort: ",
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
              const SizedBox(width: 8),
              _buildSortChip(
                  "Nearest", StationSortFilter.distance, currentSort, isDark),
              const SizedBox(width: 8),
              _buildSortChip("Availability", StationSortFilter.availability,
                  currentSort, isDark),
              const SizedBox(width: 8),
              _buildSortChip(
                  "Rating", StationSortFilter.rating, currentSort, isDark),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Station List
        Expanded(
          child: stations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.searchX,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text("No stations found",
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text("Try adjusting your filters or search",
                          style: GoogleFonts.inter(
                              color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: stations.length,
                  itemBuilder: (context, index) =>
                      _buildStationCard(context, stations[index], isDark),
                ),
        ),
      ],
    );
  }

  Widget _buildSortChip(String label, StationSortFilter filter,
      StationSortFilter current, bool isDark) {
    final isSelected = filter == current;
    return GestureDetector(
      onTap: () => ref.read(stationSortProvider.notifier).state = filter,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey[200]),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildStationCard(BuildContext context, Station station, bool isDark) {
    // Format real distance
    String distanceText = '--';
    if (station.distance != null) {
      final km = station.distance! / 1000;
      distanceText = km < 1
          ? '${station.distance!.toInt()} m'
          : '${km.toStringAsFixed(1)} km';
    }

    // Availability color
    Color availColor = StationMarkerHelper.getMarkerColor(station);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4)),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToStationDetail(context, station),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Station Image
              Hero(
                tag: 'station_img_${station.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      StationImage(
                        imageUrl: station.images.isNotEmpty
                            ? station.images.first
                            : "",
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                      // Availability indicator dot
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: availColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                      if (station.isDealer)
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text("DEALER",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 7,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Station Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(station.name,
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                              overflow: TextOverflow.ellipsis),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: availColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${station.availableBatteries} left",
                            style: GoogleFonts.outfit(
                                color: availColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Distance + Rating row (REAL DATA)
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(distanceText,
                            style: GoogleFonts.outfit(
                                color: Colors.grey, fontSize: 12)),
                        const SizedBox(width: 12),
                        const Icon(LucideIcons.star,
                            size: 12, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(station.rating.toString(),
                            style: GoogleFonts.outfit(
                                color: Colors.grey, fontSize: 12)),
                        const SizedBox(width: 12),
                        Icon(LucideIcons.clock, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          station.is24x7
                              ? "24/7"
                              : (station.openingTime ?? "Day"),
                          style: GoogleFonts.outfit(
                              color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Price + Favorite + Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _statChip(
                            LucideIcons.indianRupee,
                            "₹${station.pricePerHour.toInt()}/hr",
                            Colors.orange),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Favorite heart
                            GestureDetector(
                              onTap: () => ref
                                  .read(favoritesProvider.notifier)
                                  .toggleFavorite(station.id),
                              child: Icon(
                                ref
                                        .watch(favoritesProvider)
                                        .contains(station.id)
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 18,
                                color: ref
                                        .watch(favoritesProvider)
                                        .contains(station.id)
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () =>
                                  _navigateToStationDetail(context, station),
                              child: Text(
                                "Details →",
                                style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToStationDetail(BuildContext context, Station station) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => StationDetailScreen(station: station)));
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.outfit(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  gmc.ClusterManager<Station> _initClusterManager(List<Station> stations) {
    return gmc.ClusterManager<Station>(stations, _updateMarkers,
        markerBuilder: _markerBuilder);
  }

  void _updateMarkers(Set<gmaps.Marker> markers) {
    setState(() => _markers = markers);
  }

  Future<gmaps.Marker> _markerBuilder(dynamic cluster) async {
    try {
      final station = cluster.items.first;

      gmaps.BitmapDescriptor icon;
      if (cluster.isMultiple) {
        icon = await _getClusterIcon(cluster.count);
      } else {
        icon = await _createCustomMarker(station);
      }

      return gmaps.Marker(
        markerId: gmaps.MarkerId(cluster.getId()),
        position: cluster.location,
        onTap: () {
          if (cluster.isMultiple) {
            _mapController?.animateCamera(
                gmaps.CameraUpdate.newLatLngZoom(cluster.location, 16.0));
          } else {
            ref.read(selectedStationProvider.notifier).state = station;
            _mapController?.animateCamera(
              gmaps.CameraUpdate.newLatLng(
                  gmaps.LatLng(station.latitude - 0.002, station.longitude)),
            );
          }
        },
        icon: icon,
      );
    } catch (e) {
      debugPrint("Marker builder error: $e");
      return gmaps.Marker(
        markerId: gmaps.MarkerId(cluster.getId()),
        position: cluster.location,
        icon: gmaps.BitmapDescriptor.defaultMarker,
      );
    }
  }

  Future<gmaps.BitmapDescriptor> _createCustomMarker(Station station) async {
    try {
      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final ui.Canvas canvas = ui.Canvas(pictureRecorder);
      const double size = 60.0; // Reduced to 60.0
      const double radius = size / 2.5;

      Color markerColor = StationMarkerHelper.getMarkerColor(station);

      // 1. Draw Pin Shadow
      final ui.Paint shadowPaint = ui.Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4);

      final Path pinPath = Path();
      pinPath.addArc(
          Rect.fromCircle(
              center: const Offset(size / 2, size / 2.5), radius: radius),
          0,
          2 * pi);
      // Draw the tail/point
      pinPath.moveTo(size / 2 - radius * 0.7, size / 2.5 + radius * 0.7);
      pinPath.lineTo(size / 2, size / 2.5 + radius * 1.5);
      pinPath.lineTo(size / 2 + radius * 0.7, size / 2.5 + radius * 0.7);

      canvas.drawPath(pinPath, shadowPaint);

      // 2. Draw Main Pin
      final ui.Paint paint = ui.Paint()..color = markerColor;
      canvas.drawPath(pinPath, paint);

      // 3. White Border
      final ui.Paint borderPaint = ui.Paint()
        ..color = Colors.white
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawPath(pinPath, borderPaint);

      // 4. Draw Battery Icon (White)
      final ui.Paint iconPaint = ui.Paint()
        ..color = Colors.white
        ..style = ui.PaintingStyle.fill;

      // Battery Body
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(size / 2, size / 2.5),
              width: radius * 0.8,
              height: radius * 1.2),
          const Radius.circular(4),
        ),
        ui.Paint()..color = Colors.white.withValues(alpha: 0.2),
      );

      // Draw "Swap" arrows icon (Simplified circular arrows)
      final Path swapPath = Path();
      // Arrow 1 (Top right arc)
      swapPath.addArc(
        Rect.fromCenter(
            center: Offset(size / 2, size / 2.5),
            width: radius * 0.8,
            height: radius * 0.8),
        -pi / 4,
        pi * 0.8,
      );
      // Arrow 2 (Bottom left arc)
      swapPath.addArc(
        Rect.fromCenter(
            center: Offset(size / 2, size / 2.5),
            width: radius * 0.8,
            height: radius * 0.8),
        3 * pi / 4,
        pi * 0.8,
      );

      // Draw little arrow heads
      final double headSize = 4.0;
      // head 1
      swapPath.moveTo(size / 2 + radius * 0.4, size / 2.5);
      swapPath.lineTo(
          size / 2 + radius * 0.4 - headSize, size / 2.5 - headSize);
      swapPath.moveTo(size / 2 + radius * 0.4, size / 2.5);
      swapPath.lineTo(
          size / 2 + radius * 0.4 + headSize, size / 2.5 - headSize);

      canvas.drawPath(
          swapPath,
          iconPaint
            ..style = ui.PaintingStyle.stroke
            ..strokeWidth = 2.5);

      final ui.Image image = await pictureRecorder
          .endRecording()
          .toImage(size.toInt(), size.toInt());
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        return gmaps.BitmapDescriptor.defaultMarker;
      }

      return gmaps.BitmapDescriptor.bytes(byteData.buffer.asUint8List());
    } catch (e) {
      debugPrint("Error creating custom marker: $e");
      return gmaps.BitmapDescriptor.defaultMarker;
    }
  }

  Future<gmaps.BitmapDescriptor> _getClusterIcon(int clusterSize) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(pictureRecorder);
    const double size = 60.0; // Reduced to 60.0
    const double radius = size / 3;

    // Redesign clusters to match the pin style but maybe with a different aesthetic
    final ui.Paint paint = ui.Paint()..color = AppTheme.primaryBlue;
    final ui.Paint shadowPaint = ui.Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4);

    canvas.drawCircle(const Offset(size / 2, size / 2), radius, shadowPaint);
    canvas.drawCircle(const Offset(size / 2, size / 2), radius, paint);

    // Outer white ring
    canvas.drawCircle(
        const Offset(size / 2, size / 2),
        radius,
        ui.Paint()
          ..color = Colors.white
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 3);

    final TextPainter textPainter =
        TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: clusterSize.toString(),
      style: const TextStyle(
          fontSize: size / 4.5,
          fontWeight: FontWeight.bold,
          color: Colors.white),
    );
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(size / 2 - textPainter.width / 2,
            size / 2 - textPainter.height / 2));

    final ui.Image image = await pictureRecorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    return gmaps.BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  Future<void> _goToCurrentLocation() async {
    final position = await ref.read(userLocationStreamProvider.future);
    _mapController?.animateCamera(
      gmaps.CameraUpdate.newCameraPosition(gmaps.CameraPosition(
          target: gmaps.LatLng(position.latitude, position.longitude),
          zoom: 14.0)),
    );
  }

  void _zoomToNearestStation() {
    ref.read(nearbyStationsProvider).whenData((stations) {
      if (stations.isEmpty) return;

      // Sort by distance (nearbyStationsProvider already does this, but we ensure it)
      final sorted = List<Station>.from(stations);
      sorted.sort((a, b) => (a.distance ?? double.infinity)
          .compareTo(b.distance ?? double.infinity));

      final nearest = sorted.first;

      // Update selected station to show details
      ref.read(selectedStationProvider.notifier).state = nearest;

      // Zoom to location
      _mapController?.animateCamera(
        gmaps.CameraUpdate.newLatLngZoom(
          gmaps.LatLng(nearest.latitude - 0.001, nearest.longitude),
          16.0,
        ),
      );
    });
  }

  void _handleCameraMove(gmaps.CameraPosition position) {
    if (_lastSearchLocation == null) {
      _lastSearchLocation = position.target;
      return;
    }

    final distance = Geolocator.distanceBetween(
      _lastSearchLocation!.latitude,
      _lastSearchLocation!.longitude,
      position.target.latitude,
      position.target.longitude,
    );

    // If moved more than 1km, show "Search this area"
    if (distance > 1000 && !_showSearchThisArea) {
      setState(() => _showSearchThisArea = true);
    }
  }
}
