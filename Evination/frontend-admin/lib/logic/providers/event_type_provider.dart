import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/event_type_model.dart';
import '../../data/services/event_type_service.dart';

// Async Provider for List
final eventTypesProvider = FutureProvider.autoDispose<List<EventType>>((ref) async {
  final service = ref.watch(eventTypeServiceProvider);
  return service.getEventTypes();
});

// Stats Provider
final eventTypeStatsProvider = Provider.autoDispose<Map<String, dynamic>>((ref) {
  final typesAsync = ref.watch(eventTypesProvider);
  
  return typesAsync.maybeWhen(
    data: (types) {
      final totalTypes = types.length;
      final totalTagged = types.fold<int>(0, (sum, t) => sum + t.count);
      
      // Find most used
      String mostUsed = 'None';
      if (types.isNotEmpty) {
        final sorted = [...types]..sort((a, b) => b.count.compareTo(a.count));
        if (sorted.first.count > 0) {
           mostUsed = sorted.first.name;
        }
      }
      
      return {
        'totalTypes': totalTypes,
        'mostUsed': mostUsed,
        'tagged': totalTagged,
      };
    },
    orElse: () => {
      'totalTypes': 0,
      'mostUsed': 'Loading...',
      'tagged': 0,
    },
  );
});
