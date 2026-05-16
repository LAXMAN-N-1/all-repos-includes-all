import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api_exception.dart';
import '../../../../models/driver_model.dart';
import '../../../../models/order_model.dart';
import '../../../../widgets/app_scaffold.dart';
import '../../../../widgets/app_search_bar.dart';
import '../../../../widgets/scroll_morph_fab.dart';
import '../providers/logistics_providers.dart';
import '../widgets/fleet_map_widget.dart';
import '../widgets/drivers_list_view.dart';
import '../../../../config/app_routes.dart';
import 'package:go_router/go_router.dart';
import '../providers/route_providers.dart';
import '../widgets/route_stats_card.dart';

class FleetScreen extends ConsumerStatefulWidget {
  const FleetScreen({super.key});

  @override
  ConsumerState<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends ConsumerState<FleetScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _driversScrollController = ScrollController();
  final ValueNotifier<double> _driversFabCollapseProgress =
      ValueNotifier<double>(0);
  double _lastDriversScrollOffset = 0;
  int _activeTabIndex = 0;
  static const double _collapseTravel = 92;
  static const double _minScrollDelta = 0.2;

  void _setDriversFabProgress(double value) {
    final clamped = value.clamp(0.0, 1.0);
    final snapped = clamped <= 0.02 ? 0.0 : (clamped >= 0.98 ? 1.0 : clamped);
    if ((_driversFabCollapseProgress.value - snapped).abs() > 0.0001) {
      _driversFabCollapseProgress.value = snapped;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!mounted) return;
      if (_activeTabIndex == _tabController.index) return;
      setState(() {
        _activeTabIndex = _tabController.index;
      });
      if (_activeTabIndex != 1) {
        _setDriversFabProgress(1);
      } else if (!_driversScrollController.hasClients ||
          _driversScrollController.position.pixels <= 0) {
        _setDriversFabProgress(0);
      }
    });
    _driversScrollController.addListener(() {
      if (!_driversScrollController.hasClients) {
        return;
      }
      final offset = _driversScrollController.position.pixels.clamp(
        0.0,
        double.infinity,
      );
      final delta = offset - _lastDriversScrollOffset;
      _lastDriversScrollOffset = offset;

      if (offset <= 0) {
        _setDriversFabProgress(0);
      } else if (delta.abs() >= _minScrollDelta) {
        final next =
            _driversFabCollapseProgress.value + (delta / _collapseTravel);
        _setDriversFabProgress(next);
      }
    });
  }

  @override
  void dispose() {
    _driversScrollController.dispose();
    _driversFabCollapseProgress.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeDrivers = ref.watch(activeDriversProvider);
    final selectedDriverId = ref.watch(selectedDriverIdProvider);
    final activeRoute = ref.watch(activeRouteProvider);
    final isOptimizing = ref.watch(isOptimizingRouteProvider);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Fleet Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Live Map', icon: Icon(Icons.map_outlined)),
            Tab(text: 'Drivers', icon: Icon(Icons.people_outline)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics:
            const NeverScrollableScrollPhysics(), // Map needs touch gestures
        children: [
          // Map Tab
          Stack(
            children: [
              FleetMapWidget(
                drivers: activeDrivers,
                activeRoute: activeRoute,
                onDriverTap: (id) {
                  ref.read(selectedDriverIdProvider.notifier).state = id;
                },
              ),
              Positioned(
                top: activeRoute != null ? 220 : 16,
                left: 16,
                right: 16,
                child: AppSearchBar(
                  hintText: 'Search drivers or order ID...',
                  onChanged: (val) {},
                ),
              ),

              // Route Stats Card
              if (activeRoute != null)
                Positioned(
                  top: 80,
                  left: 16,
                  right: 16,
                  child: RouteStatsCard(
                    route: activeRoute,
                    onClear: () {
                      ref.read(activeRouteProvider.notifier).state = null;
                      ref.read(selectedDriverIdProvider.notifier).state = null;
                    },
                  ),
                ),

              // Optimize Button (only if driver selected and no route yet)
              if (selectedDriverId != null && activeRoute == null)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: isOptimizing
                      ? const FloatingActionButton(
                          onPressed: null,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : FloatingActionButton.extended(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            DriverModel? driver;
                            for (final candidate in activeDrivers) {
                              if (candidate.id == selectedDriverId) {
                                driver = candidate;
                                break;
                              }
                            }
                            if (driver == null) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Selected driver not found'),
                                ),
                              );
                              return;
                            }

                            try {
                              final orders = await ref.read(
                                driverOrdersProvider(driver.id).future,
                              );
                              final routableOrders = orders.where((order) {
                                return order.status == OrderStatus.pending ||
                                    order.status == OrderStatus.inTransit;
                              }).toList();

                              if (routableOrders.isEmpty) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Driver has no pending or in-transit orders to optimize',
                                    ),
                                  ),
                                );
                                return;
                              }

                              await ref
                                  .read(routeControllerProvider)
                                  .optimizeRoute(
                                    driver: driver,
                                    orderIds: routableOrders
                                        .map((e) => e.id)
                                        .toList(),
                                  );
                            } on ApiException catch (e) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.message.isEmpty
                                        ? 'Route optimization failed'
                                        : e.message,
                                  ),
                                ),
                              );
                            } catch (_) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Route optimization failed unexpectedly',
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.directions),
                          label: const Text('Optimize Route'),
                        ),
                ),
            ],
          ),

          // List Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: AppSearchBar(
                  hintText: 'Search drivers...',
                  onChanged: (val) {},
                ),
              ),
              Expanded(
                child: DriversListView(
                  scrollController: _driversScrollController,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: ValueListenableBuilder<double>(
        valueListenable: _driversFabCollapseProgress,
        builder: (context, progress, _) => ScrollMorphFab(
          progress: _activeTabIndex == 1 ? progress : 1,
          onPressed: () {
            context.pushNamed(AppRoutes.addDriver);
          },
          icon: const Icon(Icons.person_add),
          label: 'Add Driver',
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
