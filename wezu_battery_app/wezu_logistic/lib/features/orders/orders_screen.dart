import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_animations.dart';
import '../../config/app_navigator.dart';
import '../../config/app_colors.dart';
import '../../config/app_spacing.dart';
import '../../models/order_model.dart';
import '../../utils/app_haptics.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/scroll_morph_fab.dart';
import 'providers/orders_providers.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/widgets.dart';

/// Orders screen — reactively wired to paginated order list and filters.
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final _scrollController = ScrollController();
  final ValueNotifier<double> _fabCollapseProgress = ValueNotifier<double>(0);
  double _lastScrollOffset = 0;
  static const double _collapseTravel = 92;
  static const double _minScrollDelta = 0.2;

  void _setFabProgress(double value) {
    final clamped = value.clamp(0.0, 1.0);
    final snapped = clamped <= 0.02 ? 0.0 : (clamped >= 0.98 ? 1.0 : clamped);
    if ((_fabCollapseProgress.value - snapped).abs() > 0.0001) {
      _fabCollapseProgress.value = snapped;
    }
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) {
        return;
      }

      final offset = _scrollController.position.pixels.clamp(
        0.0,
        double.infinity,
      );
      final delta = offset - _lastScrollOffset;
      _lastScrollOffset = offset;

      if (offset <= 0) {
        _setFabProgress(0);
      } else if (delta.abs() >= _minScrollDelta) {
        final next = _fabCollapseProgress.value + (delta / _collapseTravel);
        _setFabProgress(next);
      }

      // Trigger prefetch when user gets close to the end.
      if (_scrollController.position.extentAfter <= 400) {
        final notifier = ref.read(ordersListProvider.notifier);
        if (!notifier.isFetching && notifier.hasMore) {
          notifier.loadMore();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabCollapseProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(ordersListProvider);
    final currentTab = ref.watch(ordersTabProvider);

    return DefaultTabController(
      length: 2,
      initialIndex: currentTab,
      child: AppScaffold(
        useSafeArea: false,
        body: RefreshIndicator(
          onRefresh: _refreshOrders,
          color: Theme.of(context).colorScheme.primary,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar.large(title: const Text('Orders'), pinned: true),
              SliverToBoxAdapter(
                child: TabBar(
                  onTap: (index) {
                    AppHaptics.selection();
                    ref.read(ordersTabProvider.notifier).state = index;
                  },
                  tabs: const [
                    Tab(text: 'Active'),
                    Tab(text: 'History'),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.screenPadding.copyWith(top: 16),
                  child: AppSearchBar(
                    hintText: 'Search by ID, customer, destination, tracking…',
                    onChanged: (query) {
                      ref.read(ordersListProvider.notifier).search(query);
                    },
                  ),
                ),
              ),
              listState.when(
                initial: () =>
                    const SliverToBoxAdapter(child: SizedBox.shrink()),
                loading: () => _buildShimmerSliverList(),
                loaded: (orders) => _buildOrderSliverList(orders, context),
                error: (message) => _buildErrorSliver(message),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
        floatingActionButton: ValueListenableBuilder<double>(
          valueListenable: _fabCollapseProgress,
          builder: (context, progress, _) => ScrollMorphFab(
            progress: progress,
            onPressed: () {
              AppHaptics.impact();
              AppNavigator.toCreateOrder(context);
            },
            icon: const Icon(Icons.add_rounded),
            label: 'New Order',
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  List<OrderStatus> _statusesForTab(int tabIndex) {
    return tabIndex == 0
        ? [OrderStatus.pending, OrderStatus.inTransit]
        : [OrderStatus.delivered, OrderStatus.failed, OrderStatus.cancelled];
  }

  Future<void> _refreshOrders() {
    final tabIndex = ref.read(ordersTabProvider);
    return ref
        .read(ordersListProvider.notifier)
        .loadOrders(
          statuses: _statusesForTab(tabIndex),
          sortBy: ref.read(ordersSortProvider),
          sortOrder: ref.read(ordersSortOrderProvider),
        );
  }

  Widget _buildOrderSliverList(List<OrderModel> orders, BuildContext context) {
    final notifier = ref.watch(ordersListProvider.notifier);
    final hasMore = notifier.hasMore;
    final isFetching = notifier.isFetching;

    if (orders.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: AppEmptyState(
          message: 'No orders found',
          icon: Icons.receipt_long_outlined,
          actionLabel: 'Create Order',
          onAction: () => AppNavigator.toCreateOrder(context),
        ),
      );
    }

    return SliverPadding(
      padding: AppSpacing.screenPadding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == orders.length) {
            if (!isFetching && hasMore) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final nextNotifier = ref.read(ordersListProvider.notifier);
                if (!nextNotifier.isFetching && nextNotifier.hasMore) {
                  nextNotifier.loadMore();
                }
              });
            }
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OrderListItem(order: orders[index]).listItem(index: index),
          );
        }, childCount: orders.length + (hasMore ? 1 : 0)),
      ),
    );
  }

  Widget _buildShimmerSliverList() {
    return SliverPadding(
      padding: AppSpacing.screenPadding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppShimmer(width: double.infinity, height: 100),
          ),
          childCount: 5,
        ),
      ),
    );
  }

  Widget _buildErrorSliver(String message) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: AppErrorState(message: message, onRetry: _refreshOrders),
    );
  }
}

