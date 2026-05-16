import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/reservation_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../services/navigation_service.dart';

class ActiveReservationCard extends ConsumerWidget {
  const ActiveReservationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reservationProvider);
    final reservation = state.activeReservation;

    if (reservation == null) return const SizedBox.shrink();

    final remaining = state.remainingTime;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    // Color based on urgency
    Color timerColor = Colors.green;
    if (minutes < 5) timerColor = Colors.orange;
    if (minutes < 2) timerColor = Colors.red;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.shadowMedium,
        border: Border.all(
          color: timerColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: timerColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.timer, color: timerColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Battery Reserved",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.primaryBlue,
                        ),
                      ),
                      Text(
                        reservation.stationName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: timerColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    timeStr,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          LinearProgressIndicator(
            value: remaining.inSeconds / (15 * 60),
            backgroundColor: timerColor.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(timerColor),
            minHeight: 4,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => ref
                        .read(reservationProvider.notifier)
                        .cancelReservation(),
                    icon:
                        const Icon(LucideIcons.x, size: 16, color: Colors.red),
                    label: const Text("Cancel",
                        style: TextStyle(color: Colors.red)),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      NavigationService.navigateTo(
                        reservation.latitude,
                        reservation.longitude,
                        label: reservation.stationName,
                      );
                    },
                    icon: const Icon(LucideIcons.navigation,
                        size: 16, color: AppTheme.primaryBlue),
                    label: const Text("Navigate",
                        style: TextStyle(color: AppTheme.primaryBlue)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
