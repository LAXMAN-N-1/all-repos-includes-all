import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_animations.dart';
import '../../config/app_navigator.dart';
import '../../config/app_colors.dart';
import '../../config/app_spacing.dart';
import '../../config/app_text_styles.dart';
import '../../core/result.dart';
import '../../models/battery_model.dart';
import '../../utils/formatters.dart';
import '../../utils/app_haptics.dart';
import '../../widgets/app_scanner.dart';
import 'providers/inventory_providers.dart';
import 'repository/inventory_repository.dart';
import 'widgets/inventory_summary_cards.dart';
import 'widgets/battery_grid_item.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/scroll_morph_fab.dart';
import '../../widgets/widgets.dart';
import 'transfer_history_screen.dart';
import 'widgets/transfer_stock_dialog.dart';
import 'widgets/reconcile_stock_dialog.dart';
import 'utils/battery_status_style.dart';

/// Inventory screen — reactively bound to filter, search, and list providers.
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _scrollController = ScrollController();
  final ValueNotifier<double> _fabCollapseProgress = ValueNotifier<double>(0);
  TransferLocationData? _cachedTransferLocationData;
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
    Future.microtask(() {
      unawaited(ref.read(inventoryListProvider.notifier).loadBatteries());
      unawaited(_primeTransferLocationData());
    });

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

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final notifier = ref.read(inventoryListProvider.notifier);
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
    final listState = ref.watch(inventoryListProvider);
    final statsState = ref.watch(inventoryStatsProvider);
    final currentFilter = ref.watch(inventoryFilterProvider);
    final isListView = ref.watch(inventoryViewModeProvider);

    return AppScaffold(
      useSafeArea: false,
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: Theme.of(context).colorScheme.primary,
        child: CustomScrollView(
          // physics: const BouncingScrollPhysics(), // Removed to allow platform default
          controller: _scrollController,
          slivers: [
            SliverAppBar.large(
              title: const Text('Inventory'),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: Icon(
                    isListView
                        ? Icons.calendar_view_month_rounded
                        : Icons.view_list_rounded,
                  ),
                  onPressed: () {
                    AppHaptics.selection();
                    ref
                        .read(inventoryViewModeProvider.notifier)
                        .update((state) => !state);
                  },
                  tooltip: isListView
                      ? 'Switch to Grid View'
                      : 'Switch to List View',
                ),
                IconButton(
                  icon: const Icon(Icons.sort_rounded),
                  onPressed: () => _showSortSheet(context),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz_rounded),
                  tooltip: 'Transfer Stock',
                  onPressed: () => _showTransferDialog(context),
                ),
                IconButton(
                  icon: const Icon(Icons.history_rounded),
                  tooltip: 'Transfer History',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TransferHistoryScreen(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_box_rounded),
                  tooltip: 'Receive Stock',
                  onPressed: () => AppNavigator.toReceiveStock(context),
                ),
              ],
            ),

            // Inline search bar — debounced, filters as-you-type
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.screenPadding.copyWith(top: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: AppSearchBar(
                        hintText: 'Search by ID, serial, model…',
                        initialValue: ref.read(inventorySearchQueryProvider),
                        onChanged: (query) {
                          ref
                                  .read(inventorySearchQueryProvider.notifier)
                                  .state =
                              query;
                        },
                      ),
                    ),
                    AppSpacing.gapW12,
                    IconButton.filledTonal(
                      icon: const Icon(Icons.fact_check_outlined),
                      tooltip: 'Reconcile Stock',
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => const ReconcileStockDialog(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Summary Cards
            SliverToBoxAdapter(
              child: statsState.when(
                data: (stats) =>
                    InventorySummaryCards(stats: stats).sectionEntrance(),
                loading: () => _buildSummaryShimmer(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // Filter Chips
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _AnimatedFilterChip(
                      label: 'All Batteries',
                      isSelected: currentFilter == null,
                      onTap: () {
                        AppHaptics.tap();
                        ref.read(inventoryFilterProvider.notifier).state = null;
                      },
                    ),
                    const SizedBox(width: 8),
                    _AnimatedFilterChip(
                      label: 'Fully Charged',
                      isSelected: currentFilter == BatteryStatus.available,
                      onTap: () {
                        AppHaptics.tap();
                        ref.read(inventoryFilterProvider.notifier).state =
                            BatteryStatus.available;
                      },
                    ),
                    const SizedBox(width: 8),
                    _AnimatedFilterChip(
                      label: 'Charging',
                      isSelected: currentFilter == BatteryStatus.charging,
                      onTap: () {
                        AppHaptics.tap();
                        ref.read(inventoryFilterProvider.notifier).state =
                            BatteryStatus.charging;
                      },
                    ),
                    const SizedBox(width: 8),
                    _AnimatedFilterChip(
                      label: 'Deployed',
                      isSelected: currentFilter == BatteryStatus.deployed,
                      onTap: () {
                        AppHaptics.tap();
                        ref.read(inventoryFilterProvider.notifier).state =
                            BatteryStatus.deployed;
                      },
                    ),
                    const SizedBox(width: 8),
                    _AnimatedFilterChip(
                      label: 'Faulty/Maint.',
                      isSelected:
                          currentFilter == BatteryStatus.faulty ||
                          currentFilter == BatteryStatus.maintenance,
                      onTap: () {
                        AppHaptics.tap();
                        ref.read(inventoryFilterProvider.notifier).state =
                            BatteryStatus.faulty;
                      },
                    ),
                  ],
                ),
              ).sectionEntrance(delay: const Duration(milliseconds: 100)),
            ),

            // List or Grid Content
            isListView
                ? listState.when(
                    initial: () =>
                        const SliverToBoxAdapter(child: SizedBox.shrink()),
                    loading: () => _buildShimmerSliverList(),
                    loaded: (batteries) => batteries.isEmpty
                        ? const SliverToBoxAdapter(
                            child: AppEmptyState(
                              message: 'No batteries found',
                              icon: Icons.inventory_2_outlined,
                            ),
                          )
                        : _buildBatterySliverList(batteries, context),
                    error: (message) => SliverToBoxAdapter(
                      child: AppErrorState(
                        message: message,
                        onRetry: () => ref
                            .read(inventoryListProvider.notifier)
                            .loadBatteries(),
                      ),
                    ),
                  )
                : listState.when(
                    initial: () =>
                        const SliverToBoxAdapter(child: SizedBox.shrink()),
                    loading: () => _buildShimmerSliverGrid(),
                    loaded: (batteries) => batteries.isEmpty
                        ? const SliverToBoxAdapter(
                            child: AppEmptyState(
                              message: 'No batteries found',
                              icon: Icons.inventory_2_outlined,
                            ),
                          )
                        : _buildBatterySliverGrid(batteries, context),
                    error: (message) => SliverToBoxAdapter(
                      child: AppErrorState(
                        message: message,
                        onRetry: () => ref
                            .read(inventoryListProvider.notifier)
                            .loadBatteries(),
                      ),
                    ),
                  ),

            // Bottom Padding for FAB
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      floatingActionButton: ValueListenableBuilder<double>(
        valueListenable: _fabCollapseProgress,
        builder: (context, progress, _) => ScrollMorphFab(
          progress: progress,
          onPressed: _onScanPressed,
          icon: const Icon(Icons.qr_code_scanner),
          label: 'Scan',
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  void _onScanPressed() {
    AppHaptics.impact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppScanner(
          title: 'Scan Battery',
          subtitle: 'Align battery QR code within the frame',
          onScan: (code) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Scanned: $code')));
            ref.read(inventorySearchQueryProvider.notifier).state = code;
          },
        ),
      ),
    );
  }

  // ─── Actions ───────────────────────────────────────────────────────

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _SortBottomSheet(),
    );
  }

  Future<Result<TransferLocationData>> _fetchTransferLocationData({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = _cachedTransferLocationData;
      if (cached != null &&
          cached.warehouses.isNotEmpty &&
          cached.destinations.isNotEmpty) {
        return Result.success(cached);
      }
    }

    final repo = ref.read(inventoryRepositoryProvider);
    final result = await repo.fetchTransferLocationData();
    final data = result.dataOrNull;
    if (result.isSuccess && data != null) {
      _cachedTransferLocationData = data;
    }
    return result;
  }

  Future<void> _primeTransferLocationData() async {
    await _fetchTransferLocationData();
  }

  Future<void> _showTransferDialog(BuildContext context) async {
    final seededBatteries = (ref.read(inventoryListProvider).dataOrNull ?? [])
        .where((battery) {
          final isTransferableStatus =
              battery.status == BatteryStatus.available ||
              battery.status == BatteryStatus.newBattery;
          final locationType = (battery.location ?? '').trim().toLowerCase();
          final hasSupportedSource =
              locationType == 'warehouse' ||
              locationType == 'station' ||
              locationType == 'shelf';
          return isTransferableStatus &&
              hasSupportedSource &&
              battery.locationId != null;
        })
        .toList();

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _TransferStockDialogLoader(
        availableBatteries: seededBatteries,
        fetchLocations: ({bool forceRefresh = false}) =>
            _fetchTransferLocationData(forceRefresh: forceRefresh),
      ),
    );
    if (!context.mounted) return;

    if (result == true) {
      // Refresh inventory as items might have moved (though backend updates location)
      _refresh();
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(inventoryStatsProvider);
    await ref
        .read(inventoryListProvider.notifier)
        .loadBatteries(
          filter: ref.read(inventoryFilterProvider),
          searchQuery: ref.read(inventorySearchQueryProvider),
          sortBy: ref.read(inventorySortProvider),
          sortOrder: ref.read(inventorySortOrderProvider),
        );
  }

  // Refactor these to return Slivers
  Widget _buildBatterySliverList(
    List<BatteryModel> batteries,
    BuildContext context,
  ) {
    return SliverPadding(
      padding: AppSpacing.screenPadding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == batteries.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }

            final battery = batteries[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Dismissible(
                key: Key(battery.id),
                direction: DismissDirection.horizontal,
                background: _buildswipeActionLeft(),
                secondaryBackground: _buildSwipeActionRight(),
                confirmDismiss: (direction) async {
                  AppHaptics.heavy();
                  if (direction == DismissDirection.startToEnd) {
                    await ref
                        .read(inventoryListProvider.notifier)
                        .updateStatus(battery.id, BatteryStatus.faulty);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${battery.id} marked as Faulty'),
                        ),
                      );
                    }
                    return false;
                  } else {
                    await ref
                        .read(inventoryListProvider.notifier)
                        .updateStatus(battery.id, BatteryStatus.charging);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${battery.id} moved to Charging'),
                        ),
                      );
                    }
                    return false;
                  }
                },
                child: _BatteryListItem(
                  battery: battery,
                ).listItem(index: index),
              ),
            );
          },
          childCount:
              batteries.length +
              (ref.watch(inventoryListProvider.notifier).hasMore ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildBatterySliverGrid(
    List<BatteryModel> batteries,
    BuildContext context,
  ) {
    return SliverPadding(
      padding: AppSpacing.screenPadding,
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == batteries.length) {
              return const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            }
            return BatteryGridItem(
              battery: batteries[index],
              onTap: () => AppNavigator.toBatteryDetail(
                context,
                batteryId: batteries[index].id,
              ),
            ).listItem(index: index);
          },
          childCount:
              batteries.length +
              (ref.watch(inventoryListProvider.notifier).hasMore ? 1 : 0),
        ),
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
            child: AppShimmer(width: double.infinity, height: 72),
          ),
          childCount: 6,
        ),
      ),
    );
  }

  Widget _buildShimmerSliverGrid() {
    return SliverPadding(
      padding: AppSpacing.screenPadding,
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => AppShimmer(width: double.infinity, height: 180),
          childCount: 6,
        ),
      ),
    );
  }

  Widget _buildswipeActionLeft() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      color: AppColors.error,
      child: const Icon(Icons.report_problem_outlined, color: Colors.white),
    );
  }

  Widget _buildSwipeActionRight() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      color: AppColors.batteryFull,
      child: const Icon(Icons.bolt_rounded, color: Colors.white),
    );
  }

  Widget _buildSummaryShimmer() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: List.generate(
          4,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AppShimmer(width: 110, height: 100, borderRadius: 16),
          ),
        ),
      ),
    );
  }
}

