import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/export_helper.dart';
import '../../../core/utils/time_utils.dart';
import '../providers/station_detail_provider.dart';
import '../providers/stations_provider.dart';
import '../models/station_state.dart';
import '../widgets/swap_port_grid.dart';
import '../widgets/swap_statistics.dart';

// ══════════════════════════════════════════════════════════
// LIVE SWAP OPERATIONS DASHBOARD
// ══════════════════════════════════════════════════════════

class SwapVisualizationScreen extends ConsumerStatefulWidget {
  final String? stationId;
  const SwapVisualizationScreen({super.key, this.stationId});
  @override
  ConsumerState<SwapVisualizationScreen> createState() =>
      _SwapVisualizationScreenState();
}

class _SwapVisualizationScreenState
    extends ConsumerState<SwapVisualizationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _liveIndicatorCtrl;
  int? _selectedStationFilter;
  int? _prevActive;
  int? _prevReady;
  int? _prevCharging;
  int? _prevFault;
  bool _activeFlash = false;
  bool _readyFlash = false;
  bool _chargingFlash = false;
  bool _faultFlash = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _liveIndicatorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    if (widget.stationId != null) {
      _selectedStationFilter = int.tryParse(widget.stationId!);
    }
    // Auto-refresh every 30 seconds for real-time swap updates
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        final sid = _selectedStationFilter;
        ref.read(swapStateProvider(sid).notifier).refresh();
        ref.invalidate(dealerSwapsListProvider(sid));
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _liveIndicatorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sid = _selectedStationFilter;
    final swapState = ref.watch(swapStateProvider(sid));
    final notifier = ref.read(swapStateProvider(sid).notifier);
    final stations = ref.watch(stationsProvider).stations;

    // Detect value changes for flash animations
    _checkFlash(swapState);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Back Button ──
        GestureDetector(
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
        ),
        const SizedBox(height: 18),

        // ═════════════════════════════════════════════════
        // HEADER ROW
        // ═════════════════════════════════════════════════
        Row(children: [
          // Title + breadcrumb
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Live Swap Operations',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    )),
                const SizedBox(height: 2),
                Row(children: [
                  Text('Stations',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textTertiary)),
                  const Icon(LucideIcons.chevronRight,
                      size: 12, color: AppColors.textMuted),
                  const Text('Live Swaps',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500)),
                ]),
              ])),

          // Live indicator
          AnimatedBuilder(
            animation: _liveIndicatorCtrl,
            builder: (_, __) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(
                        alpha: 0.4 + _liveIndicatorCtrl.value * 0.6),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary
                            .withValues(alpha: 0.3 * _liveIndicatorCtrl.value),
                        blurRadius: 6,
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Text('Live · Connected',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    )),
              ]),
            ),
          ),
          const SizedBox(width: 12),

          // Station filter dropdown
          Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
              value: _selectedStationFilter,
              icon: const Icon(LucideIcons.chevronDown,
                  size: 14, color: AppColors.textMuted),
              dropdownColor: AppColors.cardBg,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textPrimary),
              items: [
                const DropdownMenuItem(
                    value: null, child: Text('All Stations')),
                ...stations.map(
                    (s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
              ],
              onChanged: (val) => setState(() => _selectedStationFilter = val),
            )),
          ),
        ]),
        const SizedBox(height: 22),

        // ═════════════════════════════════════════════════
        // REAL-TIME SUMMARY STRIP
        // ═════════════════════════════════════════════════
        Row(children: [
          _animatedMetricTile(
            'Active Swaps',
            '${swapState.activeSwaps}',
            LucideIcons.refreshCw,
            AppColors.amber,
            _activeFlash,
          ),
          const SizedBox(width: 10),
          _animatedMetricTile(
            'Available Ports',
            '${swapState.readyPorts}',
            LucideIcons.checkCircle,
            AppColors.primary,
            _readyFlash,
          ),
          const SizedBox(width: 10),
          _animatedMetricTile(
            'Charging Ports',
            '${swapState.chargingPorts}',
            LucideIcons.batteryCharging,
            AppColors.cyan,
            _chargingFlash,
          ),
          const SizedBox(width: 10),
          _animatedMetricTile(
            'Fault Ports',
            '${swapState.faultPorts}',
            LucideIcons.alertTriangle,
            AppColors.red,
            _faultFlash,
          ),
        ]),
        const SizedBox(height: 24),

        // ═════════════════════════════════════════════════
        // STATION PORT DIAGRAMS
        // ═════════════════════════════════════════════════
        if (swapState.stationData.isEmpty)
          _emptyState()
        else
          ...swapState.stationData.map((sd) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: SwapPortGrid(
                    data: sd,
                    stationId: sd.stationId,
                    isCompact: swapState.stationData.length > 1,
                    onMarkFixed: (sid, pn) => notifier.markPortFixed(sid, pn),
                    onMarkOffline: (sid, pn) =>
                        notifier.markPortOffline(sid, pn),
                    onReserve: (sid, pn, m) => notifier.reservePort(sid, pn, m),
                  ),
                ),
              )),

        const SizedBox(height: 24),

        // ═════════════════════════════════════════════════
        // STATISTICS SECTION — 3 columns
        // ═════════════════════════════════════════════════
        _buildStatisticsSection(swapState, notifier),
        const SizedBox(height: 24),

        // ═════════════════════════════════════════════════
        // SWAP ACTIVITY TABLE
        // ═════════════════════════════════════════════════
        _buildSwapActivityTable(ref.watch(dealerSwapsListProvider(sid)), sid),
      ]),
    );
  }

  // ── Flash detection for summary tiles ─────────────────
  void _checkFlash(SwapScreenState s) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      bool changed = false;
      if (_prevActive != null && _prevActive != s.activeSwaps) {
        _activeFlash = true;
        changed = true;
      }
      if (_prevReady != null && _prevReady != s.readyPorts) {
        _readyFlash = true;
        changed = true;
      }
      if (_prevCharging != null && _prevCharging != s.chargingPorts) {
        _chargingFlash = true;
        changed = true;
      }
      if (_prevFault != null && _prevFault != s.faultPorts) {
        _faultFlash = true;
        changed = true;
      }

      _prevActive = s.activeSwaps;
      _prevReady = s.readyPorts;
      _prevCharging = s.chargingPorts;
      _prevFault = s.faultPorts;

      if (changed) {
        setState(() {});
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted)
            setState(() {
              _activeFlash = false;
              _readyFlash = false;
              _chargingFlash = false;
              _faultFlash = false;
            });
        });
      }
    });
  }

  // ── Animated Metric Tile ──────────────────────────────
  Widget _animatedMetricTile(
      String label, String value, IconData icon, Color color, bool flash) {
    return Expanded(
        child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: flash ? color.withValues(alpha: 0.12) : AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: flash ? color.withValues(alpha: 0.4) : AppColors.border),
        boxShadow: flash
            ? [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 12)]
            : [],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            height: 2,
            width: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1),
            )),
        const SizedBox(height: 10),
        Row(children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          if (label == 'Active Swaps' &&
              int.tryParse(value) != null &&
              int.parse(value) > 0)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: _pulseDot(color),
            ),
        ]),
      ]),
    ));
  }

  Widget _pulseDot(Color color) => AnimatedBuilder(
        animation: _liveIndicatorCtrl,
        builder: (_, __) => Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color:
                color.withValues(alpha: 0.4 + _liveIndicatorCtrl.value * 0.6),
            shape: BoxShape.circle,
          ),
        ),
      );

  // ── Statistics Section ────────────────────────────────
  Widget _buildStatisticsSection(
      SwapScreenState swapState, SwapStateNotifier notifier) {
    final completed = notifier.swapCompletedToday;
    final inProgress = swapState.activeSwaps;
    final failed = swapState.faultPorts;
    final manual =
        swapState.events.where((e) => e.eventType == 'resolved').length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Left: Hourly chart
        Expanded(
            child: HourlySwapChart(
          hourlySwaps: notifier.hourlySwaps,
          totalToday: completed,
        )),
        const SizedBox(width: 24),
        Container(width: 1, height: 280, color: AppColors.border),
        const SizedBox(width: 24),

        // Center: Donut chart
        Expanded(
            child: SwapDonutChart(
          completed: completed,
          inProgress: inProgress,
          failed: failed,
          manuallyResolved: manual,
        )),
        const SizedBox(width: 24),
        Container(width: 1, height: 280, color: AppColors.border),
        const SizedBox(width: 24),

        // Right: Live events
        Expanded(child: LiveSwapEventsFeed(events: swapState.events)),
      ]),
    );
  }

  Widget _emptyState() => Container(
        padding: const EdgeInsets.all(60),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(LucideIcons.refreshCw, size: 36, color: AppColors.textMuted),
          SizedBox(height: 14),
          Text('No swap data available',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          SizedBox(height: 4),
          Text('Stations will appear here once connected',
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
        ])),
      );

  Widget _buildSwapActivityTable(
      AsyncValue<List<SwapDto>> swapsAsync, int? sid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Swap Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            OutlinedButton.icon(
              icon: const Icon(LucideIcons.download, size: 14),
              label: const Text('Export CSV', style: TextStyle(fontSize: 12)),
              onPressed: () {
                final exportSid = sid ??
                    ref
                        .read(swapStateProvider(sid))
                        .stationData
                        .firstOrNull
                        ?.stationId;
                _handleExport(exportSid);
              },
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        swapsAsync.when(
          data: (swaps) => _buildSwapsTable(swaps),
          loading: () => _buildShimmerTable(),
          error: (e, _) => Center(
              child: Text('Error: $e',
                  style: const TextStyle(color: AppColors.red))),
        ),
      ],
    );
  }

  Widget _buildSwapsTable(List<SwapDto> swaps) {
    if (swaps.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border)),
        child: const Center(
          child: Text('No swap activity found.',
              style: TextStyle(color: AppColors.textTertiary)),
        ),
      );
    }
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('DATE')),
              DataColumn(label: Text('CUSTOMER')),
              DataColumn(label: Text('STATION')),
              DataColumn(label: Text('RETURNED')),
              DataColumn(label: Text('RECEIVED')),
              DataColumn(label: Text('STATUS')),
            ],
            rows: swaps.map((s) {
              return DataRow(cells: [
                DataCell(Text(_formatDate(s.createdAt),
                    style: const TextStyle(fontSize: 12))),
                DataCell(Text(s.customerName,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600))),
                DataCell(
                    Text(s.stationName, style: const TextStyle(fontSize: 12))),
                DataCell(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.oldBatteryCode,
                          style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: AppColors.cyan)),
                      Text('${s.oldBatterySoc.toStringAsFixed(0)}%',
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                DataCell(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.newBatteryCode,
                          style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: AppColors.primary)),
                      Text('${s.newBatterySoc.toStringAsFixed(0)}%',
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                DataCell(_statusBadge(s.status)),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerTable() {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns:
                List.generate(6, (i) => DataColumn(label: _shimmerBox(60, 16))),
            rows: List.generate(
                5,
                (i) => DataRow(
                      cells: List.generate(6,
                          (j) => DataCell(_shimmerBox(j == 1 ? 120 : 80, 14))),
                    )),
          ),
        ),
      ),
    );
  }

  Widget _shimmerBox(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    if (status.toLowerCase().contains('completed') ||
        status.toLowerCase().contains('success')) {
      color = AppColors.primary; // Green
    } else if (status.toLowerCase().contains('pending') ||
        status.toLowerCase().contains('progress')) {
      color = AppColors.amber; // Orange
    } else if (status.toLowerCase().contains('fail') ||
        status.toLowerCase().contains('error')) {
      color = AppColors.red;
    } else {
      color = AppColors.cyan;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Text(status.toUpperCase(),
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  String _formatDate(String isoString) => TimeUtils.shortDateTime(isoString);

  Future<void> _handleExport(int? sid) async {
    if (sid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select a station to export data.')));
      return;
    }
    final swaps = ref.read(dealerSwapsListProvider(sid)).valueOrNull;
    if (swaps == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Swap data is still loading')),
      );
      return;
    }
    final fileName =
        'station_${sid}_swaps_${DateTime.now().millisecondsSinceEpoch}';
    ExportHelper.exportSwapsToCsv(swaps, fileName);
  }
}
