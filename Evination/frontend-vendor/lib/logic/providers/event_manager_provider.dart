import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/event_manager_model.dart';
import '../../data/services/event_manager_service.dart';

// Filter State
// Filter State
final managerSearchProvider = NotifierProvider<ManagerSearchFilter, String>(ManagerSearchFilter.new);

class ManagerSearchFilter extends Notifier<String> {
  @override String build() => '';
  void update(String val) => state = val;
}

// Async Notifier or Future Provider
final eventManagersProvider = FutureProvider.autoDispose<List<EventManager>>((ref) async {
  final service = ref.watch(eventManagerServiceProvider);
  // Fetch all managers first, filter logic can be client-side for search for better UX if list is small,
  // or server side. For search, client side is smoother for small lists.
  // Backend supports 'availability_status' filter but not 'search' by name yet?
  // Let's fetch all (limit 100) and filter by name on client for now.
  
  final managers = await service.getEventManagers();
  
  final search = ref.watch(managerSearchProvider).toLowerCase();
  
  if (search.isEmpty) {
    return managers;
  }
  
  return managers.where((m) => 
    m.name.toLowerCase().contains(search) || 
    m.email.toLowerCase().contains(search)
  ).toList();
});

// Stats Provider (Derived)
final managerStatsProvider = Provider.autoDispose<Map<String, dynamic>>((ref) {
  final managersAsync = ref.watch(eventManagersProvider);
  
  return managersAsync.maybeWhen(
    data: (managers) {
      final total = managers.length;
      final available = managers.where((m) => m.status == 'Available').length;
      final activeEvents = managers.fold<int>(0, (sum, m) => sum + m.activeEvents);
      final totalRating = managers.fold<double>(0, (sum, m) => sum + m.rating);
      final avgRating = total > 0 ? totalRating / total : 0.0;
      
      return {
        'total': total,
        'available': available,
        'activeEvents': activeEvents,
        'avgRating': avgRating,
      };
    },
    orElse: () => {
      'total': 0,
      'available': 0,
      'activeEvents': 0,
      'avgRating': 0.0,
    },
  );
});
