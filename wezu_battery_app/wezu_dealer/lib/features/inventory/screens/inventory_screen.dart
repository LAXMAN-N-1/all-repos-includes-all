import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                              onRequestStock: () => _showRequestStockModal(context),
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
                onMoveMaintenance: () => _showBulkMaintenanceDialog(context, selectedIds),
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
          ((_pageLoadController.value - begin) / (end - begin))
              .clamp(0.0, 1.0),
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
          Text('Move to Maintenance', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        ]),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${selectedIds.length} batteries will be moved to maintenance',
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
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
                    backgroundColor: success ? AppColors.primary : AppColors.red,
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

  void _showRequestStockModal(BuildContext context) {
    int quantity = 10;
    String priority = 'normal';
    String? notes;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            backgroundColor: AppColors.cardBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(children: [
              Icon(LucideIcons.packagePlus, color: AppColors.primary, size: 20),
              SizedBox(width: 10),
              Text('Request Stock', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
            ]),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Submit a replenishment request to the platform admin.',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  // Quantity
                  TextField(
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      labelStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                      filled: true, fillColor: AppColors.pageBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                    ),
                    onChanged: (v) => quantity = int.tryParse(v) ?? 10,
                  ),
                  const SizedBox(height: 12),
                  // Priority
                  DropdownButtonFormField<String>(
                    initialValue: priority,
                    dropdownColor: AppColors.cardBg,
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      labelStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                      filled: true, fillColor: AppColors.pageBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('Low', style: TextStyle(color: AppColors.textPrimary, fontSize: 13))),
                      DropdownMenuItem(value: 'normal', child: Text('Normal', style: TextStyle(color: AppColors.textPrimary, fontSize: 13))),
                      DropdownMenuItem(value: 'high', child: Text('High', style: TextStyle(color: AppColors.textPrimary, fontSize: 13))),
                      DropdownMenuItem(value: 'urgent', child: Text('Urgent', style: TextStyle(color: AppColors.textPrimary, fontSize: 13))),
                    ],
                    onChanged: (v) => setDialogState(() => priority = v ?? 'normal'),
                  ),
                  const SizedBox(height: 12),
                  // Notes
                  TextField(
                    maxLines: 2,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Notes (optional)',
                      labelStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                      filled: true, fillColor: AppColors.pageBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                    ),
                    onChanged: (v) => notes = v.isEmpty ? null : v,
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
                      .requestStock(
                        quantity: quantity,
                        priority: priority,
                        notes: notes,
                        reason: 'Manual stock request from dealer portal',
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Stock request for $quantity batteries submitted'
                              : 'Failed to submit stock request',
                        ),
                        backgroundColor: success ? AppColors.primary : AppColors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Submit Request', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
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
              color: _hovered ? AppColors.primary : AppColors.primary.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(LucideIcons.scanLine, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}
