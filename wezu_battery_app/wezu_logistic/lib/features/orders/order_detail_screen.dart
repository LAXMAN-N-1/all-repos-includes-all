import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_spacing.dart';
import '../../config/app_text_styles.dart';
import '../../models/order_model.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/app_scaffold.dart';
import 'providers/orders_providers.dart';
import '../fleet/providers/logistics_providers.dart';
import '../../models/driver_model.dart';
import '../fleet/widgets/driver_status_chip.dart';
import 'proof_of_delivery_screen.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(orderDetailProvider(orderId)),
          ),
        ],
      ),
      body: orderAsync.when(
        initial: () => const SizedBox.shrink(),
        loaded: (order) => _buildContent(context, ref, order),
        loading: () => const AppLoader(),
        error: (message) => Center(child: Text('Error: $message')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, OrderModel order) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, order),
          AppSpacing.gapH24,
          _buildTimeline(context, order),
          AppSpacing.gapH24,
          // Track Live button for in_transit orders
          if (order.status == OrderStatus.inTransit &&
              order.assignedDriverId != null) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.location_on_rounded),
                label: const Text('Track Live'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.info),
                onPressed: () => context.pushNamed(
                  'orderTracking',
                  pathParameters: {'orderId': order.id},
                  extra: order,
                ),
              ),
            ),
            AppSpacing.gapH16,
          ],
          if (order.status == OrderStatus.failed)
            _buildFailureCard(context, order),
          if (order.status == OrderStatus.delivered && order.hasPodDisplayData)
            _buildPodCard(context, order),
          if (order.type == 'return') ...[
            AppSpacing.gapH24,
            _buildReturnManagementCard(context, ref, order),
          ],
          if (_canTakeAction(order.status) ||
              (order.status == OrderStatus.delivered &&
                  order.type == 'delivery')) ...[
            _buildActionButtons(context, ref, order),
            AppSpacing.gapH24,
          ],
        ],
      ),
    );
  }

  bool _canTakeAction(OrderStatus status) =>
      status == OrderStatus.pending || status == OrderStatus.inTransit;

  Widget _buildHeader(BuildContext context, OrderModel order) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        order.id,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (order.type == 'return') ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'RETURN',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusChip(context, order.status),
            ],
          ),
          AppSpacing.gapH4,
          Text(
            'Created on ${_formatDate(order.orderDate)}',
            style: AppTextStyles.caption.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Divider(height: 32),
          if (order.originalOrderId != null) ...[
            _buildInfoRow(context, 'Original Order', order.originalOrderId!),
            AppSpacing.gapH12,
          ],
          _buildInfoRow(context, 'Customer', order.customerName),
          AppSpacing.gapH12,
          _buildInfoRow(context, 'Destination', order.destination ?? 'N/A'),
          AppSpacing.gapH12,
          _buildInfoRow(context, 'Units', '${order.units} batteries'),
          AppSpacing.gapH12,
          _buildInfoRow(context, 'Priority', order.priority.label),
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            AppSpacing.gapH12,
            _buildInfoRow(context, 'Notes', order.notes!),
          ],
          if (order.assignedDriverName != null ||
              order.assignedDriverId != null) ...[
            AppSpacing.gapH12,
            _buildInfoRow(
              context,
              'Driver',
              order.assignedDriverName ?? order.assignedDriverId ?? 'N/A',
            ),
            if (order.assignedDriverName != null &&
                order.assignedDriverId != null) ...[
              AppSpacing.gapH12,
              _buildInfoRow(context, 'Driver ID', order.assignedDriverId!),
            ],
          ],
          if (order.dispatchDate != null) ...[
            AppSpacing.gapH12,
            _buildInfoRow(
              context,
              'Dispatched',
              _formatDate(order.dispatchDate!),
            ),
          ],
          if (order.deliveredAt != null) ...[
            AppSpacing.gapH12,
            _buildInfoRow(
              context,
              'Delivered',
              _formatDate(order.deliveredAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerManagementCard(
    BuildContext context,
    WidgetRef ref,
    OrderModel order,
  ) {
    // Determine status text/color for confirmation
    String confirmStatus = 'Not Confirmed';
    Color confirmColor = AppColors.textSecondary;
    IconData confirmIcon = Icons.help_outline;

    if (order.isConfirmed) {
      confirmStatus = 'Confirmed';
      confirmColor = AppColors.success;
      confirmIcon = Icons.check_circle_outline;
    } else if (order.confirmationSentAt != null) {
      confirmStatus = 'Request Sent';
      confirmColor = AppColors.warning;
      confirmIcon = Icons.access_time;
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_outline, color: AppColors.primary),
              AppSpacing.gapW8,
              Text(
                'Customer Communication',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const Divider(height: 24),

          // Slot
          Row(
            children: [
              const Icon(
                Icons.calendar_month,
                size: 20,
                color: AppColors.textSecondary,
              ),
              AppSpacing.gapW8,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Scheduled Slot', style: AppTextStyles.caption),
                    if (order.scheduledSlotStart != null)
                      Text(
                        '${_formatDate(order.scheduledSlotStart!)} - ${_formatTime(order.scheduledSlotEnd!)}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Text(
                        'Not scheduled',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _scheduleDelivery(context, ref, order),
                child: const Text('Reschedule'),
              ),
            ],
          ),

          AppSpacing.gapH16,

          // Confirmation Status
          Row(
            children: [
              Icon(confirmIcon, size: 20, color: confirmColor),
              AppSpacing.gapW8,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer Status', style: AppTextStyles.caption),
                    Text(
                      confirmStatus,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: confirmColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (!order.isConfirmed)
                TextButton(
                  onPressed: () => _requestConfirmation(context, ref, order),
                  child: Text(
                    order.confirmationSentAt != null ? 'Resend' : 'Request',
                  ),
                ),
            ],
          ),

          AppSpacing.gapH16,

          // Share Tracking
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.share_outlined),
              label: const Text('Share Tracking Link'),
              onPressed: () => _shareTracking(context, order),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildStatusChip(BuildContext context, OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.pending:
        color = AppColors.warning;
        break;
      case OrderStatus.inTransit:
        color = AppColors.info;
        break;
      case OrderStatus.delivered:
        color = AppColors.success;
        break;
      case OrderStatus.failed:
        color = AppColors.error;
        break;
      case OrderStatus.cancelled:
        color = AppColors.textSecondary;
        break;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(BuildContext context, OrderModel order) {
    final colorScheme = Theme.of(context).colorScheme;

    // FR-LOGISTICS-001: Pending → In Transit → Delivered | Failed
    final steps = [
      {
        'status': OrderStatus.pending,
        'label': 'Order Placed',
        'icon': Icons.receipt_long_outlined,
      },
      {
        'status': OrderStatus.inTransit,
        'label': 'In Transit',
        'icon': Icons.local_shipping_outlined,
      },
      {
        'status': OrderStatus.delivered,
        'label': 'Delivered',
        'icon': Icons.check_circle_outline,
      },
    ];

    final isFailed = order.status == OrderStatus.failed;
    final isCancelled = order.status == OrderStatus.cancelled;

    int currentStep = steps.indexWhere((s) => s['status'] == order.status);
    if (isFailed || isCancelled) currentStep = -1;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tracking', style: Theme.of(context).textTheme.titleMedium),
          AppSpacing.gapH24,
          if (isFailed)
            Row(
              children: [
                const Icon(Icons.cancel_outlined, color: AppColors.error),
                AppSpacing.gapW8,
                const Text(
                  'Delivery Failed',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          else if (isCancelled)
            Row(
              children: [
                const Icon(
                  Icons.block_outlined,
                  color: AppColors.textSecondary,
                ),
                AppSpacing.gapW8,
                const Text(
                  'Order Cancelled',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final isCompleted = index <= currentStep;
                final isCurrent = index == currentStep;
                final isLast = index == steps.length - 1;
                final color = isCompleted
                    ? AppColors.success
                    : colorScheme.outlineVariant;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppColors.success.withValues(alpha: 0.15)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: color,
                              width: isCurrent ? 2.5 : 1.5,
                            ),
                          ),
                          child: Icon(
                            isCompleted
                                ? Icons.check
                                : (steps[index]['icon'] as IconData),
                            color: color,
                            size: 14,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 32,
                            color: color.withValues(alpha: 0.5),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                          ),
                      ],
                    ),
                    AppSpacing.gapW16,
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        steps[index]['label'] as String,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isCompleted
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                          fontWeight: isCompleted
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFailureCard(BuildContext context, OrderModel order) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 20,
                ),
                AppSpacing.gapW8,
                Text(
                  'Failure Reason',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            AppSpacing.gapH8,
            Text(
              order.failureReason ?? 'No reason provided',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodCard(BuildContext context, OrderModel order) {
    final podRecipientName = order.podRecipientName;
    final podImageUrl = order.podImageUrl;
    final podSignatureUrl = order.podSignatureUrl;
    final podNotes = order.podNotes;
    final podCapturedAt = order.podCapturedAt;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.verified_outlined,
                  color: AppColors.success,
                  size: 20,
                ),
                AppSpacing.gapW8,
                Text(
                  'Proof of Delivery',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            AppSpacing.gapH16,

            // Recipient Details
            if (podRecipientName != null) ...[
              Text(
                'Received by',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textHint,
                ),
              ),
              AppSpacing.gapH4,
              Text(
                podRecipientName,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.gapH16,
            ],

            // Photo & Signature Row
            if (podImageUrl != null || podSignatureUrl != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery Photo
                  if (podImageUrl != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Photo', style: AppTextStyles.labelMedium),
                          AppSpacing.gapH8,
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              podImageUrl,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 150,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (podImageUrl != null && podSignatureUrl != null)
                    AppSpacing.gapW12,

                  // Signature
                  if (podSignatureUrl != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Signature', style: AppTextStyles.labelMedium),
                          AppSpacing.gapH8,
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                podSignatureUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.draw, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

            if (podNotes != null) ...[
              AppSpacing.gapH16,
              Text('Notes', style: AppTextStyles.labelMedium),
              AppSpacing.gapH4,
              Text(podNotes, style: AppTextStyles.bodyMedium),
            ],

            if (podCapturedAt != null) ...[
              AppSpacing.gapH16,
              const Divider(),
              AppSpacing.gapH8,
              Text(
                'Captured at ${_formatDate(podCapturedAt)}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    OrderModel order,
  ) {
    return Column(
      children: [
        // Assign Driver (pending only)
        if (order.status == OrderStatus.pending) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _showAssignDriverSheet(context, ref, order),
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Assign Driver'),
            ),
          ),
          AppSpacing.gapH12,
        ],

        // Mark In Transit (pending only)
        if (order.status == OrderStatus.pending) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.info),
              onPressed: () async {
                final confirm = await _showConfirmDialog(
                  context,
                  title: 'Mark In Transit?',
                  message:
                      'This will dispatch the order and notify the driver.',
                  confirmLabel: 'Dispatch',
                  confirmColor: AppColors.info,
                );
                if (confirm == true) {
                  final result = await ref
                      .read(orderDetailProvider(order.id).notifier)
                      .markInTransit();
                  if (!context.mounted) return;
                  if (result.isSuccess) {
                    ref.invalidate(orderDetailProvider(order.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order marked as In Transit'),
                        backgroundColor: AppColors.info,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result.error ?? 'Failed to mark in transit',
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.local_shipping_outlined),
              label: const Text('Mark In Transit'),
            ),
          ),
          AppSpacing.gapH12,
        ],

        // Capture Proof of Delivery (in_transit only)
        if (order.status == OrderStatus.inTransit) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.success),
              onPressed: () async {
                final result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => ProofOfDeliveryScreen(orderId: order.id),
                  ),
                );
                if (result == true) {
                  ref.invalidate(orderDetailProvider(order.id));
                }
              },
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Capture Proof of Delivery'),
            ),
          ),
          AppSpacing.gapH12,
        ],

        // Mark Failed (in_transit only)
        if (order.status == OrderStatus.inTransit) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
              ),
              onPressed: () => _showMarkFailedDialog(context, ref, order),
              icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
              label: const Text(
                'Mark Failed',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ),
          AppSpacing.gapH12,
        ],

        // Cancel Order (pending only)
        if (order.status == OrderStatus.pending)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirm = await _showConfirmDialog(
                  context,
                  title: 'Cancel Order?',
                  message: 'Are you sure you want to cancel this order?',
                  confirmLabel: 'Cancel Order',
                  confirmColor: AppColors.error,
                );
                if (confirm == true) {
                  await ref
                      .read(ordersListProvider.notifier)
                      .cancelOrder(order.id);
                  ref.invalidate(orderDetailProvider(order.id));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order Cancelled')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.block_outlined, color: AppColors.error),
              label: const Text(
                'Cancel Order',
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),

        // Initiate Return (delivered only)
        if (order.status == OrderStatus.delivered &&
            order.type == 'delivery') ...[
          AppSpacing.gapH12,
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _initiateReturn(context, ref, order),
              icon: const Icon(Icons.assignment_return_outlined),
              label: const Text('Initiate Return'),
            ),
          ),
        ],
      ],
    );
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel, style: TextStyle(color: confirmColor)),
          ),
        ],
      ),
    );
  }

  void _showMarkFailedDialog(
    BuildContext context,
    WidgetRef ref,
    OrderModel order,
  ) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Failed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for the delivery failure:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g., Customer not available, wrong address...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) return;
              Navigator.pop(context);
              final result = await ref
                  .read(orderDetailProvider(order.id).notifier)
                  .markFailed(reason);
              if (!context.mounted) return;
              if (result.isSuccess) {
                ref.invalidate(orderDetailProvider(order.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order marked as Failed'),
                    backgroundColor: AppColors.error,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.error ?? 'Failed to mark as failed'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text(
              'Confirm',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignDriverSheet(
    BuildContext context,
    WidgetRef ref,
    OrderModel order,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _DriverSelectionSheet(orderId: order.id),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _scheduleDelivery(
    BuildContext context,
    WidgetRef ref,
    OrderModel order,
  ) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: order.scheduledSlotStart ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );

    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          order.scheduledSlotStart ??
              DateTime(now.year, now.month, now.day, 9, 0),
        ),
      );

      if (time != null) {
        final start = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        final end = start.add(const Duration(hours: 2));

        final repo = ref.read(ordersRepositoryProvider);
        final result = await repo.scheduleOrder(order.id, start, end);

        if (result.isSuccess) {
          ref.invalidate(orderDetailProvider(order.id));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Delivery scheduled successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to schedule: ${result.error}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _requestConfirmation(
    BuildContext context,
    WidgetRef ref,
    OrderModel order,
  ) async {
    final repo = ref.read(ordersRepositoryProvider);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Sending request...')),
    );

    final result = await repo.requestConfirmation(order.id);

    if (result.isSuccess) {
      ref.invalidate(orderDetailProvider(order.id));
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Confirmation request sent via SMS'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed: ${result.error}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _shareTracking(BuildContext context, OrderModel order) async {
    final link = "https://wezu.app/track/${order.id}";
    final text = "Track your Wezu delivery here: $link";

    await Share.share(text, subject: 'Wezu Delivery Update');
  }

  Widget _buildReturnManagementCard(
    BuildContext context,
    WidgetRef ref,
    OrderModel order,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assignment_return_outlined,
                color: AppColors.primary,
              ),
              AppSpacing.gapW8,
              Text(
                'Return Management',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow(context, 'Return Status', order.status.label),
          AppSpacing.gapH12,
          _buildInfoRow(
            context,
            'Refund Status',
            order.refundStatus.toUpperCase(),
          ),
          if (order.refundStatus == 'pending') ...[
            AppSpacing.gapH16,
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _processRefund(context, ref, order),
                icon: const Icon(Icons.currency_exchange),
                label: const Text('Process Refund'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.warning,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _initiateReturn(
    BuildContext context,
    WidgetRef ref,
    OrderModel order,
  ) async {
    final reasonController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Initiate Return'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reason for return:'),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(hintText: 'e.g. Damaged item'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm == true &&
        reasonController.text.isNotEmpty &&
        context.mounted) {
      final repo = ref.read(ordersRepositoryProvider);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final result = await repo.initiateReturn(order.id, reasonController.text);

      if (result.isSuccess) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Return initiated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Failed: ${result.error}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _processRefund(
    BuildContext context,
    WidgetRef ref,
    OrderModel order,
  ) async {
    final confirm = await _showConfirmDialog(
      context,
      title: 'Process Refund?',
      message: 'This will mark the refund as processed.',
      confirmLabel: 'Process',
      confirmColor: AppColors.warning,
    );

    if (confirm == true && context.mounted) {
      final repo = ref.read(ordersRepositoryProvider);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final result = await repo.processRefund(order.id);

      if (result.isSuccess) {
        ref.invalidate(orderDetailProvider(order.id));
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Refund processed'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Failed: ${result.error}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

// ─── Driver Selection Sheet ──────────────────────────────────────────

class _DriverSelectionSheet extends ConsumerWidget {
  final String orderId;

  const _DriverSelectionSheet({required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fleetAsync = ref.watch(availableDriversProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  'Select Driver',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () => ref.refresh(availableDriversProvider),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: fleetAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text('Failed to load drivers: $e'),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => ref.refresh(availableDriversProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (available) {
                if (available.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 40,
                          color: AppColors.textHint,
                        ),
                        SizedBox(height: 8),
                        Text('No available drivers'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: available.length,
                  itemBuilder: (context, index) {
                    final driver = available[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        child: Text(
                          driver.name[0],
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      title: Text(driver.name, style: AppTextStyles.bodyLarge),
                      subtitle: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          DriverStatusChip(status: driver.status),
                          Text(
                            '${driver.vehicleType} (${driver.completedDeliveries} del.)',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _assignDriver(context, ref, driver),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _assignDriver(
    BuildContext context,
    WidgetRef ref,
    DriverModel driver,
  ) async {
    final notifier = ref.read(orderDetailProvider(orderId).notifier);
    final listNotifier = ref.read(ordersListProvider.notifier);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    Navigator.of(context).pop();

    final result = await notifier.assignDriver(
      driver.id,
      driverName: driver.name,
    );
    if (result.isSuccess) {
      final updatedOrder = result.dataOrNull;
      if (updatedOrder != null) {
        listNotifier.applyOrderUpdate(updatedOrder);
      }
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Assigned ${driver.name} to order'),
          backgroundColor: AppColors.success,
        ),
      );
      return;
    }

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(result.error ?? 'Failed to assign driver'),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
