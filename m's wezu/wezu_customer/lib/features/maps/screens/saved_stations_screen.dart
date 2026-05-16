import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/favorites_provider.dart';
import '../providers/map_providers.dart';
import '../models/station.dart';
import '../screens/station_detail_screen.dart';

class SavedStationsScreen extends ConsumerWidget {
  const SavedStationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favoriteIds = ref.watch(favoritesProvider);
    final stationsAsync = ref.watch(nearbyStationsProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.backgroundDark : Colors.white,
        elevation: 0,
        title: Text('Saved Stations',
            style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87)),
        centerTitle: false,
        actions: [
          if (favoriteIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${favoriteIds.length} saved',
                      style: GoogleFonts.outfit(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              ),
            ),
        ],
      ),
      body: favoriteIds.isEmpty
          ? _buildEmptyState(isDark)
          : stationsAsync.when(
              data: (allStations) {
                final savedStations = allStations
                    .where((s) => favoriteIds.contains(s.id))
                    .toList();
                if (savedStations.isEmpty) return _buildEmptyState(isDark);
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: savedStations.length,
                  itemBuilder: (context, index) => _buildStationCard(
                      context, ref, savedStations[index], isDark),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Error loading stations: $e')),
            ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.heart, size: 56, color: Colors.red),
            ),
            const SizedBox(height: 32),
            Text('No saved stations yet',
                style: GoogleFonts.outfit(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              'Tap the heart icon on any station to save it here for quick access.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 14, color: Colors.grey, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationCard(
      BuildContext context, WidgetRef ref, Station station, bool isDark) {
    // Availability color
    Color availColor = Colors.green;
    String availLabel = 'Available';
    if (station.availableBatteries == 0) {
      availColor = Colors.red;
      availLabel = 'Empty';
    } else if (station.availableBatteries < 5) {
      availColor = Colors.orange;
      availLabel = 'Low';
    }

    String distanceText = '--';
    if (station.distance != null) {
      final km = station.distance! / 1000;
      distanceText = km < 1
          ? '${station.distance!.toInt()} m'
          : '${km.toStringAsFixed(1)} km';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
        boxShadow: [
          if (!isDark)
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => StationDetailScreen(station: station))),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  station.images.isNotEmpty
                      ? station.images.first
                      : "https://images.unsplash.com/photo-1593941707882-a5bba14938c7?w=200",
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      width: 72,
                      height: 72,
                      color: Colors.grey[300],
                      child: const Icon(LucideIcons.image, color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(station.name,
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold, fontSize: 15),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(station.address,
                        style:
                            GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Availability badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: availColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                      color: availColor,
                                      shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              Text(availLabel,
                                  style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: availColor,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(LucideIcons.mapPin,
                            size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(distanceText,
                            style: GoogleFonts.inter(
                                fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              // Heart (unfavorite) button
              IconButton(
                onPressed: () => ref
                    .read(favoritesProvider.notifier)
                    .toggleFavorite(station.id),
                icon: const Icon(Icons.favorite_rounded,
                    color: Colors.red, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
