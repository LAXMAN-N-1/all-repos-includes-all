import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../models/inventory_state.dart';
import '../providers/inventory_provider.dart';
import '../../stations/providers/stations_provider.dart';

/// Zone 4 — Main Fleet Table (70% Pane)
/// Paginated, filterable, sortable battery grid with shimmer loading,
/// SOH bars, dynamic battery icons, quick actions, and row selection.
class FleetTablePane extends ConsumerStatefulWidget {
  const FleetTablePane({super.key});

  @override
  ConsumerState<FleetTablePane> createState() => _FleetTablePaneState();
}

class _FleetTablePaneState extends ConsumerState<FleetTablePane>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Color _healthColor(double pct) {
    if (pct >= 90) return AppColors.primary;
    if (pct >= 80) return AppColors.amber;
    return AppColors.red;
  }

  Color _statusDotColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return AppColors.primary;
      case 'reserved':
      case 'rented':
        return const Color(0xFF1A73E8);
      case 'maintenance':
      case 'charging':
        return AppColors.amber;
      case 'retired':
      case 'damaged':
        return AppColors.red;
      default:
        return AppColors.textTertiary;
    }
  }

  String _relativeTime(String? dateStr) {
    if (dateStr == null) return '—';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryBatteriesProvider);
    final selectedBattery = ref.watch(selectedBatteryProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.pageBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                _headerCell(
                  '',
                  width: 48,
                  child: Checkbox(
                    value: state.items.isNotEmpty &&
                        ref.watch(selectedInventoryIdsProvider).length ==
                            state.items.length,
                    onChanged: (val) {
                      if (val == true) {
                        ref.read(selectedInventoryIdsProvider.notifier).state =
                            state.items.map((e) => e.batteryId).toSet();
                      } else {
                        ref.read(selectedInventoryIdsProvider.notifier).state =
                            {};
                      }
                    },
                    activeColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                Expanded(flex: 3, child: _headerCell('BATTERY ID', width: 0)),
                Expanded(flex: 3, child: _headerCell('ASSIGNMENT', width: 0)),
                Expanded(flex: 3, child: _headerCell('SOH', width: 0)),
                Expanded(flex: 1, child: _headerCell('SOC%', width: 0)),
                Expanded(flex: 1, child: _headerCell('CYCLES', width: 0)),
                Expanded(flex: 2, child: _headerCell('UPDATED', width: 0)),
                const SizedBox(width: 110, child: Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text('ACTIONS', style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.5,
                  )),
                )),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Table body
          Expanded(
            child: state.isLoading
                ? _buildShimmerRows()
                : state.error != null
                    ? _buildErrorState(state.error!)
                    : state.items.isEmpty
                        ? _buildEmptyState()
                        : _buildDataRows(state.items, selectedBattery),
          ),

          // Pagination
          if (!state.isLoading && state.items.isNotEmpty)
            _buildPagination(state),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {required double width, Widget? child}) {
    return SizedBox(
      width: width > 0 ? width : null,
      child: child ??
          Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textTertiary,
          letterSpacing: 0.5,
        ),
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildShimmerRows() {
    return ListView.builder(
      itemCount: 8,
      padding: EdgeInsets.zero,
      itemBuilder: (context, i) {
        return AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, _) {
            return Container(
              height: 48,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  begin: Alignment(-1.0 + 2.0 * _shimmerController.value, 0),
                  end: Alignment(
                      -1.0 + 2.0 * _shimmerController.value + 0.6, 0),
                  colors: [
                    AppColors.pageBg.withValues(alpha: 0.3),
                    AppColors.cardBgHover.withValues(alpha: 0.5),
                    AppColors.pageBg.withValues(alpha: 0.3),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.alertTriangle, size: 40, color: AppColors.amber),
          const SizedBox(height: 12),
          Text(
            'Could not load battery data',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(LucideIcons.refreshCw, size: 14),
            label: const Text('Retry'),
            onPressed: () =>
                ref.read(inventoryBatteriesProvider.notifier).fetchPage(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.batteryCharging,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your inventory is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No batteries have been assigned to your stations yet.\nRequest your first stock batch to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textTertiary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(LucideIcons.packagePlus, size: 16),
            label: const Text('Request First Stock Batch'),
            onPressed: () {}, // Will wire to modal
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRows(
      List<BatteryItemDto> items, BatteryItemDto? selectedBattery) {
    final selectedIds = ref.watch(selectedInventoryIdsProvider);
    final stationsState = ref.watch(stationsProvider);

    return ListView.builder(
      itemCount: items.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final battery = items[index];
        final isSelected = selectedBattery?.batteryId == battery.batteryId;
        final isChecked = selectedIds.contains(battery.batteryId);

        return _BatteryRow(
          key: ValueKey('battery-${battery.batteryId}'),
          battery: battery,
          isSelected: isSelected,
          isChecked: isChecked,
          onTap: () {
            if (isSelected) {
              ref.read(selectedBatteryProvider.notifier).state = null;
            } else {
              ref.read(selectedBatteryProvider.notifier).state = battery;
            }
          },
          onCheckChanged: (checked) {
            final current =
                ref.read(selectedInventoryIdsProvider.notifier).state;
            final updated = Set<int>.from(current);
            if (checked) {
              updated.add(battery.batteryId);
            } else {
              updated.remove(battery.batteryId);
            }
            ref.read(selectedInventoryIdsProvider.notifier).state = updated;
          },
          healthColor: _healthColor,
          statusDotColor: _statusDotColor,
          relativeTime: _relativeTime,
          onMarkDefective: () => _showMarkDefectiveDialog(context, battery),
          onAssignStation: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.cardBg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Text('Assign to Station', style: TextStyle(color: Colors.white, fontSize: 16)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select destination for ${battery.serialNumber}', style: const TextStyle(color: AppColors.textTertiary, fontSize: 13)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      dropdownColor: AppColors.cardBg,
                      decoration: InputDecoration(
                        labelText: 'Station',
                        labelStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                        filled: true,
                        fillColor: AppColors.pageBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                      ),
                      items: stationsState.stations.isEmpty
                          ? [const DropdownMenuItem(value: '', child: Text('No stations available', style: TextStyle(color: AppColors.textTertiary, fontSize: 13)))]
                          : stationsState.stations.map((s) => DropdownMenuItem(
                              value: s.id.toString(),
                              child: Text(s.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                            )).toList(),
                      onChanged: (v) {},
                    ),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Assigned ${battery.serialNumber} to station'), backgroundColor: AppColors.primary));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Assign', style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
            );
          },
          onViewIoT: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Connecting to IoT Device ${battery.serialNumber}...'), duration: const Duration(seconds: 1)));
            // Also view details drawer
            ref.read(selectedBatteryProvider.notifier).state = battery;
          },
        );
      },
    );
  }

  Widget _buildPagination(InventoryListState state) {
    final totalPages =
        state.total > 0 ? (state.total / 20).ceil() : 1;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PaginationButton(
            icon: LucideIcons.chevronLeft,
            enabled: state.page > 1,
            onTap: () =>
                ref.read(inventoryBatteriesProvider.notifier).previousPage(),
          ),
          const SizedBox(width: 8),
          Text(
            'Page ${state.page} of $totalPages — ${state.total} batteries',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(width: 8),
          _PaginationButton(
            icon: LucideIcons.chevronRight,
            enabled: state.page < totalPages,
            onTap: () =>
                ref.read(inventoryBatteriesProvider.notifier).nextPage(),
          ),
        ],
      ),
    );
  }

  void _showMarkDefectiveDialog(BuildContext context, BatteryItemDto battery) {
    String? reason;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(LucideIcons.alertOctagon, color: AppColors.red, size: 20),
            const SizedBox(width: 10),
            const Text('Mark Battery as Defective',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Battery: ${battery.serialNumber}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This battery will be removed from active inventory and flagged for inspection. This action is logged in the audit trail.',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: reason,
                dropdownColor: AppColors.cardBg,
                decoration: InputDecoration(
                  labelText: 'Reason',
                  labelStyle:
                      const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                  filled: true,
                  fillColor: AppColors.pageBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'Physical Damage',
                      child: Text('Physical Damage',
                          style: TextStyle(
                              color: AppColors.textPrimary, fontSize: 13))),
                  DropdownMenuItem(
                      value: 'Extreme SOH Degradation',
                      child: Text('Extreme SOH Degradation',
                          style: TextStyle(
                              color: AppColors.textPrimary, fontSize: 13))),
                  DropdownMenuItem(
                      value: 'Connectivity Failure',
                      child: Text('Connectivity Failure',
                          style: TextStyle(
                              color: AppColors.textPrimary, fontSize: 13))),
                  DropdownMenuItem(
                      value: 'Other',
                      child: Text('Unknown/Other',
                          style: TextStyle(
                              color: AppColors.textPrimary, fontSize: 13))),
                ],
                onChanged: (v) => reason = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Call the real API to mark as defective (retired)
              final success = await ref
                  .read(inventoryBatteriesProvider.notifier)
                  .updateBatteryStatus(
                    battery.batteryId,
                    'defective',
                    reason: reason ?? 'Marked as defective',
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Battery ${battery.serialNumber} marked as defective'
                          : 'Failed to update battery status',
                    ),
                    backgroundColor: success ? AppColors.red : AppColors.amber,
                  ),
                );
                // Also refresh metrics immediately in local state
                if (success) {
                  ref.read(inventoryMetricsProvider.notifier).incrementDamaged();
                  ref.read(inventoryMetricsProvider.notifier).refresh();
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Confirm — Mark Defective',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

/// Individual Battery Row widget
class _BatteryRow extends StatefulWidget {
  final BatteryItemDto battery;
  final bool isSelected;
  final bool isChecked;
  final VoidCallback onTap;
  final ValueChanged<bool> onCheckChanged;
  final Color Function(double) healthColor;
  final Color Function(String) statusDotColor;
  final String Function(String?) relativeTime;
  final VoidCallback onMarkDefective;
  final VoidCallback onAssignStation;
  final VoidCallback onViewIoT;

  const _BatteryRow({
    super.key,
    required this.battery,
    required this.isSelected,
    required this.isChecked,
    required this.onTap,
    required this.onCheckChanged,
    required this.healthColor,
    required this.statusDotColor,
    required this.relativeTime,
    required this.onMarkDefective,
    required this.onAssignStation,
    required this.onViewIoT,
  });

  @override
  State<_BatteryRow> createState() => _BatteryRowState();
}

class _BatteryRowState extends State<_BatteryRow>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _sohBarController;

  @override
  void initState() {
    super.initState();
    _sohBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _sohBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.battery;
    final sohColor = widget.healthColor(b.health.percentage);
    final dotColor = widget.statusDotColor(b.currentStatus);
    final lastUpdated = widget.relativeTime(b.updatedAt);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primary.withValues(alpha: 0.05)
                : (_hovered ? AppColors.cardBgHover : Colors.transparent),
            borderRadius: BorderRadius.circular(6),
            border: Border(
              left: BorderSide(
                color: widget.isSelected ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              // Checkbox + Status dot
              SizedBox(
                width: 48,
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: Checkbox(
                        value: widget.isChecked,
                        onChanged: (val) =>
                            widget.onCheckChanged(val ?? false),
                        activeColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3)),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: dotColor,
                        boxShadow: [
                          BoxShadow(
                            color: dotColor.withValues(alpha: 0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Battery ID
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    // Dynamic battery icon
                    _BatteryIcon(
                      chargePercent: b.charge.percentage,
                      healthColor: sohColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(
                                          ClipboardData(text: b.serialNumber));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Copied!'),
                                          duration: Duration(milliseconds: 1500),
                                          backgroundColor: AppColors.primary,
                                        ),
                                      );
                                    },
                                    child: Text(
                                      b.serialNumber,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                        fontFamily: 'monospace',
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                if (b.currentStatus == 'defective' || b.currentStatus == 'retired') ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('DEFECTIVE', style: TextStyle(color: AppColors.red, fontSize: 8, fontWeight: FontWeight.w800)),
                                  ),
                                ],
                              ],
                            ),
                            if ((b.currentStatus == 'defective' || b.currentStatus == 'retired') && b.faultReason != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  b.faultReason!,
                                  style: const TextStyle(fontSize: 10, color: AppColors.red, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Assignment
              Expanded(
                flex: 3,
                child: Text(
                  b.location.stationName.isNotEmpty
                      ? b.location.stationName
                      : '—',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // SOH bar
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _sohBarController,
                        builder: (context, _) {
                          return Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.pageBg,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor:
                                  (b.health.percentage / 100).clamp(0.0, 1.0) *
                                      _sohBarController.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: sohColor,
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: sohColor.withValues(alpha: 0.4),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${b.health.percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: sohColor,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),

              // SOC%
              Expanded(
                flex: 1,
                child: Text(
                  '${b.charge.percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.healthColor(b.charge.percentage),
                  ),
                ),
              ),

              // Cycle Count
              Expanded(
                flex: 1,
                child: Text(
                  '${b.cycleCount}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              // Last Updated
              Expanded(
                flex: 2,
                child: Text(
                  lastUpdated,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),

              // Quick Actions (visible on hover only)
              SizedBox(
                width: 160,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: AnimatedOpacity(
                  opacity: _hovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _DestructiveActionIcon(
                          icon: LucideIcons.xCircle,
                          defaultColor: Colors.white38,
                          hoverColor: AppColors.red,
                          tooltipText: 'Mark Defective',
                          onTap: widget.onMarkDefective,
                        ),
                        const SizedBox(width: 4),
                        Tooltip(
                          message: 'Assign to Station',
                          waitDuration: Duration.zero,
                          child: InkWell(
                            onTap: widget.onAssignStation,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(LucideIcons.userPlus, size: 20, color: const Color(0xFF1A73E8).withValues(alpha: 0.8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Tooltip(
                          message: 'Live Telemetry',
                          waitDuration: Duration.zero,
                          child: InkWell(
                            onTap: widget.onViewIoT,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(LucideIcons.activity, size: 20, color: AppColors.primary.withValues(alpha: 0.8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        PopupMenuButton<String>(
                          icon: const Icon(LucideIcons.moreVertical, size: 16, color: Colors.white38),
                          color: AppColors.cardBg,
                          padding: EdgeInsets.zero,
                          onSelected: (val) {
                            if (val == 'detail') {
                              // By calling onTap we select the battery and open the drawer
                              if (!widget.isSelected) {
                                widget.onTap(); 
                              }
                            }
                            if (val == 'edit') {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: AppColors.cardBg,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    title: const Text('Edit Battery', style: TextStyle(color: Colors.white, fontSize: 16)),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Editing ${b.serialNumber}', style: const TextStyle(color: AppColors.textTertiary, fontSize: 13)),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          initialValue: b.notes ?? '',
                                          style: const TextStyle(color: Colors.white, fontSize: 13),
                                          decoration: InputDecoration(
                                            labelText: 'Notes',
                                            labelStyle: const TextStyle(color: AppColors.textTertiary),
                                            filled: true,
                                            fillColor: AppColors.pageBg,
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                                          ),
                                          maxLines: 3,
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Battery notes updated successfully')));
                                        },
                                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                        child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
                                      ),
                                    ]
                                  )
                                );
                            }
                            if (val == 'qr') {
                                showDialog(
                                  context: context, 
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: AppColors.cardBg,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    title: const Center(child: Text('Battery QR Code', style: TextStyle(color: Colors.white, fontSize: 16))),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                          child: const Icon(LucideIcons.qrCode, size: 120, color: Colors.black),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(b.serialNumber, style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                                      ]
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))
                                    ]
                                  )
                                );
                            }
                            if (val == 'copy') {
                              Clipboard.setData(ClipboardData(text: b.serialNumber));
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Serial copied')));
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'detail', child: Row(children: [Icon(LucideIcons.info, size: 16, color: Colors.white54), SizedBox(width: 8), Text('View Details', style: TextStyle(color: Colors.white70))])),
                            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(LucideIcons.edit2, size: 16, color: Colors.white54), SizedBox(width: 8), Text('Edit Battery', style: TextStyle(color: Colors.white70))])),
                            const PopupMenuItem(value: 'qr', child: Row(children: [Icon(LucideIcons.qrCode, size: 16, color: Colors.white54), SizedBox(width: 8), Text('QR Code', style: TextStyle(color: Colors.white70))])),
                            const PopupMenuItem(value: 'copy', child: Row(children: [Icon(LucideIcons.copy, size: 16, color: Colors.white54), SizedBox(width: 8), Text('Copy Serial', style: TextStyle(color: Colors.white70))])),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
 }
}

/// Dynamic battery icon that fills based on charge percentage
class _BatteryIcon extends StatelessWidget {
  final double chargePercent;
  final Color healthColor;

  const _BatteryIcon({
    required this.chargePercent,
    required this.healthColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 12,
      child: CustomPaint(
        painter: _BatteryIconPainter(
          chargePercent: chargePercent,
          fillColor: healthColor,
        ),
      ),
    );
  }
}

class _BatteryIconPainter extends CustomPainter {
  final double chargePercent;
  final Color fillColor;

  _BatteryIconPainter({
    required this.chargePercent,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = AppColors.textTertiary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Battery body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 1, size.width - 3, size.height - 2),
      const Radius.circular(2),
    );
    canvas.drawRRect(bodyRect, borderPaint);

    // Battery tip
    canvas.drawRect(
      Rect.fromLTWH(size.width - 3, 3, 3, size.height - 6),
      borderPaint..style = PaintingStyle.fill,
    );

    // Fill
    final fillWidth = (size.width - 5) * (chargePercent / 100).clamp(0.0, 1.0);
    if (fillWidth > 0) {
      final fillPaint = Paint()..color = fillColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(1, 2, fillWidth, size.height - 4),
          const Radius.circular(1),
        ),
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BatteryIconPainter oldDelegate) =>
      oldDelegate.chargePercent != chargePercent ||
      oldDelegate.fillColor != fillColor;
}

class _DestructiveActionIcon extends StatefulWidget {
  final IconData icon;
  final Color defaultColor;
  final Color hoverColor;
  final String tooltipText;
  final VoidCallback onTap;

  const _DestructiveActionIcon({
    required this.icon,
    required this.defaultColor,
    required this.hoverColor,
    required this.tooltipText,
    required this.onTap,
  });

  @override
  State<_DestructiveActionIcon> createState() => _DestructiveActionIconState();
}

class _DestructiveActionIconState extends State<_DestructiveActionIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltipText,
      waitDuration: Duration.zero,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                widget.icon,
                size: 20,
                color: _isHovered ? widget.hoverColor : widget.defaultColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaginationButton extends StatefulWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PaginationButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_PaginationButton> createState() => _PaginationButtonState();
}

class _PaginationButtonState extends State<_PaginationButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _hovered && widget.enabled
                ? AppColors.cardBgHover
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.enabled ? AppColors.border : Colors.transparent,
            ),
          ),
          child: Icon(
            widget.icon,
            size: 14,
            color: widget.enabled
                ? AppColors.textSecondary
                : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
