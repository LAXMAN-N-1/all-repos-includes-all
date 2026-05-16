import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/order_tracking.dart';

class TrackingService {
  static Dio? _dio;

  /// Set Dio instance for API calls
  static void init(Dio dio) => _dio = dio;

  static Future<OrderTracking> getTrackingDetails(String orderId) async {
    try {
      if (_dio != null) {
        final response = await _dio!.get('/catalog/orders/$orderId/tracking');

        if (response.statusCode == 200) {
          final payload = response.data;
          final data = payload is Map && payload['data'] is Map
              ? Map<String, dynamic>.from(payload['data'] as Map)
              : payload is Map
                  ? Map<String, dynamic>.from(payload)
                  : <String, dynamic>{};
          return OrderTracking(
            orderId: orderId,
            trackingNumber:
                data['tracking_number'] ?? 'WZ-TRK-${orderId.split('-').last}',
            currentStatus: _parseStatus(data['current_status']),
            expectedDelivery: data['estimated_delivery_date'] != null
                ? DateTime.tryParse(
                        data['estimated_delivery_date'].toString()) ??
                    DateTime.now().add(const Duration(days: 2))
                : DateTime.now().add(const Duration(days: 2)),
            deliveryPartnerName:
                data['courier_name']?.toString() ?? 'Courier Partner',
            deliveryPartnerPhone: '',
            deliveryPartnerPhoto: '',
            timeline: _parseTimeline(data['events']),
            deliveryProofUrl: data['delivery_proof_url'],
          );
        }
      }
    } on DioException catch (e) {
      debugPrint('Tracking API error: ${e.message}');
    } catch (e) {
      debugPrint('Tracking error: $e');
    }

    // Fallback: return basic tracking with current status
    final now = DateTime.now();
    return OrderTracking(
      orderId: orderId,
      trackingNumber: 'WZ-TRK-${orderId.split('-').last}',
      currentStatus: OrderStatus.ordered,
      expectedDelivery: now.add(const Duration(days: 2)),
      deliveryPartnerName: 'Support Team',
      deliveryPartnerPhone: '+919000000000',
      deliveryPartnerPhoto: '',
      timeline: [
        TrackingEvent(
          status: OrderStatus.ordered,
          timestamp: now,
          location: 'Processing',
          description: 'Order is being processed.',
        ),
      ],
    );
  }

  static OrderStatus _parseStatus(dynamic status) {
    if (status == null) return OrderStatus.ordered;
    switch (status.toString().toLowerCase()) {
      case 'ordered':
        return OrderStatus.ordered;
      case 'packed':
        return OrderStatus.packed;
      case 'shipped':
        return OrderStatus.shipped;
      case 'out_for_delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      default:
        return OrderStatus.ordered;
    }
  }

  static List<TrackingEvent> _parseTimeline(dynamic timeline) {
    if (timeline == null || timeline is! List) return [];
    return (timeline as List).map((e) {
      return TrackingEvent(
        status: _parseStatus(e['status']),
        timestamp: e['timestamp'] != null
            ? DateTime.tryParse(e['timestamp'].toString()) ?? DateTime.now()
            : DateTime.now(),
        location: e['location']?.toString() ?? '',
        description: e['description']?.toString() ?? '',
      );
    }).toList();
  }
}
