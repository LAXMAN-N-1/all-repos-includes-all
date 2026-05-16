import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_constants.dart';
import '../../../core/providers.dart';
import '../../../core/result.dart';
import '../../../models/driver_model.dart';
import '../../../models/order_model.dart';
import '../repository/driver_repository.dart';
import '../../orders/providers/orders_providers.dart';

// Repository Provider
final driverRepositoryProvider = Provider<DriverRepository>((ref) {
  return DriverRepository(api: ref.read(apiClientProvider));
});

// Fleet/Drivers List
final fleetListProvider =
    StateNotifierProvider<FleetListNotifier, AsyncValue<List<DriverModel>>>((
      ref,
    ) {
      return FleetListNotifier(ref.read(driverRepositoryProvider));
    });

class FleetListNotifier extends StateNotifier<AsyncValue<List<DriverModel>>> {
  final DriverRepository _repository;

  FleetListNotifier(this._repository) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh({DriverStatus? status}) async {
    state = const AsyncValue.loading();
    final result = await _repository.fetchDrivers(status: status);
    result.when(
      success: (drivers) => state = AsyncValue.data(drivers),
      failure: (msg, st) => state = AsyncValue.error(msg, StackTrace.current),
    );
  }

  Future<Result<DriverModel>> addDriver(DriverModel driver) async {
    final result = await _repository.createDriver(driver);
    result.when(
      success: (newDriver) {
        final currentList = state.value ?? [];
        state = AsyncValue.data([...currentList, newDriver]);
      },
      failure: (_, __) {},
    );
    return result;
  }
}

// Active Drivers Filter (Client-side from full list)
final activeDriversProvider = Provider<List<DriverModel>>((ref) {
  final driversState = ref.watch(fleetListProvider);
  return driversState.maybeWhen(
    data: (drivers) =>
        drivers.where((d) => d.status != DriverStatus.offline).toList(),
    orElse: () => [],
  );
});

// Available Drivers (Server-side fetched for assignment)
final availableDriversProvider = FutureProvider.autoDispose<List<DriverModel>>((
  ref,
) async {
  final repo = ref.read(driverRepositoryProvider);
  final result = await repo.fetchDrivers(status: DriverStatus.available);
  return result.when(success: (drivers) => drivers, failure: (_, __) => []);
});

// Selected Driver State
final selectedDriverIdProvider = StateProvider<String?>((ref) => null);

final selectedDriverProvider = Provider<DriverModel?>((ref) {
  final selectedId = ref.watch(selectedDriverIdProvider);
  final driversState = ref.watch(fleetListProvider);

  return driversState.maybeWhen(
    data: (drivers) {
      if (selectedId == null) return null;
      try {
        return drivers.firstWhere((d) => d.id == selectedId);
      } catch (_) {
        return null;
      }
    },
    orElse: () => null,
  );
});

// Driver Orders
// Fetches orders assigned to specific driver
final driverOrdersProvider = FutureProvider.family<List<OrderModel>, String>((
  ref,
  driverId,
) async {
  final repo = ref.read(ordersRepositoryProvider);
  final result = await repo.fetchOrders(
    driverId: driverId,
    statuses: const [OrderStatus.pending, OrderStatus.inTransit],
    pageSize: 200,
  );
  return result.when(
    success: (orders) => orders,
    failure: (_, __) => [], // Return empty list on failure for now
  );
});

// ─── Live Location Polling ────────────────────────────────────────────────────
// Polls the backend every 30s to get the latest driver location.
final driverLiveLocationProvider = StreamProvider.family<DriverModel?, String>((
  ref,
  driverId,
) async* {
  final repo = ref.read(driverRepositoryProvider);

  // Emit immediately, then every 30s
  while (true) {
    final result = await repo.fetchDriver(driverId);
    yield result.when(success: (d) => d, failure: (_, __) => null);
    await Future.delayed(const Duration(seconds: 30));
  }
});

// ─── ETA Provider ─────────────────────────────────────────────────────────────
// Calls Google Directions API to get ETA from driver location to destination.
// Returns a record: (etaText, etaMinutes, routePoints)
class EtaResult {
  final String etaText;
  final int etaMinutes;
  final List<Map<String, double>> routePoints; // [{lat, lng}]

  const EtaResult({
    required this.etaText,
    required this.etaMinutes,
    required this.routePoints,
  });
}

final etaProvider =
    FutureProvider.family<EtaResult, ({String driverId, String destination})>((
      ref,
      args,
    ) async {
      final liveDriver = ref
          .watch(driverLiveLocationProvider(args.driverId))
          .value;
      if (liveDriver == null) {
        return const EtaResult(
          etaText: 'Calculating...',
          etaMinutes: 0,
          routePoints: [],
        );
      }

      final origin = '${liveDriver.currentLat},${liveDriver.currentLng}';
      final dio = Dio();
      try {
        final response = await dio.get(
          AppConstants.directionsApiUrl,
          queryParameters: {
            'origin': origin,
            'destination': args.destination,
            'key': AppConstants.googleMapsApiKey,
            'mode': 'driving',
          },
        );
        final data = response.data as Map<String, dynamic>;
        final routes = data['routes'] as List?;
        if (routes == null || routes.isEmpty) {
          return const EtaResult(
            etaText: 'Route unavailable',
            etaMinutes: 0,
            routePoints: [],
          );
        }
        final leg = routes[0]['legs'][0] as Map<String, dynamic>;
        final etaText = leg['duration']['text'] as String;
        final etaMinutes = (leg['duration']['value'] as int) ~/ 60;
        final encodedPolyline =
            routes[0]['overview_polyline']['points'] as String;
        final points = _decodePolyline(encodedPolyline);
        return EtaResult(
          etaText: etaText,
          etaMinutes: etaMinutes,
          routePoints: points,
        );
      } catch (_) {
        return const EtaResult(
          etaText: 'ETA unavailable',
          etaMinutes: 0,
          routePoints: [],
        );
      }
    });

List<Map<String, double>> _decodePolyline(String encoded) {
  final List<Map<String, double>> points = [];
  int index = 0;
  int lat = 0, lng = 0;
  while (index < encoded.length) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lat += dlat;
    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lng += dlng;
    points.add({'lat': lat / 1e5, 'lng': lng / 1e5});
  }
  return points;
}

// ─── Delay Alert Provider ─────────────────────────────────────────────────────
// Returns true if ETA exceeds estimated delivery by > 15 minutes.
final delayAlertProvider =
    Provider.family<bool, ({int etaMinutes, DateTime? estimatedDelivery})>((
      ref,
      args,
    ) {
      if (args.estimatedDelivery == null || args.etaMinutes == 0) return false;
      final minutesUntilDeadline = args.estimatedDelivery!
          .difference(DateTime.now())
          .inMinutes;
      return args.etaMinutes >
          minutesUntilDeadline + AppConstants.delayAlertThresholdMinutes;
    });

// ─── Analytics Provider ───────────────────────────────────────────────────────
final logisticsAnalyticsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
      final api = ref.read(apiClientProvider);
      try {
        final response = await api.get<Map<String, dynamic>>(
          '/logistics/performance',
        );
        final payload = response['data'];
        if (payload is Map<String, dynamic>) {
          return payload;
        }
        return response;
      } catch (e) {
        return {
          "onTimeRate": 0.0,
          "avgDeliveryTime": 0.0,
          "failedCount": 0,
          "fleetRating": 0.0,
          "deliveryTrend": [],
        };
      }
    });
