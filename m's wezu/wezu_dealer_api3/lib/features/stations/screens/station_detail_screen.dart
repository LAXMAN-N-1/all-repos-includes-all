import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/colors.dart';
import '../providers/stations_provider.dart';
import '../providers/station_detail_provider.dart';
import '../models/station_state.dart';
import '../widgets/swap_port_grid.dart';
import '../widgets/swap_statistics.dart';

import '../widgets/rating_review_card.dart';
import '../tabs/station_overview_tab.dart';
import '../tabs/station_batteries_tab.dart';
import '../tabs/station_settings_tab.dart';

class StationDetailScreen extends ConsumerStatefulWidget {
  final String stationId;
  const StationDetailScreen({super.key, required this.stationId});
  @override
  ConsumerState<StationDetailScreen> createState() =>
      _StationDetailScreenState();
}

class _StationDetailScreenState extends ConsumerState<StationDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  int _tab = 0;
  final _tabs = [
    'Overview',
    'Batteries',
    'Swaps',
    'Ratings',
    'Analytics',
    'Settings'
  ];

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Widget _stagger(int i, {required Widget child}) {
    final begin = i * 0.12;
    final end = (begin + 0.35).clamp(0.0, 1.0);
    return AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final t = Curves.easeOut.transform(
              ((_anim.value - begin) / (end - begin)).clamp(0.0, 1.0));
          return Opacity(
              opacity: t,
              child: Transform.translate(
                  offset: Offset(0, 14 * (1 - t)), child: child));
        });
  }

  StationDto? get _station {
    final stations = ref.watch(stationsProvider).stations;
    final sid = int.tryParse(widget.stationId);
    if (sid == null) return null;
    return stations.where((s) => s.id == sid).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final s = _station;
    if (s == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    final statusColor = _statusColor(s.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Back button ──
        _stagger(0,
            child: GestureDetector(
              onTap: () => context.go('/stations'),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(LucideIcons.arrowLeft, size: 16, color: AppColors.primary),
                SizedBox(width: 6),
                Text('Back to Stations',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500)),
              ]),
            )),
        const SizedBox(height: 18),

        // ── Station Header Card ──
        _stagger(1,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statusColor.withValues(alpha: 0.08),
                    AppColors.cardBg
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withValues(alpha: 0.2)),
              ),
              child: Row(children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(LucideIcons.radio, size: 24, color: statusColor),
                ),
                const SizedBox(width: 18),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(s.name,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(LucideIcons.mapPin,
                            size: 12, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                            s.city.isNotEmpty
                                ? '${s.address}, ${s.city}'
                                : s.address,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(width: 12),
                        if (s.is24x7) _pill('24/7', AppColors.primary),
                        const SizedBox(width: 4),
                        _pill(s.stationType, AppColors.textTertiary),
                      ]),
                    ])),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(s.status.toUpperCase(),
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.5)),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(LucideIcons.settings,
                      size: 18, color: AppColors.textTertiary),
                  onPressed: () => setState(() => _tab = 5),
                  tooltip: 'Settings',
                ),
              ]),
            )),
        const SizedBox(height: 18),

        // ── 5 KPI Cards ──
        _stagger(2,
            child: Row(children: [
              _kpiCard(
                  'Available Batteries',
                  '${s.availableBatteries}',
                  LucideIcons.batteryFull,
                  AppColors.primary,
                  () => context.go('/stations/${s.id}/batteries')),
              const SizedBox(width: 10),
              _kpiCard(
                  'Ongoing Rentals',
                  '${s.ongoingRentals}',
                  LucideIcons.userCheck,
                  AppColors.cyan,
                  () => context.go('/stations/rentals')),
              const SizedBox(width: 10),
              _kpiCard(
                  'Current Swaps',
                  '${s.activeSwaps}',
                  LucideIcons.refreshCw,
                  AppColors.amber,
                  () => setState(() => _tab = 2)),
              const SizedBox(width: 10),
              _kpiCard(
                  'Station Rating',
                  s.rating.toStringAsFixed(1),
                  LucideIcons.star,
                  AppColors.purple,
                  () => setState(() => _tab = 3)),
              const SizedBox(width: 10),
              _kpiCard(
                  "Today's Revenue",
                  '₹${s.todayRevenue.toStringAsFixed(0)}',
                  LucideIcons.indianRupee,
                  AppColors.amber,
                  () {}),
            ])),
        const SizedBox(height: 22),

        // ── Tab Navigation ──
        _stagger(3,
            child: Container(
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border))),
              child: Row(
                  children: _tabs.asMap().entries.map((e) {
                final sel = _tab == e.key;
                return GestureDetector(
                  onTap: () => setState(() => _tab = e.key),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                          color: sel ? AppColors.primary : Colors.transparent,
                          width: 2,
                        )),
                      ),
                      child: Text(e.value,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                            color: sel
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          )),
                    ),
                  ),
                );
              }).toList()),
            )),
        const SizedBox(height: 20),

        // ── Tab Content ──
        _stagger(4, child: _buildTabContent(s)),
      ]),
    );
  }

  Widget _buildTabContent(StationDto s) {
    switch (_tab) {
      case 0:
        return _overviewTab(s);
      case 1:
        return _batteriesTab(s);
      case 2:
        return _swapsTab(s);
      case 3:
        return _ratingsTab(s);
      case 4:
        return _analyticsTab(s);
      case 5:
        return _settingsTab(s);
      default:
        return const SizedBox.shrink();
    }
  }

  // ══════════════════════════════════════════════════════════
  // OVERVIEW TAB (extracted to StationOverviewTab)
  // ══════════════════════════════════════════════════════════
  Widget _overviewTab(StationDto s) => StationOverviewTab(
        station: s,
        onTabChange: (tab) => setState(() => _tab = tab),
      );

  // ══════════════════════════════════════════════════════════
  // BATTERIES TAB (extracted to StationBatteriesTab)
  // ══════════════════════════════════════════════════════════
  Widget _batteriesTab(StationDto s) => StationBatteriesTab(station: s);

  // ══════════════════════════════════════════════════════════
  // SWAPS TAB — live, auto-refreshing
  // ══════════════════════════════════════════════════════════
  Widget _swapsTab(StationDto s) {
    final swapState = ref.watch(swapStateProvider(s.id));
    final notifier = ref.read(swapStateProvider(s.id).notifier);
    final swapsAsync = ref.watch(dealerSwapsListProvider(s.id));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header with live badge + refresh
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: swapState.isLive ? AppColors.primary : AppColors.textMuted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            swapState.isLive ? 'Live · Connected' : 'Offline',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: swapState.isLive ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        ]),
        TextButton.icon(
          icon: const Icon(LucideIcons.refreshCw, size: 13),
          label: const Text('Refresh', style: TextStyle(fontSize: 12)),
          onPressed: () {
            notifier.refresh();
            ref.invalidate(dealerSwapsListProvider(s.id));
          },
        ),
      ]),
      const SizedBox(height: 12),

      // Port grid or empty state
      if (swapState.stationData.isEmpty)
        _card(null,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(children: [
                Icon(LucideIcons.refreshCw,
                    size: 32, color: AppColors.textMuted.withValues(alpha: 0.5)),
                const SizedBox(height: 12),
                const Text('No active swap data',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                const Text(
                  'Swap port data will appear here when customers swap batteries at this station.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(LucideIcons.refreshCw, size: 14),
                  label: const Text('Refresh Now'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  onPressed: () {
                    notifier.refresh();
                    ref.invalidate(dealerSwapsListProvider(s.id));
                  },
                ),
              ]),
            ))
      else
        ...swapState.stationData.map((sd) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _card(null,
                  child: SwapPortGrid(
                    data: sd,
                    stationId: sd.stationId,
                    isCompact: false,
                    onMarkFixed: (sid, pn) => notifier.markPortFixed(sid, pn),
                    onMarkOffline: (sid, pn) =>
                        notifier.markPortOffline(sid, pn),
                    onReserve: (sid, pn, m) => notifier.reservePort(sid, pn, m),
                  )),
            )),

      const SizedBox(height: 8),

      // Swap activity table
      _card('Recent Swaps',
          child: swapsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Failed to load swaps: $e',
                  style: const TextStyle(color: AppColors.red, fontSize: 12)),
            ),
            data: (swaps) => swaps.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('No swap activity recorded yet',
                          style: TextStyle(
                              color: AppColors.textTertiary, fontSize: 12)),
                    ))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                          AppColors.pageBg.withValues(alpha: 0.5)),
                      columns: const [
                        DataColumn(label: Text('DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('CUSTOMER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('RETURNED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('RECEIVED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                      ],
                      rows: swaps.take(20).map((sw) {
                        Color statusColor;
                        final st = sw.status.toLowerCase();
                        if (st.contains('completed') || st.contains('success')) {
                          statusColor = AppColors.primary;
                        } else if (st.contains('pending') || st.contains('progress')) {
                          statusColor = AppColors.amber;
                        } else if (st.contains('fail') || st.contains('error')) {
                          statusColor = AppColors.red;
                        } else {
                          statusColor = AppColors.cyan;
                        }
                        String fmtDate(String iso) {
                          try {
                            final d = DateTime.parse(iso).toLocal();
                            return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')} ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
                          } catch (_) { return iso; }
                        }
                        return DataRow(cells: [
                          DataCell(Text(fmtDate(sw.createdAt), style: const TextStyle(fontSize: 12))),
                          DataCell(Text(sw.customerName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                          DataCell(Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sw.oldBatteryCode, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.cyan)),
                              Text('${sw.oldBatterySoc.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                            ],
                          )),
                          DataCell(Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sw.newBatteryCode, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.primary)),
                              Text('${sw.newBatterySoc.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                            ],
                          )),
                          DataCell(Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                            ),
                            child: Text(sw.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
          )),

      const SizedBox(height: 8),

      // Live events feed (station-filtered)
      if (swapState.events.isNotEmpty)
        _card('Live Events',
            child: LiveSwapEventsFeed(
              events: swapState.events
                  .where((e) =>
                      e.stationName.isEmpty || e.stationName == s.name)
                  .toList(),
              maxItems: 15,
            )),
    ]);
  }

  // ══════════════════════════════════════════════════════════
  // RATINGS TAB
  // ══════════════════════════════════════════════════════════
  Widget _ratingsTab(StationDto s) {
    final reviewsAsync = ref.watch(stationReviewsProvider(s.id));
    return reviewsAsync.when(
      data: (reviews) =>
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Rating summary
        _card(null,
            child: Row(children: [
              Column(children: [
                Text(s.rating.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                Row(
                    children: List.generate(
                        5,
                        (i) => Icon(
                              LucideIcons.star,
                              size: 16,
                              color: i < s.rating.round()
                                  ? AppColors.amber
                                  : AppColors.textMuted,
                            ))),
                const SizedBox(height: 4),
                Text('${reviews.length} reviews',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textTertiary)),
              ]),
              const SizedBox(width: 30),
              Expanded(
                  child: Column(children: [
                _ratingBar(5, reviews),
                _ratingBar(4, reviews),
                _ratingBar(3, reviews),
                _ratingBar(2, reviews),
                _ratingBar(1, reviews),
              ])),
            ])),
        const SizedBox(height: 16),

        // Reviews list
        ...reviews.map((r) => RatingReviewCard(
              review: r,
              onReply: (id, text) async {
                try {
                  await ref.read(stationReviewActionsProvider).replyToReview(
                        reviewId: id,
                        replyText: text,
                        stationId: s.id,
                      );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Reply saved!'),
                        backgroundColor: AppColors.primary),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Failed to save reply: $e'),
                        backgroundColor: AppColors.red),
                  );
                }
              },
            )),
      ]),
      loading: () => const Center(
          child: Padding(
              padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
      error: (e, _) => Center(
          child:
              Text('Error: $e', style: const TextStyle(color: AppColors.red))),
    );
  }

  // ══════════════════════════════════════════════════════════
  // ANALYTICS TAB (real data via fl_chart)
  // ══════════════════════════════════════════════════════════
  Widget _analyticsTab(StationDto s) {
    final swapsAsync = ref.watch(dealerSwapsListProvider(s.id));
    final batteriesAsync = ref.watch(dealerBatteriesProvider(s.id));
    final reviewsAsync = ref.watch(stationReviewsProvider(s.id));

    return swapsAsync.when(
      loading: () => const Center(
          child: Padding(
              padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
      error: (e, _) => Center(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Error: $e',
                  style: const TextStyle(color: AppColors.red)))),
      data: (swaps) {
        // Aggregate last 30 days by day
        final now = DateTime.now();
        final cutoff = now.subtract(const Duration(days: 30));
        final recent = swaps.where((sw) {
          final d = DateTime.tryParse(sw.createdAt)?.toLocal();
          return d != null && d.isAfter(cutoff);
        }).toList();

        // Build day → count + revenue maps (last 14 days for readability)
        final Map<int, int> dailyCounts = {};
        final Map<int, double> dailyRevenue = {};
        for (final sw in recent) {
          final parsed = DateTime.tryParse(sw.createdAt);
          if (parsed == null) continue;
          final d = parsed.toLocal();
          final dayKey = now.difference(d).inDays;
          if (dayKey < 14) {
            dailyCounts[dayKey] = (dailyCounts[dayKey] ?? 0) + 1;
            dailyRevenue[dayKey] =
                (dailyRevenue[dayKey] ?? 0.0) + sw.swapAmount;
          }
        }

        // Build heatmap: dayOfWeek (0=Mon) × hour
        final heatmap = List.generate(7, (_) => List.filled(24, 0));
        for (final sw in recent) {
          final d = DateTime.tryParse(sw.createdAt)?.toLocal();
          if (d == null) continue;
          final dow = (d.weekday - 1).clamp(0, 6); // Monday=0
          final h = d.hour;
          heatmap[dow][h]++;
        }
        final maxCell =
            heatmap.expand((r) => r).fold(0, (a, b) => a > b ? a : b);

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 8),
          // Swap Count + Revenue row
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: _card('Daily Swap Count',
                    child: _barChart(
                      dailyCounts,
                      AppColors.primary,
                      'swaps',
                      14,
                    ))),
            const SizedBox(width: 14),
            Expanded(
                child: _card('Daily Revenue (₹)',
                    child: _barChart(
                      dailyRevenue.map((k, v) => MapEntry(k, v.round())),
                      AppColors.cyan,
                      '₹',
                      14,
                    ))),
          ]),
          const SizedBox(height: 14),

          // Heatmap
          _card('Hourly Activity Heatmap',
              child: _buildHeatmap(heatmap, maxCell)),
          const SizedBox(height: 14),

          // Health + Satisfaction row
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: batteriesAsync.when(
              data: (batteries) => _card('Battery Health Distribution',
                  child: _healthChart(batteries)),
              loading: () => _card('Battery Health Distribution',
                  child: const SizedBox(
                      height: 160,
                      child: Center(child: CircularProgressIndicator()))),
              error: (_, __) => _card('Battery Health Distribution',
                  child: _emptyChart('No health data')),
            )),
            const SizedBox(width: 14),
            Expanded(
                child: reviewsAsync.when(
              data: (reviews) => _card('Customer Satisfaction',
                  child: _satisfactionChart(reviews)),
              loading: () => _card('Customer Satisfaction',
                  child: const SizedBox(
                      height: 160,
                      child: Center(child: CircularProgressIndicator()))),
              error: (_, __) => _card('Customer Satisfaction',
                  child: _emptyChart('No review data')),
            )),
          ]),
        ]);
      },
    );
  }

  Widget _barChart(Map<int, int> dayData, Color color, String unit, int days) {
    if (dayData.isEmpty) return _emptyChart('No data for last $days days');
    final maxVal = dayData.values.fold(0, (a, b) => a > b ? a : b).toDouble();
    return SizedBox(
      height: 160,
      child: BarChart(BarChartData(
        maxY: maxVal > 0 ? maxVal * 1.2 : 10,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppColors.border, strokeWidth: 0.5),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (val, _) {
              final daysAgo = val.toInt();
              if (daysAgo % 3 != 0) return const SizedBox.shrink();
              final date = DateTime.now().subtract(Duration(days: daysAgo));
              return Text('${date.month}/${date.day}',
                  style:
                      const TextStyle(fontSize: 8, color: AppColors.textMuted));
            },
            reservedSize: 18,
          )),
        ),
        barGroups: List.generate(days, (i) {
          final count = (dayData[i] ?? 0).toDouble();
          return BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: count,
              color: color,
              width: 8,
              borderRadius: BorderRadius.circular(3),
            ),
          ]);
        }),
      )),
    );
  }

  Widget _healthChart(List<BatteryDto> batteries) {
    if (batteries.isEmpty) return _emptyChart('No batteries assigned');
    final buckets = [0, 0, 0, 0]; // <50, 50-70, 70-90, 90-100
    for (final b in batteries) {
      final h = b.healthPercentage;
      if (h < 50)
        buckets[0]++;
      else if (h < 70)
        buckets[1]++;
      else if (h < 90)
        buckets[2]++;
      else
        buckets[3]++;
    }
    final labels = ['<50%', '50-70%', '70-90%', '90%+'];
    final colors = [
      AppColors.red,
      AppColors.amber,
      AppColors.primary,
      AppColors.cyan
    ];
    final maxY = buckets.fold(0, (a, b) => a > b ? a : b).toDouble();
    return SizedBox(
      height: 160,
      child: BarChart(BarChartData(
        maxY: maxY > 0 ? maxY * 1.2 : 5,
        gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: AppColors.border, strokeWidth: 0.5)),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (val, _) => Text(labels[val.toInt().clamp(0, 3)],
                style:
                    const TextStyle(fontSize: 9, color: AppColors.textMuted)),
            reservedSize: 18,
          )),
        ),
        barGroups: List.generate(
            4,
            (i) => BarChartGroupData(x: i, barRods: [
                  BarChartRodData(
                      toY: buckets[i].toDouble(),
                      color: colors[i],
                      width: 20,
                      borderRadius: BorderRadius.circular(3)),
                ])),
      )),
    );
  }

  Widget _satisfactionChart(List<ReviewDto> reviews) {
    if (reviews.isEmpty) return _emptyChart('No reviews yet');
    // Show last 20 reviews as a line chart ordered by date
    final sorted = [...reviews]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final recent =
        sorted.length > 20 ? sorted.sublist(sorted.length - 20) : sorted;
    return SizedBox(
      height: 160,
      child: LineChart(LineChartData(
        minY: 0,
        maxY: 5.5,
        gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: AppColors.border, strokeWidth: 0.5)),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (v, _) => v == v.roundToDouble()
                      ? Text(v.toInt().toString(),
                          style: const TextStyle(
                              fontSize: 9, color: AppColors.textMuted))
                      : const SizedBox.shrink(),
                  reservedSize: 18)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(recent.length,
                (i) => FlSpot(i.toDouble(), recent[i].rating.toDouble())),
            isCurved: true,
            color: AppColors.amber,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
                show: true, color: AppColors.amber.withValues(alpha: 0.08)),
          ),
        ],
      )),
    );
  }

  Widget _buildHeatmap(List<List<int>> heatmap, int maxCell) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Column(children: [
      Row(children: [
        const SizedBox(width: 30),
        ...List.generate(
            24,
            (h) => Expanded(
                  child: Center(
                      child: Text(h % 4 == 0 ? '$h' : '',
                          style: const TextStyle(
                              fontSize: 8, color: AppColors.textMuted))),
                )),
      ]),
      ...List.generate(
          7,
          (dow) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(children: [
                  SizedBox(
                      width: 30,
                      child: Text(days[dow],
                          style: const TextStyle(
                              fontSize: 9, color: AppColors.textTertiary))),
                  ...List.generate(24, (h) {
                    final count = heatmap[dow][h];
                    final intensity = maxCell > 0 ? count / maxCell : 0.0;
                    return Expanded(
                        child: Container(
                      height: 16,
                      margin: const EdgeInsets.all(0.5),
                      decoration: BoxDecoration(
                        color: AppColors.primary
                            .withValues(alpha: intensity * 0.7 + 0.05),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ));
                  }),
                ]),
              )),
    ]);
  }

  Widget _emptyChart(String label) => Container(
        height: 160,
        decoration: BoxDecoration(
            color: AppColors.pageBg.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8)),
        child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(LucideIcons.barChart3,
              size: 28, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ])),
      );

  // ══════════════════════════════════════════════════════════
  // SETTINGS TAB (extracted to StationSettingsTab)
  // ══════════════════════════════════════════════════════════
  Widget _settingsTab(StationDto s) => StationSettingsTab(station: s);

  // ══════════════════════════════════════════════════════════
  // HELPERS (used by ratings, analytics & swaps tabs)
  // ══════════════════════════════════════════════════════════

  Widget _pill(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4)),
        child: Text(text,
            style: TextStyle(
                fontSize: 9, color: color, fontWeight: FontWeight.w600)),
      );

  Widget _kpiCard(String label, String value, IconData icon, Color color,
      VoidCallback onTap) {
    return Expanded(
        child: GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                height: 2,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(1))),
            const SizedBox(height: 12),
            Row(children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500))),
            ]),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
          ]),
        ),
      ),
    ));
  }

  Widget _card(String? title, {required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (title != null) ...[
            Text(title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 14),
          ],
          child,
        ]),
      );

  Widget _ratingBar(int stars, List<ReviewDto> reviews) {
    final count = reviews.where((r) => r.rating == stars).length;
    final fraction = reviews.isEmpty ? 0.0 : count / reviews.length;
    final color = stars >= 4
        ? AppColors.primary
        : stars == 3
            ? AppColors.amber
            : AppColors.red;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        SizedBox(
            width: 20,
            child: Text('$stars',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textTertiary))),
        const Icon(LucideIcons.star, size: 10, color: AppColors.amber),
        const SizedBox(width: 8),
        Expanded(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  height: 6,
                  child: LinearProgressIndicator(
                      value: fraction,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(color)),
                ))),
        const SizedBox(width: 8),
        SizedBox(
            width: 30,
            child: Text('$count',
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textTertiary),
                textAlign: TextAlign.right)),
      ]),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPERATIONAL':
        return AppColors.primary;
      case 'OFFLINE':
        return AppColors.red;
      case 'MAINTENANCE':
        return AppColors.amber;
      default:
        return AppColors.textMuted;
    }
  }
}
