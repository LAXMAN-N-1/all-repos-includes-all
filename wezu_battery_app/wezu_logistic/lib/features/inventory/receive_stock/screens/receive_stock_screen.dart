import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/manifest_model.dart';
import '../../../../config/app_colors.dart';
import '../../../../utils/app_haptics.dart';
import '../../../../config/app_spacing.dart';
import '../../../../widgets/app_scaffold.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/app_button.dart';
import '../../../../widgets/app_loader.dart';
import '../../providers/warehouse_providers.dart';
import '../../widgets/warehouse_grid_view.dart';
import '../providers/receive_stock_provider.dart';
import 'scanner_view.dart';
import '../widgets/receive_stock_dialogs.dart';
import 'stock_receipt_screen.dart';

class ReceiveStockScreen extends ConsumerStatefulWidget {
  final String? manifestId;

  const ReceiveStockScreen({super.key, this.manifestId});

  @override
  ConsumerState<ReceiveStockScreen> createState() => _ReceiveStockScreenState();
}

class _ReceiveStockScreenState extends ConsumerState<ReceiveStockScreen> {
  @override
  void initState() {
    super.initState();
    // Only load if ID is provided and not already loaded (or if we want to force refresh)
    if (widget.manifestId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(receiveStockProvider.notifier)
            .loadManifest(widget.manifestId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(receiveStockProvider);
    final manifest = state.manifest;

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'Receive Stock',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          if (manifest != null)
            TextButton(
              onPressed:
                  state.isLoading ||
                      (state.availableWarehouses.length > 1 &&
                          state.selectedWarehouseId == null)
                  ? null
                  : () => _submit(),
              child: state.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: AppLoader(size: 16, strokeWidth: 2),
                    )
                  : const Text('Submit'),
            ),
        ],
      ),
      body: state.isLoading && manifest == null
          ? const Center(child: AppLoader())
          : state.error != null && manifest == null
          ? Center(child: Text('Error: ${state.error}'))
          : manifest == null
          ? _buildScanManifestState(context)
          : Column(
              children: [
                _buildProgressHeader(manifest),
                if (state.availableWarehouses.isNotEmpty)
                  _buildWarehouseSelector(state),
                Expanded(child: _buildManifestList(manifest)),
                _buildScannerButton(context, label: 'Scan Battery'),
              ],
            ),
    );
  }

  Widget _buildScanManifestState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            AppSpacing.gapH24,
            Text(
              'Scan Shipment Manifest',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapH8,
            Text(
              'Scan the QR code on the shipment manifest\nto start receiving stock.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            AppSpacing.gapH32,
            _buildScannerButton(context, label: 'Scan Manifest QR'),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    AppHaptics.impact();
    final result = await ref
        .read(receiveStockProvider.notifier)
        .submitManifest();
    if (!mounted) return;

    result.when(
      success: (updatedManifest) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StockReceiptScreen(manifest: updatedManifest),
          ),
        );
      },
      failure: (message, _) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Submit failed: $message')));
      },
    );
  }

  Widget _buildProgressHeader(ManifestModel manifest) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Manifest #${manifest.id}',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              AppSpacing.gapW8,
              Text(
                '${manifest.scannedCount} / ${manifest.totalItems} Scanned',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          AppSpacing.gapH8,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: manifest.progress,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.success,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseSelector(ReceiveStockState state) {
    final options = state.availableWarehouses;
    return Padding(
      padding: AppSpacing.screenPadding.copyWith(top: 12, bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<int>(
            initialValue: state.selectedWarehouseId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Receiving Warehouse',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.warehouse_outlined),
            ),
            items: options
                .map(
                  (warehouse) => DropdownMenuItem<int>(
                    value: warehouse.id,
                    child: Text(
                      '${warehouse.name} (Warehouse #${warehouse.id})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: state.isLoading
                ? null
                : (value) => ref
                      .read(receiveStockProvider.notifier)
                      .selectWarehouse(value),
          ),
          if (options.length > 1 && state.selectedWarehouseId == null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Please select a receiving warehouse before submitting.',
                style: TextStyle(color: AppColors.warning, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildManifestList(ManifestModel manifest) {
    return ListView.separated(
      padding: AppSpacing.screenPadding,
      itemCount: manifest.items.length,
      separatorBuilder: (context, index) => AppSpacing.gapH12,
      itemBuilder: (context, index) {
        final item = manifest.items[index];
        return AppCard(
          onTap: () => _showItemOptions(item),
          child: Row(
            children: [
              Icon(
                item.status == ManifestItemStatus.scanned
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                color: item.status == ManifestItemStatus.scanned
                    ? AppColors.success
                    : AppColors.textHint,
                size: 28,
              ),
              AppSpacing.gapW16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.batteryId,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      item.type,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (item.assignedLocation != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 12,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Loc: ${_formatAssignedLocation(item.assignedLocation!)}',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: AppColors.textHint),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (item.status != ManifestItemStatus.pending)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(item.status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.status.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _getStatusColor(item.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showItemOptions(ManifestItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSpacing.gapH8,
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AppSpacing.gapH24,
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Assign Location'),
              onTap: () {
                Navigator.pop(context);
                _showLocationAssignmentPicker(item);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.report_problem_outlined,
                color: AppColors.warning,
              ),
              title: const Text('Report Issue / Damage'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => DiscrepancyReportDialog(
                    batteryId: item.batteryId,
                    onReport: (report, imagePath) => ref
                        .read(receiveStockProvider.notifier)
                        .reportDamage(
                          item.batteryId,
                          report,
                          imagePath: imagePath,
                        ),
                  ),
                );
              },
            ),
            AppSpacing.gapH16,
          ],
        ),
      ),
    );
  }

  int? _resolveReceivingWarehouseId(ReceiveStockState state) {
    return state.selectedWarehouseId ??
        (state.availableWarehouses.length == 1
            ? state.availableWarehouses.first.id
            : null);
  }

  String _formatAssignedLocation(String rawLocation) {
    final location = rawLocation.trim();
    final shelfId = int.tryParse(location);
    if (shelfId != null && shelfId > 0) {
      return 'Shelf #$shelfId';
    }
    return location;
  }

  void _showLocationAssignmentPicker(ManifestItem item) {
    if (item.status == ManifestItemStatus.pending ||
        item.status == ManifestItemStatus.missing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Scan this battery first, then assign a shelf location.',
          ),
        ),
      );
      return;
    }

    final receiveStockState = ref.read(receiveStockProvider);
    final receivingWarehouseId = _resolveReceivingWarehouseId(
      receiveStockState,
    );
    if (receivingWarehouseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Select a receiving warehouse before assigning location.',
          ),
        ),
      );
      return;
    }

    ref
        .read(warehouseGraphProvider.notifier)
        .loadWarehouse(
          preferredWarehouseId: receivingWarehouseId,
          batterySerialHint: item.batteryId,
        );

    final parentContext = context;
    showDialog(
      context: parentContext,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(dialogContext).size.height * 0.82,
            maxWidth: 560,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Assign Shelf: ${item.batteryId}',
                        style: Theme.of(dialogContext).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) {
                    final warehouseState = ref.watch(warehouseGraphProvider);
                    return warehouseState.when(
                      initial: () => const Center(child: AppLoader()),
                      loading: () => const Center(child: AppLoader()),
                      loaded: (warehouse) => WarehouseGridView(
                        warehouse: warehouse,
                        onLocationSelected: (shelfId) {
                          ref
                              .read(receiveStockProvider.notifier)
                              .assignLocation(item.batteryId, shelfId);
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(parentContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${item.batteryId} assigned to shelf #$shelfId',
                              ),
                            ),
                          );
                        },
                      ),
                      error: (message) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('Failed to load warehouse map: $message'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannerButton(
    BuildContext context, {
    String label = 'Scan Battery',
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AppButton(
        label: label,
        icon: Icons.qr_code_scanner,
        onPressed: () async {
          final scannedCode = await Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (context) => const ScannerView()),
          );
          if (!context.mounted || scannedCode == null) return;

          // Handle scanned code (manifest or battery)
          await ref.read(receiveStockProvider.notifier).scanCode(scannedCode);
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Scanned: $scannedCode')));
        },
      ),
    );
  }

  Color _getStatusColor(ManifestItemStatus status) {
    switch (status) {
      case ManifestItemStatus.scanned:
        return AppColors.success;
      case ManifestItemStatus.missing:
        return AppColors.warning;
      case ManifestItemStatus.damaged:
        return AppColors.error;
      case ManifestItemStatus.extra:
        return AppColors.info;
      default:
        return AppColors.textHint;
    }
  }
}
