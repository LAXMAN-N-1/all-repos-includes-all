import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/colors.dart';
import '../../../core/utils/export_helper.dart';
import '../../../core/utils/time_utils.dart';
import '../../stations/providers/station_detail_provider.dart';
import '../../stations/providers/stations_provider.dart';
import '../../stations/models/station_state.dart';

// ── Status filter ────────────────────────────────────────────

enum _SwapFilter { all, completed, inProgress, failed }

extension _SwapFilterX on _SwapFilter {
  String get label {
    switch (this) {
      case _SwapFilter.all:        return 'All';
      case _SwapFilter.completed:  return 'Completed';
      case _SwapFilter.inProgress: return 'In Progress';
      case _SwapFilter.failed:     return 'Failed';
    }
  }

  bool matches(String status) {
    final s = status.toLowerCase();
    switch (this) {
      case _SwapFilter.all:        return true;
      case _SwapFilter.completed:  return s.contains('completed') || s.contains('success');
      case _SwapFilter.inProgress: return s.contains('pending') || s.contains('progress') || s.contains('initiated') || s.contains('payment');
      case _SwapFilter.failed:     return s.contains('fail') || s.contains('error') || s.contains('cancel');
    }
  }
}

// ── Screen ──────────────────────────────────────────────────

class SwapHistoryScreen extends ConsumerStatefulWidget {
  const SwapHistoryScreen({super.key});

  @override
  ConsumerState<SwapHistoryScreen> createState() => _SwapHistoryScreenState();
}

