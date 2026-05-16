import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_exception.dart';
import '../models/route_model.dart';
import '../../../services/api/api_client.dart';
import '../../../core/providers.dart';

final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  return RouteRepository(apiClient: ref.read(apiClientProvider));
});

class RouteRepository {
  final ApiClient apiClient;

  RouteRepository({required this.apiClient});

  Future<DeliveryRouteModel> optimizeRoute({
    required String driverId,
    required GeoPoint startLocation,
    required List<String> orderIds,
  }) async {
    final parsedDriverId = _parseDriverId(driverId);
    if (parsedDriverId == null) {
      throw ApiException(
        message: 'Invalid driver ID format. Expected D-<number> or <number>.',
        statusCode: 400,
      );
    }

    final normalizedOrderIds = orderIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    if (normalizedOrderIds.isEmpty) {
      throw ApiException(
        message: 'No valid order IDs were provided for route optimization.',
        statusCode: 400,
      );
    }

    final response = await apiClient.post<Map<String, dynamic>>(
      '/routes/optimize',
      data: {
        'driver_id': parsedDriverId,
        'start_location': startLocation.toJson(),
        'order_ids': normalizedOrderIds,
      },
    );

    final routePayload = response['data'];
    if (routePayload is! Map<String, dynamic>) {
      throw ApiException(
        message: 'Unexpected route optimization response payload.',
      );
    }

    return DeliveryRouteModel.fromJson(routePayload);
  }

  int? _parseDriverId(String rawDriverId) {
    final trimmed = rawDriverId.trim();
    if (trimmed.isEmpty) return null;
    final withoutPrefix = trimmed.toUpperCase().startsWith('D-')
        ? trimmed.substring(2)
        : trimmed;
    final parsed = int.tryParse(withoutPrefix);
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }
}