// ─── Sub-widgets ────────────────────────────────────────────────────

class _OrderListItem extends StatelessWidget {
  const _OrderListItem({required this.order});

  final OrderModel order;

  Color _getStatusColor(BuildContext context) {
    switch (order.status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.inTransit:
        return AppColors.info;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.failed:
        return AppColors.error;
      case OrderStatus.cancelled:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusBgColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = _getStatusColor(context);
    return baseColor.withValues(alpha: isDark ? 0.2 : 0.15);
  }

  Color _getPriorityColor() {
    switch (order.priority) {
      case OrderPriority.urgent:
        return AppColors.error;
      case OrderPriority.normal:
        return AppColors.info;
      case OrderPriority.low:
        return AppColors.textSecondary;
    }
  }

  IconData _getPriorityIcon() {
    switch (order.priority) {
      case OrderPriority.urgent:
        return Icons.priority_high_rounded;
      case OrderPriority.normal:
        return Icons.remove_rounded;
      case OrderPriority.low:
        return Icons.keyboard_arrow_down_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = _getStatusColor(context);
    final statusBgColor = _getStatusBgColor(context);
    final priorityColor = _getPriorityColor();

    return AppCard(
      onTap: () => AppNavigator.toOrderDetail(context, orderId: order.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Priority + ID + Status ──
          Row(
            children: [
              // Priority indicator
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getPriorityIcon(), size: 16, color: priorityColor),
              ),
              AppSpacing.gapW8,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.id,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      order.customerName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AppSpacing.gapW8,
              AppStatusBadge(label: order.status.label, color: statusColor),
            ],
          ),
          AppSpacing.gapH12,

          // ── Row 2: Units, Value, Date ──
          Row(
            children: [
              AppIconText(
                icon: Icons.inventory_2_outlined,
                label: '${order.units} units',
              ),
              AppSpacing.gapW12,
              AppIconText(
                icon: Icons.currency_rupee,
                label: _formatCurrency(order.totalValue),
              ),
              AppSpacing.gapW12,
              AppIconText(
                icon: Icons.calendar_today_outlined,
                label: _formatDate(order.orderDate),
              ),
            ],
          ),

          AppSpacing.gapH8,

          // ── Row 3: Destination + Tracking/Battery count ──
          Row(
            children: [
              if (order.destination != null)
                Expanded(
                  child: AppIconText(
                    icon: Icons.place_outlined,
                    label: order.destination!,
                  ),
                ),
              if (order.hasTracking) ...[
                AppSpacing.gapW8,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 12,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        order.trackingNumber!,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (order.hasBatteriesAssigned) ...[
                AppSpacing.gapW8,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.battery_std,
                        size: 12,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${order.assignedBatteryIds.length} assigned',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          AppSpacing.gapH8,

          // ── Progress bar ──
          if (order.status != OrderStatus.delivered &&
              order.status != OrderStatus.cancelled)
            _AnimatedProgressBar(
              progress: order.status.progress,
              color: statusColor,
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatCurrency(double value) {
    if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(0)}K';
    }
    return '₹${value.toStringAsFixed(0)}';
  }
}

class _AnimatedProgressBar extends StatefulWidget {
  const _AnimatedProgressBar({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  State<_AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<_AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.slow + const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.entranceCurve),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(_AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(begin: _animation.value, end: widget.progress)
          .animate(
            CurvedAnimation(
              parent: _controller,
              curve: AppAnimations.defaultCurve,
            ),
          );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _animation.value,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(widget.color),
            minHeight: 4,
          ),
        );
      },
    );
  }
}
