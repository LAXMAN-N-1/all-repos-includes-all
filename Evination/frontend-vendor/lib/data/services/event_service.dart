import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../models/event_model.dart';
import '../models/event_summary_model.dart'; // Import Summary Model
import '../models/event_stats_model.dart';   // Import Stats Model
import 'package:dio/dio.dart';

final eventServiceProvider = Provider<EventService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EventService(apiClient);
});

class EventService {
  final ApiClient _apiClient;

  EventService(this._apiClient);

  Future<List<EventSummary>> getEvents({
    String? status,
    String? search,
    int skip = 0, 
    int limit = 100
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'skip': skip, 
        'limit': limit,
      };
      if (status != null && status != 'All Status' && status != 'all') {
         queryParams['status'] = status;
      }
      if (search != null && search.isNotEmpty) {
         queryParams['search'] = search;
      }

      final response = await _apiClient.get('/events/', queryParameters: queryParams);
      final List<dynamic> data = response.data;
      return data.map((json) => EventSummary.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load events: $e');
    }
  }

  Future<EventStats> getEventStats() async {
    try {
      final response = await _apiClient.get('/events/stats');
      return EventStats.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load stats: $e');
    }
  }
}
