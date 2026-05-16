import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order_model.dart';
import '../../data/services/order_service.dart';

// State for Filters
final orderSearchFilterProvider = NotifierProvider<OrderSearchFilter, String>(OrderSearchFilter.new);
final orderStatusFilterProvider = NotifierProvider<OrderStatusFilter, String>(OrderStatusFilter.new);

class OrderSearchFilter extends Notifier<String> {
  @override String build() => '';
  void update(String val) => state = val;
}

class OrderStatusFilter extends Notifier<String> {
  @override String build() => 'All Status';
  void update(String val) => state = val;
}

// Orders List Provider
final ordersProvider = FutureProvider.autoDispose<List<Order>>((ref) async {
  final service = ref.watch(orderServiceProvider);
  final allOrders = await service.getOrders();
  
  final search = ref.watch(orderSearchFilterProvider).toLowerCase();
  final status = ref.watch(orderStatusFilterProvider);
  
  return allOrders.where((order) {
    // Search
    final matchesSearch = order.orderRef.toLowerCase().contains(search) || 
                          (order.eventName?.toLowerCase().contains(search) ?? false);
    
    // Status
    final matchesStatus = status == 'All Status' || order.status.toLowerCase() == status.toLowerCase();
    
    return matchesSearch && matchesStatus;
  }).toList();
});

// Stats Provider
final orderStatsProvider = Provider.autoDispose<Map<String, dynamic>>((ref) {
  final ordersAsync = ref.watch(ordersProvider);
  
  return ordersAsync.maybeWhen(
    data: (orders) {
      final total = orders.length;
      final pending = orders.where((o) => o.status.toLowerCase() == 'pending').length;
      final completed = orders.where((o) => o.status.toLowerCase() == 'completed').length;
      final totalValue = orders.fold<double>(0, (sum, o) => sum + o.amount);
      
      return {
        'total': total,
        'pending': pending,
        'completed': completed,
        'totalValue': totalValue,
      };
    },
    orElse: () => {
      'total': 0, 'pending': 0, 'completed': 0, 'totalValue': 0.0
    },
  );
});
