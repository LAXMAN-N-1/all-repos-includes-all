import 'package:dio/dio.dart';

import '../../../core/api_exception.dart';
import '../../../core/result.dart';
import '../../../models/order_model.dart';
import '../../../services/api/api_client.dart';
import '../../../services/api/idempotency_key.dart';
import '../../../services/offline_service.dart';
import '../../../utils/battery_identity.dart';

String? _trimOrNull(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

Map<String, dynamic> buildSubmitProofOfDeliveryPayload({
  required String imageUrl,
  String? notes,
  String? signatureUrl,
  String? recipientName,
}) {
  final normalizedImageUrl = imageUrl.trim();
  final normalizedNotes = _trimOrNull(notes);
  final normalizedSignatureUrl = _trimOrNull(signatureUrl);
  final normalizedRecipientName = _trimOrNull(recipientName);

  final payload = <String, dynamic>{
    'image_url': normalizedImageUrl,
    'imageUrl': normalizedImageUrl,
    'notes': normalizedNotes,
    'signature_url': normalizedSignatureUrl,
    'signatureUrl': normalizedSignatureUrl,
    'recipient_name': normalizedRecipientName,
    'recipientName': normalizedRecipientName,
    'proofOfDelivery': <String, dynamic>{
      'imageUrl': normalizedImageUrl,
      if (normalizedNotes != null) 'notes': normalizedNotes,
      if (normalizedSignatureUrl != null)
        'signatureUrl': normalizedSignatureUrl,
      if (normalizedRecipientName != null)
        'recipientName': normalizedRecipientName,
    },
  };
  payload.removeWhere((_, value) => value == null);
  return payload;
}

/// Repository for order data operations.
/// Connects to the real backend API.
class OrdersRepository {
  final ApiClient _api;

  OrdersRepository({required ApiClient api}) : _api = api;

  /// Fetch orders with optional status filter, search, and sort.
  Future<Result<List<OrderModel>>> fetchOrders({
    int page = 1,
    int pageSize = 20,
    List<OrderStatus>? statuses,
    String? searchQuery,
    String sortBy = 'order_date',
    String sortOrder = 'desc',
    OrderPriority? priorityFilter,
    String? driverId,
  }) async {
    try {
      final normalizedDriverId = _normalizeDriverIdForApi(driverId);
      if (driverId != null && normalizedDriverId == null) {
        return Result.failure(
          'Invalid driver ID format. Expected D-<number> or <number>.',
        );
      }

      final normalizedStatuses = _normalizeStatuses(statuses);
      final selectedStatuses = statuses?.toSet() ?? const <OrderStatus>{};
      final backendSortBy = switch (sortBy) {
        'updated_at' => 'updated_at',
        'estimated_delivery' => 'estimated_delivery',
        _ => 'order_date',
      };

      final queryParams = <String, dynamic>{
        'skip': (page - 1) * pageSize,
        'limit': pageSize,
        'include_pagination': true,
        'sort_by': backendSortBy,
        'sort_order': sortOrder,
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }

      if (normalizedDriverId != null) {
        queryParams['assigned_driver_id'] = normalizedDriverId;
      }

      if (normalizedStatuses.length == 1) {
        queryParams['status'] = normalizedStatuses.first;
      }

      if (priorityFilter != null) {
        queryParams['priority'] = priorityFilter.name;
      }

      final response = await _api.get<dynamic>(
        '/orders/',
        queryParameters: queryParams,
      );

      final List<dynamic> listData = _extractOrdersList(response);
      var items = listData
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Client-side filtering for statuses (if backend doesn't support multiple status query)
      if (normalizedStatuses.length > 1) {
        items = items
            .where((o) => selectedStatuses.contains(o.status))
            .toList();
      }

      await OfflineService.cacheOrders(items);
      return Result.success(items);
    } on ApiException catch (e) {
      final cached = OfflineService.getCachedOrders();
      if (cached.isNotEmpty) return Result.success(cached);
      return Result.failure(e.message);
    } catch (e) {
      final cached = OfflineService.getCachedOrders();
      if (cached.isNotEmpty) return Result.success(cached);
      return Result.failure('Failed to load orders: $e');
    }
  }

  /// Fetch computed order statistics.
  Future<Result<Map<String, dynamic>>> fetchOrderStats() async {
    try {
      final response = await _api.get<dynamic>(
        '/orders/',
        queryParameters: {'skip': 0, 'limit': 500, 'include_pagination': true},
      );
      final List<dynamic> data = _extractOrdersList(response);
      final allOrders = data.map((e) => OrderModel.fromJson(e)).toList();

      final pendingCount = allOrders
          .where((o) => o.status == OrderStatus.pending)
          .length;
      final inTransitCount = allOrders
          .where((o) => o.status == OrderStatus.inTransit)
          .length;
      final deliveredCount = allOrders
          .where((o) => o.status == OrderStatus.delivered)
          .length;
      final failedCount = allOrders
          .where((o) => o.status == OrderStatus.failed)
          .length;
      final urgentCount = allOrders
          .where((o) => o.priority == OrderPriority.urgent)
          .length;
      final totalValue = allOrders.fold<double>(
        0,
        (sum, o) => sum + o.totalValue,
      );
      final totalUnits = allOrders.fold<int>(0, (sum, o) => sum + o.units);

      return Result.success({
        'total_orders': allOrders.length,
        'pending': pendingCount,
        'in_transit': inTransitCount,
        'delivered': deliveredCount,
        'failed': failedCount,
        'urgent': urgentCount,
        'total_value': totalValue,
        'total_units': totalUnits,
      });
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to load order stats: $e');
    }
  }

  /// Get search recommendations based on query.
  Future<List<String>> getSearchRecommendations(String query) async {
    if (query.isEmpty) return [];
    try {
      final result = await fetchOrders(searchQuery: query, pageSize: 5);
      if (result.isSuccess) {
        final orders = result.dataOrNull!;
        return orders.map((o) => o.id).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Fetch a single order by ID.
  Future<Result<OrderModel>> getOrderById(
    String id, {
    bool noCache = false,
  }) async {
    try {
      final data = await _api.get<Map<String, dynamic>>(
        '/orders/$id',
        options: noCache
            ? Options(
                headers: const {
                  'Cache-Control': 'no-cache',
                  'Pragma': 'no-cache',
                },
              )
            : null,
      );
      return Result.success(OrderModel.fromJson(data['data']));
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Order not found: $e');
    }
  }

  /// Create a new order.
  Future<Result<OrderModel>> createOrder({
    required int units,
    required String destination,
    required List<String> assignedBatteryIds,
    String? notes,
    String? customerName,
    String? customerPhone,
    OrderPriority priority = OrderPriority.normal,
    double? totalValue,
    String? trackingNumber,
    int? assignedDriverId,
    DateTime? orderDate,
    DateTime? dispatchDate,
    DateTime? estimatedDelivery,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final normalizedDestination = destination.trim();
      if (units <= 0) {
        return Result.failure('Units must be greater than 0.');
      }
      if (normalizedDestination.isEmpty) {
        return Result.failure('Destination is required.');
      }
      if (normalizedDestination.length > 255) {
        return Result.failure('Destination must be 255 characters or less.');
      }

      final normalizedAssignedBatteryIds = normalizeBatterySerials(
        assignedBatteryIds,
      );
      if (normalizedAssignedBatteryIds.isEmpty) {
        return Result.failure(
          'Select at least one assigned battery before creating an order.',
          code: '422',
        );
      }
      if (units != normalizedAssignedBatteryIds.length) {
        return Result.failure(
          'Units must equal assigned_battery_ids count.',
          code: '422',
        );
      }

      final hasLatitude = latitude != null;
      final hasLongitude = longitude != null;
      if (hasLatitude != hasLongitude) {
        return Result.failure(
          'Latitude and longitude must both be provided together.',
          code: '422',
        );
      }
      if (latitude != null && (latitude < -90 || latitude > 90)) {
        return Result.failure(
          'Latitude must be between -90 and 90.',
          code: '422',
        );
      }
      if (longitude != null && (longitude < -180 || longitude > 180)) {
        return Result.failure(
          'Longitude must be between -180 and 180.',
          code: '422',
        );
      }

      final normalizedCustomerName = (customerName ?? '').trim().isEmpty
          ? 'Walk-in Customer'
          : customerName!.trim();
      if (normalizedCustomerName.length > 120) {
        return Result.failure('Customer name must be 120 characters or less.');
      }

      final normalizedCustomerPhone = _normalizeCustomerPhone(customerPhone);
      if (customerPhone != null &&
          customerPhone.trim().isNotEmpty &&
          normalizedCustomerPhone == null) {
        return Result.failure(
          'Customer phone must contain 10 to 15 digits.',
          code: '422',
        );
      }

      final normalizedNotes = notes?.trim();
      if (normalizedNotes != null && normalizedNotes.length > 2000) {
        return Result.failure('Notes must be 2000 characters or less.');
      }

      final normalizedTrackingNumber = trackingNumber?.trim();
      if (normalizedTrackingNumber != null &&
          normalizedTrackingNumber.length > 64) {
        return Result.failure('Tracking number must be 64 characters or less.');
      }

      if (totalValue != null && totalValue < 0) {
        return Result.failure(
          'Total value must be greater than or equal to 0.',
        );
      }

      if (dispatchDate != null &&
          orderDate != null &&
          dispatchDate.isBefore(orderDate)) {
        return Result.failure(
          'Dispatch date must be greater than or equal to order date.',
          code: '422',
        );
      }

      final earliestDeliveryDate = dispatchDate ?? orderDate;
      if (estimatedDelivery != null &&
          earliestDeliveryDate != null &&
          estimatedDelivery.isBefore(earliestDeliveryDate)) {
        return Result.failure(
          'Estimated delivery must be greater than or equal to dispatch/order date.',
          code: '422',
        );
      }

      final payload = <String, dynamic>{
        'units': units,
        'destination': normalizedDestination,
        'assigned_battery_ids': normalizedAssignedBatteryIds,
        'customer_name': normalizedCustomerName,
        'priority': priority.name,
        if (normalizedCustomerPhone != null)
          'customer_phone': normalizedCustomerPhone,
        if (totalValue != null) 'total_value': totalValue,
        if (normalizedNotes != null && normalizedNotes.isNotEmpty)
          'notes': normalizedNotes,
        if (normalizedTrackingNumber != null &&
            normalizedTrackingNumber.isNotEmpty)
          'tracking_number': normalizedTrackingNumber,
        if (assignedDriverId != null) 'assigned_driver_id': assignedDriverId,
        if (orderDate != null) 'order_date': orderDate.toIso8601String(),
        if (dispatchDate != null)
          'dispatch_date': dispatchDate.toIso8601String(),
        if (estimatedDelivery != null)
          'estimated_delivery': estimatedDelivery.toIso8601String(),
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

      final response = await _api.post<dynamic>(
        '/orders/',
        data: payload,
        options: Options(headers: buildIdempotencyHeaders('orders_create')),
      );
      final orderPayload = _extractOrderMap(response);
      if (orderPayload == null || orderPayload.isEmpty) {
        return Result.failure('Invalid create-order response from server.');
      }
      return Result.success(OrderModel.fromJson(orderPayload));
    } on ApiException catch (e) {
      final statusCode = e.statusCode;
      if (statusCode == 400 || statusCode == 409 || statusCode == 422) {
        return Result.failure(e.message, code: '$statusCode');
      }
      return Result.failure(e.message, code: statusCode?.toString());
    } catch (e) {
      return Result.failure('Failed to create order: $e');
    }
  }

  String? _normalizeCustomerPhone(String? phone) {
    if (phone == null) return null;
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.isEmpty) return null;
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return null;
    }
    return digitsOnly;
  }

  /// Cancel an existing order.
  Future<Result<OrderModel>> cancelOrder(String id) async {
    try {
      final data = await _api.put<Map<String, dynamic>>(
        '/orders/$id/status',
        data: {'status': 'cancelled'},
        options: Options(
          headers: buildIdempotencyHeaders('orders_status_cancel_$id'),
        ),
      );
      return Result.success(OrderModel.fromJson(data['data']));
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to cancel order: $e');
    }
  }

  /// Mark order as in transit (dispatched).
  Future<Result<OrderModel>> markInTransit(String id) async {
    try {
      final data = await _api.put<Map<String, dynamic>>(
        '/orders/$id/status',
        data: {'status': 'in_transit'},
        options: Options(
          headers: buildIdempotencyHeaders('orders_status_in_transit_$id'),
        ),
      );
      return Result.success(OrderModel.fromJson(data['data']));
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to mark in transit: $e');
    }
  }

  /// Mark order as failed with a reason.
  Future<Result<OrderModel>> markFailed(String id, String reason) async {
    try {
      final data = await _api.put<Map<String, dynamic>>(
        '/orders/$id/status',
        data: {'status': 'failed', 'failure_reason': reason},
        options: Options(
          headers: buildIdempotencyHeaders('orders_status_failed_$id'),
        ),
      );
      return Result.success(OrderModel.fromJson(data['data']));
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to mark as failed: $e');
    }
  }

  /// Submit proof of delivery (image URL + notes) and mark as delivered.
  Future<Result<OrderModel>> submitProofOfDelivery(
    String id, {
    required String imageUrl,
    String? notes,
    String? signatureUrl,
    String? recipientName,
  }) async {
    try {
      final normalizedImageUrl = imageUrl.trim();
      if (normalizedImageUrl.isEmpty) {
        return Result.failure('Proof of delivery image URL is required.');
      }

      final data = await _api.post<Map<String, dynamic>>(
        '/orders/$id/proof-of-delivery',
        data: buildSubmitProofOfDeliveryPayload(
          imageUrl: normalizedImageUrl,
          notes: notes,
          signatureUrl: signatureUrl,
          recipientName: recipientName,
        ),
      );
      return Result.success(OrderModel.fromJson(data['data']));
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to submit proof of delivery: $e');
    }
  }

  /// Assign a driver to an order.
  Future<Result<OrderModel>> assignDriver(
    String orderId,
    String driverId, {
    OrderModel? currentOrder,
  }) async {
    try {
      final normalizedOrderId = orderId.trim();
      final normalizedDriverId = driverId.trim();
      if (normalizedOrderId.isEmpty) {
        return Result.failure('Invalid order ID.');
      }
      if (normalizedDriverId.isEmpty) {
        return Result.failure('Invalid driver ID format.');
      }

      final response = await _api.put<Map<String, dynamic>>(
        '/orders/$normalizedOrderId/assign-driver',
        queryParameters: {'driver_id': normalizedDriverId},
        data: {
          'driver_id': normalizedDriverId,
          'assigned_driver_id': normalizedDriverId,
        },
      );

      final data = _extractOrderMap(response) ?? const <String, dynamic>{};
      final assignedDriver = _extractDriverMap(data);
      final assignedDriverId =
          data['assigned_driver_id'] ??
          data['driver_id'] ??
          data['assignedDriverId'] ??
          assignedDriver?['id'];
      final assignedDriverName =
          data['assigned_driver_name'] ??
          data['driver_name'] ??
          data['assignedDriverName'] ??
          assignedDriver?['full_name'] ??
          assignedDriver?['name'] ??
          assignedDriver?['display_name'];
      final isDriverAssigned =
          data['is_driver_assigned'] ?? (assignedDriverId != null);

      final responsePayload = Map<String, dynamic>.from(data);
      final assignedIdText = _asNonEmptyString(assignedDriverId);
      final assignedNameText = _asNonEmptyString(assignedDriverName);
      if (isDriverAssigned == true) {
        if (assignedIdText != null) {
          responsePayload['assigned_driver_id'] = assignedIdText;
        }
        if (assignedNameText != null) {
          responsePayload['assigned_driver_name'] = assignedNameText;
        }
      }

      if (currentOrder != null) {
        return Result.success(
          _mergeOrderFromPayload(
            baseOrder: currentOrder,
            payload: responsePayload,
            assignedDriverId: assignedIdText,
            assignedDriverName: assignedNameText,
            isDriverAssigned: isDriverAssigned == true,
          ),
        );
      }

      if (responsePayload.isNotEmpty) {
        return Result.success(OrderModel.fromJson(responsePayload));
      }

      // Last-resort fallback if backend omits body.
      return getOrderById(normalizedOrderId, noCache: true);
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        return Result.failure(e.message);
      }
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to assign driver: $e');
    }
  }

  Map<String, dynamic>? _extractOrderMap(dynamic payload) {
    final root = _toStringKeyedMap(payload);
    if (root == null) return null;

    final nested = _toStringKeyedMap(root['data']);
    return nested ?? root;
  }

  Map<String, dynamic>? _extractDriverMap(Map<String, dynamic> payload) {
    return _toStringKeyedMap(payload['assigned_driver']) ??
        _toStringKeyedMap(payload['driver']) ??
        _toStringKeyedMap(payload['assignedDriver']);
  }

  Map<String, dynamic>? _toStringKeyedMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  String? _asNonEmptyString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  OrderModel _mergeOrderFromPayload({
    required OrderModel baseOrder,
    required Map<String, dynamic> payload,
    required String? assignedDriverId,
    required String? assignedDriverName,
    required bool isDriverAssigned,
  }) {
    final mergedJson = <String, dynamic>{...baseOrder.toJson(), ...payload};
    if (isDriverAssigned) {
      if (assignedDriverId != null) {
        mergedJson['assigned_driver_id'] = assignedDriverId;
      }
      if (assignedDriverName != null) {
        mergedJson['assigned_driver_name'] = assignedDriverName;
      }
    }
    return OrderModel.fromJson(mergedJson);
  }

  /// Schedule a delivery slot.
  Future<Result<OrderModel>> scheduleOrder(
    String id,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final data = await _api.put<Map<String, dynamic>>(
        '/orders/$id/schedule',
        data: {
          'scheduled_slot_start': start.toIso8601String(),
          'scheduled_slot_end': end.toIso8601String(),
        },
      );
      return Result.success(OrderModel.fromJson(data['data']));
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to schedule order: $e');
    }
  }

  /// Request delivery confirmation from customer via SMS.
  Future<Result<OrderModel>> requestConfirmation(String id) async {
    try {
      final data = await _api.post<Map<String, dynamic>>(
        '/orders/$id/confirm-request',
      );
      return Result.success(OrderModel.fromJson(data['data']));
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to request confirmation: $e');
    }
  }

  /// Send a specific notification to the customer.
  Future<Result<void>> sendNotification(String id, String type) async {
    try {
      await _api.post<Map<String, dynamic>>(
        '/orders/$id/notify',
        queryParameters: {'type': type},
      );
      return Result.success(null);
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to send notification: $e');
    }
  }

  /// Initiate a return for a delivered order.
  Future<Result<OrderModel>> initiateReturn(String id, String reason) async {
    try {
      final data = await _api.post<Map<String, dynamic>>(
        '/orders/$id/return',
        queryParameters: {'reason': reason},
      );
      return Result.success(OrderModel.fromJson(data['data']));
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to initiate return: $e');
    }
  }

  /// Process refund for a return order.
  Future<Result<OrderModel>> processRefund(String id) async {
    try {
      final data = await _api.post<Map<String, dynamic>>('/orders/$id/refund');
      return Result.success(OrderModel.fromJson(data['data']));
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to process refund: $e');
    }
  }

  String? _normalizeDriverIdForApi(String? rawDriverId) {
    if (rawDriverId == null) return null;
    final trimmed = rawDriverId.trim();
    if (trimmed.isEmpty) return null;
    final withoutPrefix = trimmed.toUpperCase().startsWith('D-')
        ? trimmed.substring(2)
        : trimmed;
    final parsed = int.tryParse(withoutPrefix);
    if (parsed == null || parsed <= 0) {
      return null;
    }
    return parsed.toString();
  }

  List<String> _normalizeStatuses(List<OrderStatus>? statuses) {
    if (statuses == null || statuses.isEmpty) {
      return const [];
    }
    return statuses.map((status) => status.apiValue).toSet().toList();
  }

  List<dynamic> _extractOrdersList(dynamic response) {
    dynamic root = response;

    for (var depth = 0; depth < 3; depth++) {
      if (root is List) {
        return root;
      }

      final mapRoot = _toStringKeyedMap(root);
      if (mapRoot == null) {
        return const [];
      }

      for (final key in const [
        'data',
        'items',
        'orders',
        'results',
        'records',
        'rows',
      ]) {
        final candidate = mapRoot[key];
        if (candidate is List) {
          return candidate;
        }
      }

      root =
          mapRoot['data'] ??
          mapRoot['items'] ??
          mapRoot['orders'] ??
          mapRoot['results'];
    }

    return const [];
  }
}
