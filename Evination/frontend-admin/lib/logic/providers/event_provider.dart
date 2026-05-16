import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/event_summary_model.dart';
import '../../data/models/event_stats_model.dart';
import '../../data/services/event_service.dart';
import '../../data/models/event_model.dart';

// Search & Filter State
final eventSearchFilterProvider = NotifierProvider<EventSearchFilter, String>(EventSearchFilter.new);
final eventStatusFilterProvider = NotifierProvider<EventStatusFilter, String>(EventStatusFilter.new);

class EventSearchFilter extends Notifier<String> {
  @override String build() => '';
  void update(String val) => state = val;
}

class EventStatusFilter extends Notifier<String> {
  @override String build() => 'All Status';
  void update(String val) => state = val;
}

// Event List Provider
final eventListProvider = FutureProvider.autoDispose<List<EventSummary>>((ref) async {
  final service = ref.watch(eventServiceProvider);
  final search = ref.watch(eventSearchFilterProvider);
  final status = ref.watch(eventStatusFilterProvider);
  
  return service.getEvents(search: search, status: status);
});

// Event Stats Provider
final eventStatsProvider = FutureProvider.autoDispose<EventStats>((ref) async {
  final service = ref.watch(eventServiceProvider);
  return service.getEventStats();
});

// Event Detail Provider
final eventDetailProvider = FutureProvider.autoDispose.family<Event, int>((ref, id) async {
  final service = ref.watch(eventServiceProvider);
  return service.getEvent(id);
});
