import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../config/app_spacing.dart';
import '../../models/transfer_model.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/app_scaffold.dart';
import 'providers/inventory_providers.dart';

final transferHistoryProvider = FutureProvider.autoDispose<List<TransferModel>>(
  (ref) async {
    final repo = ref.watch(inventoryRepositoryProvider);
    final result = await repo.fetchTransfers();
    if (result.isFailure) {
      throw Exception(result.error ?? 'Failed to load transfer history');
    }
    return result.dataOrNull ?? [];
  },
);

class TransferHistoryScreen extends ConsumerWidget {
  const TransferHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(transferHistoryProvider);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Transfer History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(transferHistoryProvider),
          ),
        ],
      ),
      body: historyAsync.when(
        data: (transfers) => transfers.isEmpty
            ? const Center(child: Text('No transfers found'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: transfers.length,
                separatorBuilder: (_, __) => AppSpacing.gapH16,
                itemBuilder: (context, index) =>
                    _TransferCard(transfer: transfers[index]),
              ),
        loading: () => const AppLoader(),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _TransferCard extends ConsumerStatefulWidget {
  final TransferModel transfer;

  const _TransferCard({required this.transfer});

  @override
  ConsumerState<_TransferCard> createState() => _TransferCardState();
}

class _TransferCardState extends ConsumerState<_TransferCard> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final transfer = widget.transfer;
    final dateStr = DateFormat('MMM dd, yyyy HH:mm').format(transfer.createdAt);

    Color statusColor;
    switch (transfer.status) {
      case TransferStatus.pending:
        statusColor = AppColors.warning;
        break;
      case TransferStatus.inTransit:
        statusColor = AppColors.info;
        break;
      case TransferStatus.completed:
        statusColor = AppColors.success;
        break;
      case TransferStatus.cancelled:
        statusColor = AppColors.textSecondary;
        break;
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Transfer #${transfer.id}',
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text(
                  transfer.status.label,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: statusColor.withValues(alpha: 0.1),
                labelStyle: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          AppSpacing.gapH8,
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warehouse,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'From: ${transfer.fromLocationType} #${transfer.fromLocationId}',
                  ),
                ],
              ),
              const Icon(
                Icons.arrow_forward,
                size: 16,
                color: AppColors.textSecondary,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.store,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'To: ${transfer.toLocationType} #${transfer.toLocationId}',
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.gapH8,
          Text(
            '${transfer.items.length} Items',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          AppSpacing.gapH4,
          Text(
            dateStr,
            style: const TextStyle(color: AppColors.textHint, fontSize: 12),
          ),

          if (transfer.status == TransferStatus.inTransit) ...[
            const Divider(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isProcessing
                    ? null
                    : () => _receiveTransfer(context, transfer.id),
                icon: const Icon(Icons.download),
                label: const Text('Receive Stock'),
              ),
            ),
          ],
          if (transfer.status == TransferStatus.pending ||
              transfer.status == TransferStatus.inTransit) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isProcessing
                    ? null
                    : () => _cancelTransfer(context, transfer.id),
                icon: const Icon(Icons.close),
                label: const Text('Cancel Transfer'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _receiveTransfer(BuildContext context, int id) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final repo = ref.read(inventoryRepositoryProvider);
      final result = await repo.receiveTransfer(id);
      result.when(
        success: (_) {
          ref.invalidate(transferHistoryProvider);
          unawaited(
            ref
                .read(transferLocationBatteriesProvider.notifier)
                .safetyRefetchAfterTransferLifecycle(
                  sourceLocation: InventoryLocationRef(
                    locationType: widget.transfer.fromLocationType,
                    locationId: widget.transfer.fromLocationId,
                  ),
                  destinationLocation: InventoryLocationRef(
                    locationType: widget.transfer.toLocationType,
                    locationId: widget.transfer.toLocationId,
                  ),
                ),
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Stock received successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        failure: (message, _) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed: $message'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _cancelTransfer(BuildContext context, int id) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final repo = ref.read(inventoryRepositoryProvider);
      final result = await repo.cancelTransfer(id);
      result.when(
        success: (_) {
          ref.invalidate(transferHistoryProvider);
          unawaited(
            ref
                .read(transferLocationBatteriesProvider.notifier)
                .safetyRefetchAfterTransferLifecycle(
                  sourceLocation: InventoryLocationRef(
                    locationType: widget.transfer.fromLocationType,
                    locationId: widget.transfer.fromLocationId,
                  ),
                  destinationLocation: InventoryLocationRef(
                    locationType: widget.transfer.toLocationType,
                    locationId: widget.transfer.toLocationId,
                  ),
                ),
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transfer cancelled successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        failure: (message, _) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed: $message'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
