import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../models/event_manager_model.dart';

final eventManagerServiceProvider = Provider<EventManagerService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EventManagerService(apiClient);
});

class EventManagerService {
  final ApiClient _apiClient;

  EventManagerService(this._apiClient);

  Future<List<EventManager>> getEventManagers({
    String? availabilityStatus,
    int skip = 0,
    int limit = 100
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'skip': skip,
        'limit': limit,
      };
      if (availabilityStatus != null && availabilityStatus.isNotEmpty && availabilityStatus != 'All') {
        queryParams['availability_status'] = availabilityStatus;
      }

      final response = await _apiClient.get('/event-managers/', queryParameters: queryParams);
      final List<dynamic> data = response.data;
      return data.map((json) => EventManager.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load event managers: $e');
    }
  }

  // Future<EventManager> getManager(int id) ...
  // Future<void> createManager(...) ...
}