typedef _TransferLocationFetcher =
    Future<Result<TransferLocationData>> Function({bool forceRefresh});

class _TransferStockDialogLoader extends StatefulWidget {
  const _TransferStockDialogLoader({
    required this.availableBatteries,
    required this.fetchLocations,
  });

  final List<BatteryModel> availableBatteries;
  final _TransferLocationFetcher fetchLocations;

  @override
  State<_TransferStockDialogLoader> createState() =>
      _TransferStockDialogLoaderState();
}

class _TransferStockDialogLoaderState
    extends State<_TransferStockDialogLoader> {
  late Future<Result<TransferLocationData>> _locationsFuture;

  @override
  void initState() {
    super.initState();
    _locationsFuture = widget.fetchLocations();
  }

  void _retry() {
    setState(() {
      _locationsFuture = widget.fetchLocations(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<TransferLocationData>>(
      future: _locationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Dialog(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: SizedBox(
                width: 280,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text('Loading transfer locations...', maxLines: 2),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        String? errorMessage;
        if (snapshot.hasError) {
          errorMessage = 'Failed to load transfer destinations.';
        } else {
          final result = snapshot.data;
          if (result == null) {
            errorMessage = 'No transfer locations available.';
          } else if (result.isFailure) {
            errorMessage =
                'Failed to load transfer destinations: ${result.error}';
          } else {
            final locationData = result.dataOrNull;
            if (locationData == null) {
              errorMessage = 'No transfer locations available.';
            } else if (locationData.warehouses.isEmpty) {
              errorMessage = 'No active warehouses available.';
            } else if (locationData.destinations.isEmpty) {
              errorMessage = 'No active station destinations available.';
            } else {
              return TransferStockDialog(
                availableBatteries: widget.availableBatteries,
                warehouses: locationData.warehouses,
                destinations: locationData.destinations,
              );
            }
          }
        }

        return AlertDialog(
          title: const Text('Transfer Stock'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Close'),
            ),
            FilledButton(onPressed: _retry, child: const Text('Retry')),
          ],
        );
      },
    );
  }
}

// ─── Sort Bottom Sheet ──────────────────────────────────────────────

class _SortBottomSheet extends ConsumerWidget {
  const _SortBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSort = ref.watch(inventorySortProvider);
    final currentOrder = ref.watch(inventorySortOrderProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sort_rounded, color: colorScheme.primary),
                AppSpacing.gapW8,
                Text('Sort Inventory', style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Choose how batteries are ordered in the list.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            AppSpacing.gapH16,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sort By', style: theme.textTheme.titleSmall),
                  AppSpacing.gapH12,
                  _SortOption(
                    label: 'Battery ID',
                    value: 'id',
                    icon: Icons.tag_rounded,
                    groupValue: currentSort,
                    onChanged: (val) {
                      ref.read(inventorySortProvider.notifier).state = val!;
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 10),
                  _SortOption(
                    label: 'Charge Level',
                    value: 'charge_percentage',
                    icon: Icons.battery_charging_full_rounded,
                    groupValue: currentSort,
                    onChanged: (val) {
                      ref.read(inventorySortProvider.notifier).state = val!;
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 10),
                  _SortOption(
                    label: 'Date Received',
                    value: 'created_at',
                    icon: Icons.calendar_today_rounded,
                    groupValue: currentSort,
                    onChanged: (val) {
                      ref.read(inventorySortProvider.notifier).state = val!;
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Direction', style: theme.textTheme.titleSmall),
                  AppSpacing.gapH12,
                  Row(
                    children: [
                      Expanded(
                        child: _SortDirectionOption(
                          label: 'Ascending',
                          icon: Icons.arrow_upward_rounded,
                          isSelected: currentOrder == 'asc',
                          onTap: () {
                            ref
                                    .read(inventorySortOrderProvider.notifier)
                                    .state =
                                'asc';
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      AppSpacing.gapW12,
                      Expanded(
                        child: _SortDirectionOption(
                          label: 'Descending',
                          icon: Icons.arrow_downward_rounded,
                          isSelected: currentOrder == 'desc',
                          onTap: () {
                            ref
                                    .read(inventorySortOrderProvider.notifier)
                                    .state =
                                'desc';
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _SortOption({
    required this.label,
    required this.value,
    required this.icon,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = groupValue == value;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Theme.of(context).colorScheme.outlineVariant,
          ),
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.primary : AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

class _SortDirectionOption extends StatelessWidget {
  const _SortDirectionOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        curve: AppAnimations.defaultCurve,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : theme.colorScheme.outlineVariant,
          ),
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : theme.colorScheme.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? AppColors.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter Chip Widget ─────────────────────────────────────────────

class _AnimatedFilterChip extends StatefulWidget {
  const _AnimatedFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_AnimatedFilterChip> createState() => _AnimatedFilterChipState();
}

class _AnimatedFilterChipState extends State<_AnimatedFilterChip> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double scale = _isPressed
        ? 0.95
        : _isHovered
        ? 1.05
        : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: AppAnimations.normal,
            curve: AppAnimations.defaultCurve,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? AppColors.primary
                  : (Theme.of(context).brightness == Brightness.light
                        ? AppColors.surfaceVariant
                        : AppColors.surfaceVariantDark),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.primary
                    : (_isHovered
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : (Theme.of(context).brightness == Brightness.light
                                ? AppColors.border
                                : AppColors.borderDark)),
                width: 1.5,
              ),
              boxShadow: widget.isSelected || _isHovered
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: _isHovered ? 12 : 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: AnimatedDefaultTextStyle(
              duration: AppAnimations.fast,
              style: AppTextStyles.labelMedium.copyWith(
                color: widget.isSelected
                    ? Colors.white
                    : AppColors.textSecondary,
                fontWeight: widget.isSelected
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
              child: Text(widget.label),
            ),
          ),
        ),
      ),
    );
  }
}

class _BatteryListItem extends StatelessWidget {
  const _BatteryListItem({required this.battery});

  final BatteryModel battery;

  Color get _chargeColor {
    if (battery.chargePercentage >= 80) return AppColors.batteryFull;
    if (battery.chargePercentage >= 40) return AppColors.batteryMedium;
    if (battery.chargePercentage >= 20) return AppColors.batteryLow;
    return AppColors.batteryCritical;
  }

  Color get _healthColor {
    if (battery.healthPercentage >= 80) return AppColors.success;
    if (battery.healthPercentage >= 60) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = BatteryStatusStyle.foreground(battery.status);
    final statusBgColor = BatteryStatusStyle.background(
      context,
      battery.status,
    );

    return AppCard(
      onTap: () => AppNavigator.toBatteryDetail(context, batteryId: battery.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: ID, Manufacturer, Status ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon with manufacturer initial
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Center(
                  child: Text(
                    battery.manufacturer.substring(0, 2).toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              AppSpacing.gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Hero(
                          tag: 'battery_id_${battery.id}',
                          child: Text(
                            battery.id,
                            style: theme.textTheme.labelLarge,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          Formatters.relativeTime(battery.updatedAt),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textHint,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${battery.manufacturer} · ${battery.model}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AppSpacing.gapW8,
              AppStatusBadge(label: battery.status.label, color: statusColor),
            ],
          ),
          AppSpacing.gapH8,

          // ── Row 2: Charge + Health bars ──
          Row(
            children: [
              // Charge
              Expanded(
                child: _MetricBar(
                  label: 'Charge',
                  value: battery.chargePercentage,
                  color: _chargeColor,
                ),
              ),
              AppSpacing.gapW12,
              // Health
              Expanded(
                child: _MetricBar(
                  label: 'Health',
                  value: battery.healthPercentage,
                  color: _healthColor,
                ),
              ),
            ],
          ),
          AppSpacing.gapH8,

          // ── Row 3: Metadata chips ──
          Row(
            children: [
              AppIconText(
                icon: Icons.repeat,
                label: '${battery.cycleCount} cycles',
              ),
              AppSpacing.gapW8,
              AppIconText(icon: Icons.bolt, label: '${battery.voltage}V'),
              if (battery.temperature != null) ...[
                AppSpacing.gapW8,
                AppIconText(
                  icon: Icons.thermostat,
                  label: '${battery.temperature}°C',
                ),
              ],
              const Spacer(),
              if (battery.location != null)
                AppIconText(
                  icon: Icons.location_on_outlined,
                  label: battery.location!
                      .replaceAll('Rack ', '')
                      .replaceAll('Shelf ', ''),
                ),
            ],
          ),

          // ── Row 4: Warnings ──
          if (battery.isLowHealth || battery.isWarrantyExpiring) ...[
            AppSpacing.gapH8,
            Row(
              children: [
                if (battery.isLowHealth)
                  AppStatusBadge(
                    icon: Icons.health_and_safety_outlined,
                    label: 'Low Health',
                    color: AppColors.error,
                    hasDot: false,
                  ),
                if (battery.isLowHealth && battery.isWarrantyExpiring)
                  AppSpacing.gapW8,
                if (battery.isWarrantyExpiring)
                  AppStatusBadge(
                    icon: Icons.schedule_outlined,
                    label: 'Warranty Expiring',
                    color: AppColors.warning,
                    hasDot: false,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact metric bar widget showing label + progress + percentage.
class _MetricBar extends StatelessWidget {
  const _MetricBar({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textHint,
                fontSize: 10,
              ),
            ),
            Text(
              '$value%',
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        SizedBox(
          height: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 4,
            ),
          ),
        ),
      ],
    );
  }
}

/// Tiny chip for metadata.

/// Small warning badge for low health / warranty expiring.
