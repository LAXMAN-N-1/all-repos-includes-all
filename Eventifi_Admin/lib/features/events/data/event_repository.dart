import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:eventifi_admin/core/constants/api_constants.dart';
import 'package:eventifi_admin/core/network/dio_client.dart';
import 'package:eventifi_admin/features/events/domain/event_models.dart';

part 'event_repository.g.dart';

class EventRepository {
  final Dio _dio;

  EventRepository(this._dio);

  Future<List<Event>> getEvents() async {
    try {
      final response = await _dio.get(ApiConstants.events);
      final List<dynamic> data = response.data is List ? response.data : (response.data['data'] ?? []);
      return data.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Event> createEvent(CreateEventRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.events,
        data: request.toJson(),
      );
      return Event.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Event> updateEvent(int id, CreateEventRequest request) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.events}/$id',
        data: request.toJson(),
      );
      return Event.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEvent(int id) async {
    try {
      await _dio.delete('${ApiConstants.events}/$id');
    } catch (e) {
      rethrow;
    }
  }
}

@riverpod
EventRepository eventRepository(EventRepositoryRef ref) {
  return EventRepository(ref.watch(dioClientProvider));
}
