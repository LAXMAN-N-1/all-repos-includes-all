import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:eventifi_admin/features/events/data/event_repository.dart';
import 'package:eventifi_admin/features/events/domain/event_models.dart';

part 'event_controller.g.dart';

@riverpod
class EventController extends _$EventController {
  @override
  FutureOr<List<Event>> build() async {
    return _fetchEvents();
  }

  Future<List<Event>> _fetchEvents() async {
    final repository = ref.read(eventRepositoryProvider);
    return await repository.getEvents();
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchEvents());
  }

  Future<void> createEvent(CreateEventRequest request) async {
    final repository = ref.read(eventRepositoryProvider);
    await repository.createEvent(request);
    ref.invalidateSelf();
  }

  Future<void> updateEvent(int id, CreateEventRequest request) async {
    final repository = ref.read(eventRepositoryProvider);
    await repository.updateEvent(id, request);
    ref.invalidateSelf();
  }

  Future<void> deleteEvent(int id) async {
    final repository = ref.read(eventRepositoryProvider);
    await repository.deleteEvent(id);
    ref.invalidateSelf();
  }
}