class _SwapHistoryScreenState extends ConsumerState<SwapHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _liveCtrl;
  int? _stationFilter;
  _SwapFilter _statusFilter = _SwapFilter.all;
  bool _hasNewEvent = false;

  final _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _liveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _liveCtrl.dispose();
    super.dispose();
  }

  List<SwapDto> _applyFilters(List<SwapDto> swaps) => swaps.where((s) {
        if (_stationFilter != null && s.stationId != _stationFilter) return false;
        return _statusFilter.matches(s.status);
      }).toList();

  ({int total, int completed, double revenue, double avg}) _kpis(List<SwapDto> list) {
    final completed = list.where((s) => _SwapFilter.completed.matches(s.status)).length;
    final revenue   = list.fold(0.0, (sum, s) => sum + s.swapAmount);
    return (
      total: list.length,
      completed: completed,
      revenue: revenue,
      avg: list.isEmpty ? 0.0 : revenue / list.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sid = _stationFilter;
    final swapsAsync = ref.watch(dealerSwapsListProvider(sid));
    final stations   = ref.watch(stationsProvider).stations;

    // Flash badge whenever the swap list gets a new value from realtime invalidation.
    ref.listen<AsyncValue<List<SwapDto>>>(dealerSwapsListProvider(sid), (prev, next) {
      if (prev?.valueOrNull != null && next.hasValue && !_hasNewEvent) {
        final prevLen = prev!.valueOrNull!.length;
        final nextLen = next.valueOrNull!.length;
        if (nextLen > prevLen) {
          setState(() => _hasNewEvent = true);
          Future.delayed(const Duration(seconds: 4), () {
            if (mounted) setState(() => _hasNewEvent = false);
          });
        }
      }
    });

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.cardBg,
      onRefresh: () async {
        ref.invalidate(dealerSwapsListProvider(sid));
        await Future.delayed(const Duration(milliseconds: 600));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildHeader(),
          const SizedBox(height: 22),

          swapsAsync.when(
            data: (swaps) {
              final filtered = _applyFilters(swaps);
              final k = _kpis(filtered);
              return _buildKpiStrip(k);
            },
            loading: () => _buildKpiShimmer(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 22),

          _buildFilterBar(stations),
          const SizedBox(height: 16),

          swapsAsync.when(
            data: (swaps) => _buildTable(_applyFilters(swaps), swaps),
            loading: () => _buildShimmerTable(),
            error: (e, _) => _buildError(e),
          ),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Swap History',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 3),
          const Text('All battery swap transactions at your stations',
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
        ]),
      ),

      if (_hasNewEvent)
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            AnimatedBuilder(
              animation: _liveCtrl,
              builder: (_, __) => Container(
                width: 6, height: 6,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.4 + _liveCtrl.value * 0.6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Text('New swap', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ]),
        ),

      // Live dot
      AnimatedBuilder(
        animation: _liveCtrl,
        builder: (_, __) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 6, height: 6,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.4 + _liveCtrl.value * 0.6),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3 * _liveCtrl.value), blurRadius: 6)],
              ),
            ),
            const SizedBox(width: 6),
            const Text('Live · Connected', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ]),
        ),
      ),
    ]);
  }

  // ── KPI Strip ───────────────────────────────────────────

  Widget _buildKpiStrip(({int total, int completed, double revenue, double avg}) k) {
    return Row(children: [
      _kpiCard('Total Swaps',   '${k.total}',              LucideIcons.arrowLeftRight, AppColors.cyan,   null),
      const SizedBox(width: 12),
      _kpiCard('Completed',     '${k.completed}',          LucideIcons.checkCircle2,   AppColors.primary, k.total > 0 ? k.completed / k.total : 0),
      const SizedBox(width: 12),
      _kpiCard('Total Revenue', _currency.format(k.revenue), LucideIcons.indianRupee, AppColors.amber,   null),
      const SizedBox(width: 12),
      _kpiCard('Avg Amount',    _currency.format(k.avg),   LucideIcons.trendingUp,     AppColors.purple,  null),
    ]);
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color, double? ratio) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(height: 2, width: 24, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(1))),
          const SizedBox(height: 10),
          Row(children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary, fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          if (ratio != null) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 3,
              ),
            ),
            const SizedBox(height: 3),
            Text('${(ratio * 100).toStringAsFixed(0)}% success rate',
                style: TextStyle(fontSize: 9, color: color)),
          ],
        ]),
      ),
    );
  }

  Widget _buildKpiShimmer() => Row(
        children: List.generate(4, (i) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 3 ? 12 : 0),
            child: Container(
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
            ),
          ),
        )),
      );

  // ── Filter Bar ──────────────────────────────────────────

  Widget _buildFilterBar(List<StationDto> stations) {
    return Row(children: [
      Expanded(
        child: Wrap(
          spacing: 8,
          children: _SwapFilter.values.map((f) {
            final sel = _statusFilter == f;
            return ChoiceChip(
              label: Text(f.label),
              selected: sel,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                color: sel ? AppColors.textPrimary : AppColors.textTertiary,
              ),
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              backgroundColor: AppColors.cardBg,
              side: BorderSide(
                color: sel ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border,
              ),
              onSelected: (_) => setState(() => _statusFilter = f),
            );
          }).toList(),
        ),
      ),
      const SizedBox(width: 12),
      Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int?>(
            value: _stationFilter,
            icon: const Icon(LucideIcons.chevronDown, size: 14, color: AppColors.textMuted),
            dropdownColor: AppColors.cardBg,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Stations')),
              ...stations.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
            ],
            onChanged: (val) => setState(() => _stationFilter = val),
          ),
        ),
      ),
    ]);
  }

  // ── Table ───────────────────────────────────────────────

  Widget _buildTable(List<SwapDto> filtered, List<SwapDto> all) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Text(
            '${filtered.length} swap${filtered.length == 1 ? '' : 's'}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          if (filtered.length != all.length) ...[
            const SizedBox(width: 8),
            Text('(filtered from ${all.length})',
                style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
          ],
        ]),
        OutlinedButton.icon(
          icon: const Icon(LucideIcons.download, size: 13),
          label: const Text('Export CSV', style: TextStyle(fontSize: 12)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.border),
            foregroundColor: AppColors.textSecondary,
          ),
          onPressed: filtered.isEmpty ? null : () {
            final name = 'swap_history_${DateTime.now().millisecondsSinceEpoch}';
            ExportHelper.exportSwapsToCsv(filtered, name);
          },
        ),
      ]),
      const SizedBox(height: 12),
      filtered.isEmpty ? _emptyState() : _dataTable(filtered),
    ]);
  }

  Widget _dataTable(List<SwapDto> swaps) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStatePropertyAll(AppColors.pageBg.withValues(alpha: 0.5)),
            headingTextStyle: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700,
              color: AppColors.textMuted, letterSpacing: 0.8,
            ),
            dataTextStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            dividerThickness: 0.5,
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text('#')),
              DataColumn(label: Text('DATE / TIME')),
              DataColumn(label: Text('CUSTOMER')),
              DataColumn(label: Text('STATION')),
              DataColumn(label: Text('RETURNED BATTERY')),
              DataColumn(label: Text('RECEIVED BATTERY')),
              DataColumn(label: Text('AMOUNT'), numeric: true),
              DataColumn(label: Text('PAYMENT')),
              DataColumn(label: Text('STATUS')),
            ],
            rows: swaps.asMap().entries.map((e) {
              final i = e.key;
              final s = e.value;
              return DataRow(
                color: WidgetStatePropertyAll(
                  i.isOdd ? AppColors.pageBg.withValues(alpha: 0.25) : Colors.transparent,
                ),
                cells: [
                  DataCell(Text('#${s.id}',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.textMuted))),
                  DataCell(_dateCell(s.createdAt, s.completedAt)),
                  DataCell(_customerCell(s.customerName)),
                  DataCell(Row(children: [
                    const Icon(LucideIcons.mapPin, size: 11, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(s.stationName.isNotEmpty ? s.stationName : '—'),
                  ])),
                  DataCell(_batteryCell(s.oldBatteryCode, s.oldBatterySoc, AppColors.amber)),
                  DataCell(_batteryCell(s.newBatteryCode, s.newBatterySoc, AppColors.primary)),
                  DataCell(Text(_currency.format(s.swapAmount),
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                  DataCell(_badge(s.paymentStatus,
                      (s.paymentStatus.toLowerCase().contains('paid') || s.paymentStatus.toLowerCase().contains('success'))
                          ? AppColors.primary : AppColors.amber)),
                  DataCell(_badge(s.status, _statusColor(s.status))),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _dateCell(String createdAt, String? completedAt) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_formatDate(createdAt),
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
        if (completedAt != null)
          Text('Done ${_timeAgo(completedAt)}',
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _customerCell(String name) {
    return Row(children: [
      Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: AppColors.cyan.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.cyan),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Text(name.isNotEmpty ? name : '—',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _batteryCell(String code, double soc, Color accent) {
    if (code.isEmpty) {
      return const Text('—', style: TextStyle(color: AppColors.textMuted, fontSize: 12));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(code,
            style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: accent)),
        Row(children: [
          Container(
            width: 32, height: 3,
            margin: const EdgeInsets.only(right: 4, top: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1.5),
              color: AppColors.border,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (soc / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1.5),
                  color: soc > 30 ? accent : AppColors.red,
                ),
              ),
            ),
          ),
          Text('${soc.toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 9, color: AppColors.textTertiary)),
        ]),
      ],
    );
  }

  Widget _badge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(label.toUpperCase(),
            style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700)),
      );

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('completed') || s.contains('success')) return AppColors.primary;
    if (s.contains('pending') || s.contains('progress') || s.contains('initiated')) return AppColors.amber;
    if (s.contains('fail') || s.contains('error') || s.contains('cancel')) return AppColors.red;
    return AppColors.cyan;
  }

  Widget _buildShimmerTable() => Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: List.generate(9, (_) => DataColumn(
                  label: Container(width: 60, height: 12,
                      decoration: BoxDecoration(color: AppColors.border.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(3))))),
              rows: List.generate(8, (i) => DataRow(cells: List.generate(9, (j) => DataCell(
                Container(width: j == 2 ? 110 : 70, height: 12,
                    decoration: BoxDecoration(color: AppColors.border.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(3))),
              )))),
            ),
          ),
        ),
      );

  Widget _emptyState() => Container(
        padding: const EdgeInsets.symmetric(vertical: 60),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(LucideIcons.arrowLeftRight, size: 36, color: AppColors.textMuted),
          const SizedBox(height: 14),
          const Text('No swaps found',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(
            _statusFilter == _SwapFilter.all
                ? 'Swap transactions will appear here once activity begins'
                : 'No ${_statusFilter.label.toLowerCase()} swaps match current filters',
            style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
          if (_statusFilter != _SwapFilter.all || _stationFilter != null) ...[
            const SizedBox(height: 14),
            TextButton(
              onPressed: () => setState(() {
                _statusFilter = _SwapFilter.all;
                _stationFilter = null;
              }),
              child: const Text('Clear filters', style: TextStyle(color: AppColors.primary, fontSize: 12)),
            ),
          ],
        ]),
      );

  Widget _buildError(Object e) => Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text('Failed to load swaps: $e',
              style: const TextStyle(color: AppColors.red, fontSize: 13)),
        ),
      );

  // ── Helpers ─────────────────────────────────────────────

  String _formatDate(String iso) => TimeUtils.shortDateTime(iso);

  String _timeAgo(String iso) => TimeUtils.timeAgo(iso);
}
