import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'order_view_model.dart';
import '../../models/order_model.dart';
import '../../widgets/order_card.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF233D4C),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Consumer<OrderViewModel>(
        builder: (context, viewModel, child) {
          final history = viewModel.filteredHistory;

          if (history.isEmpty && !viewModel.isLoadingMore) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No order history found',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  if (viewModel.dateFilter != null ||
                      viewModel.statusFilter != null)
                    TextButton(
                      onPressed: viewModel.clearFilters,
                      child: const Text('Clear Filters'),
                    ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Active Filters Display
              if (viewModel.dateFilter != null ||
                  viewModel.statusFilter != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Colors.grey[100],
                  child: Row(
                    children: [
                      if (viewModel.dateFilter != null)
                        Chip(
                          label: Text(
                            '${DateFormat('MMM d').format(viewModel.dateFilter!.start)} - ${DateFormat('MMM d').format(viewModel.dateFilter!.end)}',
                          ),
                          onDeleted: () => viewModel.setDateFilter(null),
                        ),
                      const SizedBox(width: 8),
                      if (viewModel.statusFilter != null)
                        Chip(
                          label: Text(
                            viewModel.statusFilter.toString().split('.').last,
                          ),
                          onDeleted: () => viewModel.setStatusFilter(null),
                        ),
                      const Spacer(),
                      TextButton(
                        onPressed: viewModel.clearFilters,
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                ),

              // Order List
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (!viewModel.isLoadingMore &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                      viewModel.loadMoreHistory();
                      return true;
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        history.length + (viewModel.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == history.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final order = history[index];
                      return OrderCard(
                        order: order,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/order-details',
                            arguments: order,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const FilterBottomSheet(),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  DateTimeRange? _selectedDateRange;
  OrderStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<OrderViewModel>(context, listen: false);
    _selectedDateRange = viewModel.dateFilter;
    _selectedStatus = viewModel.statusFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Filter History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Date Range'),
            subtitle: Text(
              _selectedDateRange == null
                  ? 'All time'
                  : '${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d').format(_selectedDateRange!.end)}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: _selectedDateRange,
              );
              if (picked != null) {
                setState(() {
                  _selectedDateRange = picked;
                });
              }
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<OrderStatus>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('All Statuses')),
              DropdownMenuItem(
                value: OrderStatus.delivered,
                child: Text('Delivered'),
              ),
              DropdownMenuItem(
                value: OrderStatus.cancelled,
                child: Text('Cancelled'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final viewModel = Provider.of<OrderViewModel>(
                context,
                listen: false,
              );
              viewModel.setDateFilter(_selectedDateRange);
              viewModel.setStatusFilter(_selectedStatus);
              Navigator.pop(context);
            },
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }
}
