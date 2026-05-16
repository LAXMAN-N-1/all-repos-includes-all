import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../models/event_type_model.dart';

final eventTypeServiceProvider = Provider<EventTypeService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EventTypeService(apiClient);
});

class EventTypeService {
  final ApiClient _apiClient;

  EventTypeService(this._apiClient);

  Future<List<EventType>> getEventTypes({int? categoryId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (categoryId != null) {
        queryParams['category_id'] = categoryId;
      }
      
      final response = await _apiClient.get('/event-types/', queryParameters: queryParams);
      final List<dynamic> data = response.data;
      return data.map((json) => EventType.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load event types: $e');
    }
  }

  // Future<void> createEventType(...)
  // Future<void> updateEventType(...)
  // Future<void> deleteEventType(...)
}
