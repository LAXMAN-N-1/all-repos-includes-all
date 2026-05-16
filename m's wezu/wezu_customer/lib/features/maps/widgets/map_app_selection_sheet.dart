import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../models/nav_app.dart';
import '../providers/navigation_providers.dart';
import '../services/navigation_service.dart';

class MapAppSelectionSheet extends ConsumerWidget {
  final double latitude;
  final double longitude;
  final String? stationName;

  const MapAppSelectionSheet({
    super.key,
    required this.latitude,
    required this.longitude,
    this.stationName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final preferred = ref.watch(navigationPreferenceProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(
          24, 12, 24, 0), // Bottom padding handled by safe area or scroll
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('Open with...',
                style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 8),
            Text('Choose your preferred navigation app',
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),
            _buildAppOption(context, ref, NavAppType.googleMaps, 'Google Maps',
                Icons.map, Colors.green, preferred, isDark),
            const SizedBox(height: 12),
            _buildAppOption(context, ref, NavAppType.appleMaps, 'Apple Maps',
                Icons.explore, Colors.blue, preferred, isDark),
            const SizedBox(height: 12),
            _buildAppOption(context, ref, NavAppType.waze, 'Waze',
                LucideIcons.navigation, Colors.cyan, preferred, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildAppOption(
      BuildContext context,
      WidgetRef ref,
      NavAppType type,
      String name,
      IconData icon,
      Color color,
      NavAppType preferred,
      bool isDark) {
    final isPreferred = type == preferred;

    return InkWell(
      onTap: () {
        ref.read(navigationPreferenceProvider.notifier).setPreference(type);
        // Launch the app
        NavigationApp navApp;
        switch (type) {
          case NavAppType.googleMaps:
            navApp = NavigationApp.googleMaps;
            break;
          case NavAppType.appleMaps:
            navApp = NavigationApp.appleMaps;
            break;
          case NavAppType.waze:
            navApp = NavigationApp.waze;
            break;
        }
        NavigationService.navigateTo(latitude, longitude,
            label: stationName, preference: navApp);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPreferred
              ? color.withValues(alpha: 0.08)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.grey[50]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isPreferred
                  ? color.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87)),
                  if (isPreferred)
                    Text('Preferred',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(LucideIcons.externalLink, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
