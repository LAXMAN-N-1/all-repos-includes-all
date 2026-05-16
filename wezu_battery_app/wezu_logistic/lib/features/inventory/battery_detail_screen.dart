import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_animations.dart';
import '../../config/app_spacing.dart';
import '../../config/app_text_styles.dart';
import '../../utils/app_haptics.dart';
import '../../models/battery_model.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import 'providers/inventory_providers.dart';
import 'providers/warehouse_providers.dart';
import 'utils/battery_status_style.dart';
import 'widgets/warehouse_grid_view.dart';
import 'widgets/battery_gauges.dart';
import 'widgets/battery_timeline.dart';

class BatteryDetailScreen extends ConsumerWidget {
  final String batteryId;

  const BatteryDetailScreen({super.key, required this.batteryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batteryAsync = ref.watch(batteryDetailProvider(batteryId));

    return AppScaffold(
      useSafeArea: false,
      body: batteryAsync.when(
        loaded: (battery) {
          return _buildContent(context, ref, battery);
        },
        initial: () => const AppLoader(),
        loading: () => const AppLoader(),
        error: (err) => Center(child: Text('Error: $err')),
      ),
      bottomNavigationBar: batteryAsync.dataOrNull != null
          ? _buildBottomActionBar(context, ref, batteryAsync.dataOrNull!)
          : null,
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    BatteryModel battery,
  ) {
    final statusColor = BatteryStatusStyle.foreground(battery.status);

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildImmersiveHeader(context, battery, statusColor),
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusChip(context, battery),
                    AppSpacing.gapH24,

                    // Gauges
                    BatteryGaugesRow(
                      chargePercentage: battery.chargePercentage.toDouble(),
                      healthPercentage: battery.healthPercentage.toDouble(),
                    ).sectionEntrance(),
                    AppSpacing.gapH24,
                    const Divider(),
                    AppSpacing.gapH24,

                    // Key Specs Grid
                    Text(
                      'Specifications',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    AppSpacing.gapH16,
                    _buildSpecsGrid(
                      context,
                      battery,
                    ).sectionEntrance(delay: const Duration(milliseconds: 100)),
                    AppSpacing.gapH24,

                    // Location Check
                    _buildLocationCard(
                      context,
                      battery,
                    ).sectionEntrance(delay: const Duration(milliseconds: 200)),
                    AppSpacing.gapH24,

                    // Timeline
                    BatteryTimeline(
                      events: _getEvents(battery),
                    ).sectionEntrance(delay: const Duration(milliseconds: 300)),

                    // Bottom padding for FAB/Bar
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Floating Back Button
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildFloatingButton(
                context,
                icon: Icons.arrow_back_rounded,
                onPressed: () {
                  AppHaptics.impact();
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
        // Floating Share Button
        Positioned(
          top: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildFloatingButton(
                context,
                icon: Icons.share_rounded,
                onPressed: () {
                  AppHaptics.impact();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImmersiveHeader(
    BuildContext context,
    BatteryModel battery,
    Color color,
  ) {
    return SliverAppBar.large(
      expandedHeight: 220,
      pinned: true,
      stretch: true,
      backgroundColor: color,
      foregroundColor: Colors.white,
      centerTitle: true, // Center title when collapsed to avoid back button
      automaticallyImplyLeading: false, // Hide default back button
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(
          bottom: 16,
        ), // Allow centerTitle to work horizontally
        title: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Hero(
                tag: 'battery_id_${battery.id}',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    battery.id,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Text(
                battery.model,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                color,
                color.withValues(alpha: 0.7),
                Theme.of(context).scaffoldBackgroundColor,
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Hero(
                tag: 'battery_${battery.id}',
                child: Icon(
                  Icons.battery_charging_full_rounded,
                  size: 100,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, BatteryModel battery) {
    final color = BatteryStatusStyle.foreground(battery.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            battery.status.label.toUpperCase(),
            style: AppTextStyles.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsGrid(BuildContext context, BatteryModel battery) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildSpecItem(context, Icons.bolt, 'Voltage', '${battery.voltage}V'),
        _buildSpecItem(
          context,
          Icons.energy_savings_leaf,
          'Capacity',
          '${(battery.capacity / 1000).toStringAsFixed(1)}Ah',
        ),
        _buildSpecItem(context, Icons.loop, 'Cycles', '${battery.cycleCount}'),
        _buildSpecItem(
          context,
          Icons.thermostat,
          'Temp',
          battery.temperature != null ? '${battery.temperature}°C' : 'N/A',
        ),
      ],
    );
  }

  Widget _buildSpecItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: AppTextStyles.caption),
              Text(
                value,
                style: AppTextStyles.titleMedium.copyWith(fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, BatteryModel battery) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warehouse_rounded,
              color: AppColors.primary,
            ),
          ),
          AppSpacing.gapW16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Location', style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  battery.location ?? 'Unassigned',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {}, // TODO: Show on Map
            child: const Text('View'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    WidgetRef ref,
    BatteryModel battery,
  ) {
    return BottomAppBar(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              onPressed: () => _showMoveStockDialog(context, ref, battery),
              icon: Icons.move_down,
              label: 'Move',
              variant: AppButtonVariant.outlined,
              size: AppButtonSize.medium,
            ),
          ),
          AppSpacing.gapW12,
          Expanded(
            child: AppButton(
              onPressed: () {
                // Dispatch logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dispatch initiated')),
                );
              },
              icon: Icons.outbound,
              label: 'Dispatch',
              size: AppButtonSize.medium,
            ),
          ),
          IconButton.filledTonal(
            onPressed: () {
              // More actions
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('More options...')));
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  List<TimelineEvent> _getEvents(BatteryModel battery) {
    if (battery.history.isEmpty) return [];

    return battery.history.map((e) {
      return TimelineEvent(
        title: _mapEventTitle(e.eventType),
        description: e.description ?? '',
        date: e.timestamp,
        icon: _mapEventIcon(e.eventType),
        color: _mapEventColor(e.eventType),
      );
    }).toList();
  }

  String _mapEventTitle(String type) {
    switch (type) {
      case 'created':
        return 'Registered';
      case 'status_change':
        return 'Status Update';
      case 'location_change':
        return 'Moved';
      case 'maintenance_start':
        return 'Maintenance Started';
      case 'maintenance_end':
        return 'Maintenance Completed';
      default:
        return 'Event';
    }
  }

  IconData _mapEventIcon(String type) {
    switch (type) {
      case 'created':
        return Icons.add_circle_outline;
      case 'status_change':
        return Icons.info_outline;
      case 'location_change':
        return Icons.place;
      case 'maintenance_start':
        return Icons.build;
      case 'maintenance_end':
        return Icons.check_circle_outline;
      default:
        return Icons.circle;
    }
  }

  Color _mapEventColor(String type) {
    switch (type) {
      case 'created':
        return AppColors.success;
      case 'status_change':
        return AppColors.info;
      case 'location_change':
        return AppColors.primary;
      case 'maintenance_start':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showMoveStockDialog(
    BuildContext context,
    WidgetRef ref,
    BatteryModel battery,
  ) {
    final preferredWarehouseId =
        (battery.location ?? '').toLowerCase() == 'warehouse'
        ? battery.locationId
        : null;
    ref
        .read(warehouseGraphProvider.notifier)
        .loadWarehouse(
          preferredWarehouseId: preferredWarehouseId,
          batterySerialHint: battery.serialNumber,
        );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select New Location',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) {
                    final warehouseAsync = ref.watch(warehouseGraphProvider);
                    return warehouseAsync.when(
                      loaded: (warehouse) => WarehouseGridView(
                        warehouse: warehouse,
                        onLocationSelected: (locationId) async {
                          Navigator.pop(context); // Close dialog

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Moving battery to shelf $locationId...',
                              ),
                            ),
                          );

                          // Assign battery to the selected shelf
                          final warehouseRepo = ref.read(
                            warehouseRepositoryProvider,
                          );
                          final result = await warehouseRepo
                              .assignBatteryToShelf(
                                batteryId: battery.serialNumber,
                                shelfId: locationId,
                              );

                          result.when(
                            success: (_) {
                              // Refresh both battery details and warehouse
                              ref.invalidate(batteryDetailProvider(battery.id));
                              ref
                                  .read(warehouseGraphProvider.notifier)
                                  .loadWarehouse(
                                    preferredWarehouseId: preferredWarehouseId,
                                    batterySerialHint: battery.serialNumber,
                                  );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Battery moved successfully!'),
                                ),
                              );
                            },
                            failure: (message, _) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Move failed: $message'),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      loading: () => const AppLoader(),
                      initial: () => const AppLoader(),
                      error: (message) =>
                          Center(child: Text('Error: $message')),
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

  Widget _buildFloatingButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white12,
          width: 1,
        ), // Visibility on Black
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
