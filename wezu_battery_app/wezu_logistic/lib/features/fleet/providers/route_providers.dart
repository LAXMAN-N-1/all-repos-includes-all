import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/route_model.dart';
import '../repository/route_repository.dart';
import '../../../../models/driver_model.dart';

// State for the active route
final activeRouteProvider = StateProvider<DeliveryRouteModel?>((ref) => null);

// State for optimization loading status
final isOptimizingRouteProvider = StateProvider<bool>((ref) => false);

// Logic to trigger optimization
final routeControllerProvider = Provider((ref) {
  final repository = ref.read(routeRepositoryProvider);
  
  return RouteController(ref, repository);
});

class RouteController {
  final Ref _ref;
  final RouteRepository _repository;

  RouteController(this._ref, this._repository);

  Future<void> optimizeRoute({
    required DriverModel driver,
    required List<String> orderIds,
  }) async {
    try {
      _ref.read(isOptimizingRouteProvider.notifier).state = true;
      
      final route = await _repository.optimizeRoute(
        driverId: driver.id,
        startLocation: GeoPoint(lat: driver.currentLat, lng: driver.currentLng),
        orderIds: orderIds,
      );

      _ref.read(activeRouteProvider.notifier).state = route;
    } catch (e) {
      // Handle error (show toast/snackbar in UI)
      rethrow;
    } finally {
      _ref.read(isOptimizingRouteProvider.notifier).state = false;
    }
  }
  
  void clearRoute() {
    _ref.read(activeRouteProvider.notifier).state = null;
  }
}
