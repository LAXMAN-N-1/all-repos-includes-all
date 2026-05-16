import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../repositories/order_repository.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderRepository _orderRepository;

  DateTimeRange? _dateFilter;
  OrderStatus? _statusFilter;
  bool _isLoadingMore = false;

  OrderViewModel({required OrderRepository orderRepository})
    : _orderRepository = orderRepository {
    // Listen to repository changes
    _orderRepository.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _orderRepository.removeListener(notifyListeners);
    super.dispose();
  }

  List<Order> get _orders => _orderRepository.orders;

  List<Order> get activeOrders => _orders
      .where(
        (order) =>
            order.status != OrderStatus.delivered &&
            order.status != OrderStatus.cancelled,
      )
      .toList();

  List<Order> get orderHistory => _orders
      .where(
        (order) =>
            order.status == OrderStatus.delivered ||
            order.status == OrderStatus.cancelled,
      )
      .toList();

  DateTimeRange? get dateFilter => _dateFilter;
  OrderStatus? get statusFilter => _statusFilter;
  bool get isLoadingMore => _isLoadingMore;

  void setDateFilter(DateTimeRange? range) {
    _dateFilter = range;
    notifyListeners();
  }

  void setStatusFilter(OrderStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void clearFilters() {
    _dateFilter = null;
    _statusFilter = null;
    notifyListeners();
  }

  List<Order> get filteredHistory {
    return _orders.where((order) {
      // 1. Basic History Filter (Delivered/Cancelled)
      bool isHistory =
          order.status == OrderStatus.delivered ||
          order.status == OrderStatus.cancelled;
      if (!isHistory) return false;

      // 2. Date Filter
      if (_dateFilter != null) {
        final start = _dateFilter!.start;
        final end = _dateFilter!.end.add(const Duration(days: 1)); // End of day
        if (order.timestamp.isBefore(start) || order.timestamp.isAfter(end)) {
          return false;
        }
      }

      // 3. Status Filter
      if (_statusFilter != null && order.status != _statusFilter) {
        return false;
      }

      return true;
    }).toList();
  }

  Future<void> loadMoreHistory() async {
    if (_isLoadingMore) return;
    _isLoadingMore = true;
    notifyListeners();

    await _orderRepository.fetchMoreHistory();

    _isLoadingMore = false;
    notifyListeners();
  }
}
