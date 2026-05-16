import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../providers/inventory_provider.dart';
import '../widgets/inventory_command_bar.dart';
import '../widgets/kpi_metric_banner.dart';
import '../widgets/filter_status_strip.dart';
import '../widgets/fleet_table_pane.dart';
import '../widgets/collapsible_fleet_panel.dart';
import '../widgets/battery_detail_drawer.dart';
import '../widgets/add_battery_modal.dart';
import '../widgets/bulk_action_bar.dart';
import '../models/inventory_state.dart';

/// WEZU Dealer Portal — Inventory Screen
/// Mission Control Center: Fixed-height, non-scrolling canvas.
/// Fleet Intelligence is a collapsible side panel to prevent vertical overflow.
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pageLoadController;

  @override
  void initState() {
    super.initState();
    _pageLoadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _pageLoadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<BatteryItemDto?>(selectedBatteryProvider, (prev, next) {
      if (next != null) {
        _showBatteryDetailDrawer(context, next);
      }
    });

    final selectedIds = ref.watch(selectedInventoryIdsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              color: AppColors.pageBg,
              child: Column(
                children: [
                  // ─── Zone 1: Top Command Bar (fixed, ~56px) ───
                  _fadeIn(0.0, 0.2, child: const InventoryCommandBar()),

                  // ─── Zone 2: KPI Metric Banner (fixed, ~110px) ───
                  _fadeIn(0.1, 0.4, child: const KpiMetricBanner()),

                  // ─── Zone 3: Filter & Status Strip (fixed, ~44px) ───
                  _fadeIn(0.15, 0.45, child: const FilterStatusStrip()),

                  // ─── Zone 4: Fleet Table + Collapsible Panel (fills remaining) ───
                  Expanded(
                    child: _fadeIn(
                      0.2,
                      0.6,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(24, 12, 12, 12),
                              child: FleetTablePane(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 12, 24, 12),
                            child: CollapsibleFleetPanel(
                              onRequestStock: () =>
                                  context.go('/operations/request-batteries'),
                              onReceiveStock: () =>
                                  _showReceiveStockModal(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Zone 6: Bulk Action Bar (slides from bottom) ───
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BulkActionBar(
                selectedCount: selectedIds.length,
                onDeselectAll: () {
                  ref.read(selectedInventoryIdsProvider.notifier).state = {};
                },
                onMoveMaintenance: () =>
                    _showBulkMaintenanceDialog(context, selectedIds),
                onReassignStation: () {},
                onFirmwareUpdate: () {},
              ),
            ),

            // ─── Zone 6: QR Scanner FAB (floating, bottom-right) ───
            Positioned(
              right: 24,
              bottom: selectedIds.length >= 2 ? 80 : 24,
              child: _fadeIn(
                0.5,
                0.8,
                child: _QRScannerFAB(
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierColor: Colors.black.withValues(alpha: 0.5),
                      builder: (_) => const AddBatteryModal(),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Desktop and compact layouts are no longer needed — the table
  // is always full-width. Fleet Intelligence lives above the table
  // as a horizontal strip, and Asset Deep-Dive opens as an overlay.

  /// Helper: staggered fade-in for page-load animation
  Widget _fadeIn(double begin, double end, {required Widget child}) {
    return AnimatedBuilder(
      animation: _pageLoadController,
      builder: (context, _) {
        final progress = Curves.easeOut.transform(
          ((_pageLoadController.value - begin) / (end - begin)).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - progress)),
            child: child,
          ),
        );
      },
    );
  }

  void _showBatteryDetailDrawer(BuildContext context, BatteryItemDto battery) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return BatteryDetailDrawer(battery: battery);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
    ).then((_) {
      // Clear selection when dismissed
      if (mounted) {
        ref.read(selectedBatteryProvider.notifier).state = null;
      }
    });
  }

  void _showBulkMaintenanceDialog(BuildContext context, Set<int> selectedIds) {
    if (selectedIds.length < 2) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(LucideIcons.wrench, color: AppColors.amber, size: 20),
          SizedBox(width: 10),
          Text('Move to Maintenance',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        ]),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${selectedIds.length} batteries will be moved to maintenance',
                style: const TextStyle(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              const Text(
                'All selected batteries will be removed from active availability and flagged for scheduled maintenance. This action is logged.',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
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
              final success = await ref
                  .read(inventoryBatteriesProvider.notifier)
                  .bulkUpdateStatus(
                    selectedIds.toList(),
                    'maintenance',
                    reason: 'Bulk moved to maintenance',
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '${selectedIds.length} batteries moved to maintenance'
                          : 'Bulk update failed',
                    ),
                    backgroundColor:
                        success ? AppColors.primary : AppColors.red,
                  ),
                );
                if (success) {
                  ref.read(selectedInventoryIdsProvider.notifier).state = {};
                  ref.read(inventoryMetricsProvider.notifier).refresh();
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.amber),
            child: const Text('Confirm — Move to Maintenance',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showReceiveStockModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _ReceiveStockDialog(ref: ref),
    );
  }
}

/// Receive Stock Dialog — lists approved stock requests and lets dealer confirm receipt
class _ReceiveStockDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _ReceiveStockDialog({required this.ref});

  @override
  ConsumerState<_ReceiveStockDialog> createState() =>
      _ReceiveStockDialogState();
}

class _ReceiveStockDialogState extends ConsumerState<_ReceiveStockDialog> {
  bool _loading = true;
  List<Map<String, dynamic>> _requests = [];
  int? _selectedRequestId;
  int? _actualQuantity;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    final requests = await ref
        .read(inventoryBatteriesProvider.notifier)
        .fetchPendingStockRequests();
    if (mounted)
      setState(() {
        _requests = requests;
        _loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(children: [
        Icon(LucideIcons.packageCheck, color: AppColors.primary, size: 20),
        SizedBox(width: 10),
        Text('Receive Stock',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
      ]),
      content: SizedBox(
        width: 460,
        child: _loading
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            : _requests.isEmpty
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.packageX,
                          size: 40, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      const Text(
                        'No approved stock requests pending receipt.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.textTertiary, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Submit a stock request first. Once admin approves it, it will appear here for you to confirm receipt.',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select the approved request and confirm that stock has been received at your location.',
                        style: TextStyle(
                            color: AppColors.textTertiary, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      // Request selector
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: _requests.map((r) {
                            final id = r['id'] as int?;
                            final qty =
                                r['quantity'] ?? r['requested_quantity'] ?? 0;
                            final model = r['model_name'] ??
                                r['battery_model'] ??
                                'Standard Battery';
                            final approvedAt =
                                r['approved_at'] ?? r['updated_at'] ?? '';
                            final selected = id == _selectedRequestId;
                            return InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => setState(() {
                                _selectedRequestId = id;
                                _actualQuantity = qty is int
                                    ? qty
                                    : int.tryParse(qty.toString());
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primary
                                          .withValues(alpha: 0.08)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primary
                                            .withValues(alpha: 0.4)
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: selected
                                              ? AppColors.primary
                                              : AppColors.border,
                                          width: 2,
                                        ),
                                        color: selected
                                            ? AppColors.primary
                                            : Colors.transparent,
                                      ),
                                      child: selected
                                          ? const Icon(Icons.check,
                                              size: 10, color: Colors.white)
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$qty units — $model',
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (approvedAt.isNotEmpty)
                                            Text(
                                              'Approved: $approvedAt',
                                              style: const TextStyle(
                                                  color: AppColors.textMuted,
                                                  fontSize: 10),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'Approved',
                                        style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      if (_selectedRequestId != null) ...[
                        const SizedBox(height: 12),
                        TextField(
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Actual quantity received',
                            labelStyle: const TextStyle(
                                color: AppColors.textTertiary, fontSize: 12),
                            filled: true,
                            fillColor: AppColors.pageBg,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: AppColors.border)),
                          ),
                          controller: TextEditingController(
                              text: _actualQuantity?.toString() ?? ''),
                          onChanged: (v) => _actualQuantity = int.tryParse(v),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _notesController,
                          maxLines: 2,
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            labelText:
                                'Notes (optional — e.g. condition, discrepancies)',
                            labelStyle: const TextStyle(
                                color: AppColors.textTertiary, fontSize: 12),
                            filled: true,
                            fillColor: AppColors.pageBg,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: AppColors.border)),
                          ),
                        ),
                      ],
                    ],
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (_requests.isNotEmpty)
          ElevatedButton.icon(
            icon: const Icon(LucideIcons.check, size: 14, color: Colors.white),
            label: const Text('Confirm Receipt',
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: _selectedRequestId == null
                ? null
                : () async {
                    Navigator.pop(context);
                    final success = await ref
                        .read(inventoryBatteriesProvider.notifier)
                        .confirmStockReceived(
                          _selectedRequestId!,
                          actualQuantity: _actualQuantity,
                          notes: _notesController.text.isEmpty
                              ? null
                              : _notesController.text,
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(success
                            ? 'Stock receipt confirmed. Inventory updated.'
                            : 'Failed to confirm receipt. Please try again.'),
                        backgroundColor:
                            success ? AppColors.primary : AppColors.red,
                      ));
                      if (success) {
                        ref.read(inventoryMetricsProvider.notifier).refresh();
                      }
                    }
                  },
          ),
      ],
    );
  }
}

/// QR Scanner FAB with breathing pulse animation
class _QRScannerFAB extends StatefulWidget {
  final VoidCallback onTap;
  const _QRScannerFAB({required this.onTap});

  @override
  State<_QRScannerFAB> createState() => _QRScannerFABState();
}

class _QRScannerFABState extends State<_QRScannerFAB>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = 1.0 + (_pulseController.value * 0.06);
            return Transform.scale(
              scale: _hovered ? 1.1 : scale,
              child: child,
            );
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _hovered
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child:
                const Icon(LucideIcons.scanLine, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}
