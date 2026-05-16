import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../providers/stations_provider.dart';
import '../providers/station_detail_provider.dart';
import '../widgets/quick_stats_bar.dart';
import '../widgets/station_card.dart';
import '../widgets/add_station_drawer.dart';

class StationsScreen extends ConsumerStatefulWidget {
  const StationsScreen({super.key});
  @override
  ConsumerState<StationsScreen> createState() => _StationsScreenState();
}

class _StationsScreenState extends ConsumerState<StationsScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  bool _showAddDrawer = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  Widget _stagger(int i, {required Widget child}) {
    final begin = i * 0.12;
    final end = (begin + 0.35).clamp(0.0, 1.0);
    return AnimatedBuilder(animation: _anim, builder: (_, __) {
      final t = Curves.easeOut.transform(((_anim.value - begin) / (end - begin)).clamp(0.0, 1.0));
      return Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 18 * (1 - t)), child: child));
    });
  }

  @override
  Widget build(BuildContext context) {
    final stationsState = ref.watch(stationsProvider);
    final statsAsync = ref.watch(dealerQuickStatsProvider);
    final stations = stationsState.stations;

    return Stack(children: [
      SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ═══════════════════════════════════════════════
          // ZONE 1 — QUICK STATS BAR
          // ═══════════════════════════════════════════════
          _stagger(0, child: statsAsync.when(
            data: (stats) => QuickStatsBar(
              availableBatteries: stats.availableBatteries,
              ongoingRentals: stats.ongoingRentals,
              currentSwaps: stats.currentSwaps,
              avgRating: stats.avgRating,
              stationCount: stats.stationCount,
              onBatteriesTap: () => context.go('/stations/batteries'),
              onRentalsTap: () => context.go('/stations/rentals'),
              onSwapsTap: () => context.go('/stations/swaps'),
              onRatingsTap: () => context.go('/stations/ratings'),
              onRefresh: () {
                ref.invalidate(dealerQuickStatsProvider);
                ref.read(stationsProvider.notifier).refresh();
              },
            ),
            loading: () => _statsLoading(),
            error: (_, __) => QuickStatsBar(
              availableBatteries: stations.fold(0, (sum, s) => sum + s.maxCapacity),
              ongoingRentals: stations.fold(0, (sum, s) => sum + s.ongoingRentals),
              currentSwaps: stations.fold(0, (sum, s) => sum + s.activeSwaps),
              avgRating: stations.isEmpty ? 0 : stations.fold(0.0, (sum, s) => sum + s.rating) / stations.length,
              stationCount: stations.length,
              onBatteriesTap: () => context.go('/stations/batteries'),
              onRentalsTap: () => context.go('/stations/rentals'),
              onSwapsTap: () => context.go('/stations/swaps'),
              onRatingsTap: () => context.go('/stations/ratings'),
            ),
          )),

          const SizedBox(height: 28),

          // ═══════════════════════════════════════════════
          // ZONE 2 — STATION CARDS
          // ═══════════════════════════════════════════════
          _stagger(1, child: Row(children: [
            const Icon(LucideIcons.mapPin, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Your Stations (${stations.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const Spacer(),
            // Refresh
            TextButton.icon(
              icon: const Icon(LucideIcons.refreshCw, size: 13),
              label: const Text('Refresh', style: TextStyle(fontSize: 12)),
              onPressed: () => ref.read(stationsProvider.notifier).refresh(),
            ),
            const SizedBox(width: 8),
            // Add Station
            ElevatedButton.icon(
              icon: const Icon(LucideIcons.plus, size: 15),
              label: const Text('Add Station'),
              onPressed: () => setState(() => _showAddDrawer = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ])),

          const SizedBox(height: 16),

          // Station cards or loading/error
          if (stationsState.isLoading)
            _stagger(2, child: const Padding(
              padding: EdgeInsets.all(60),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ))
          else if (stationsState.error != null)
            _stagger(2, child: _errorCard(stationsState.error!))
          else if (stations.isEmpty)
            _stagger(2, child: _emptyState())
          else
            ...stations.asMap().entries.map((entry) {
              final i = entry.key;
              final s = entry.value;
              return _stagger(i + 2, child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: StationCard(
                  station: s,
                  isExpanded: stations.length == 1,
                  onTap: () => context.go('/stations/${s.id}'),
                  onViewBatteries: () => context.go('/stations/${s.id}/batteries'),
                ),
              ));
            }),
        ]),
      ),

      // ═══════════════════════════════════════════════
      // ADD STATION DRAWER OVERLAY
      // ═══════════════════════════════════════════════
      if (_showAddDrawer) ...[
        // Backdrop
        GestureDetector(
          onTap: () => setState(() => _showAddDrawer = false),
          child: Container(color: Colors.black.withValues(alpha: 0.4)),
        ),
        // Drawer
        Positioned(
          right: 0, top: 0, bottom: 0,
          child: AddStationDrawer(
            onClose: () => setState(() => _showAddDrawer = false),
            onSubmit: (data) {
              setState(() => _showAddDrawer = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Station submitted for approval!'),
                  backgroundColor: AppColors.primary,
                ),
              );
              ref.read(stationsProvider.notifier).refresh();
            },
          ),
        ),
      ],
    ]);
  }

  Widget _statsLoading() {
    return Row(children: List.generate(4, (i) => Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: i < 3 ? 12 : 0),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: const Center(child: SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          )),
        ),
      ),
    )));
  }

  Widget _errorCard(String error) => Container(
    padding: const EdgeInsets.all(40),
    decoration: BoxDecoration(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
    ),
    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(LucideIcons.alertTriangle, size: 32, color: AppColors.red),
      const SizedBox(height: 12),
      Text('Error loading stations', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      Text(error, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary), textAlign: TextAlign.center),
      const SizedBox(height: 16),
      ElevatedButton.icon(
        icon: const Icon(LucideIcons.refreshCw, size: 14),
        label: const Text('Retry'),
        onPressed: () => ref.read(stationsProvider.notifier).refresh(),
      ),
    ])),
  );

  Widget _emptyState() => Container(
    padding: const EdgeInsets.all(60),
    decoration: BoxDecoration(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(LucideIcons.mapPin, size: 28, color: AppColors.primary),
      ),
      const SizedBox(height: 16),
      const Text('No stations yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      const Text('Add your first station to start managing your battery swap business.', style: TextStyle(fontSize: 13, color: AppColors.textTertiary), textAlign: TextAlign.center),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        icon: const Icon(LucideIcons.plus, size: 15),
        label: const Text('Add Your First Station'),
        onPressed: () => setState(() => _showAddDrawer = true),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    ])),
  );
}
