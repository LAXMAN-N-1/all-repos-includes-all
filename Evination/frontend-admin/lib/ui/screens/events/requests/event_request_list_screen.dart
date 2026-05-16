import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_panel/theme/app_theme.dart';
import 'package:admin_panel/logic/providers/event_provider.dart';
import 'package:admin_panel/data/models/event_summary_model.dart';

class EventRequestListScreen extends ConsumerStatefulWidget {
  const EventRequestListScreen({super.key});

  @override
  ConsumerState<EventRequestListScreen> createState() => _EventRequestListScreenState();
}

class _EventRequestListScreenState extends ConsumerState<EventRequestListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      // Update filter based on tab
      // 0: All, 1: Pending, 2: Planning/Quoting, 3: Confirmed
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventListAsync = ref.watch(eventListProvider);

    return Scaffold(
      body: Column(
        children: [
          // Header Area
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Event Requests', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Manage incoming event requests and inquiries', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {}, // Create request manually
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New Request'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Tabs
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppTheme.primary600,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppTheme.primary600,
                  tabAlignment: TabAlignment.start,
                  tabs: const [
                    Tab(text: 'All Requests'),
                    Tab(text: 'Pending Action'),
                    Tab(text: 'In Progress'),
                    Tab(text: 'Confirmed'),
                  ],
                ),
              ],
            ),
          ),
          
          // Filters Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by ID, Name, or Client...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildFilterBtn(Icons.filter_list, 'Filter'),
                const SizedBox(width: 8),
                _buildFilterBtn(Icons.sort, 'Sort'),
              ],
            ),
          ),

          // Content
          Expanded(
            child: eventListAsync.when(
              data: (events) => TabBarView(
                controller: _tabController,
                children: [
                  _buildRequestTable(events), // All
                  _buildRequestTable(events.where((e) => e.status == 'Pending').toList()),
                  _buildRequestTable(events.where((e) => e.status == 'Planning').toList()),
                  _buildRequestTable(events.where((e) => e.status == 'Confirmed').toList()),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e,s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBtn(IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildRequestTable(List<EventSummary> events) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No requests found', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
          dataRowMinHeight: 60,
          dataRowMaxHeight: 72,
          columns: const [
            DataColumn(label: Text('Request Info')),
            DataColumn(label: Text('Date & Venue')),
            DataColumn(label: Text('Budget')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Submitted')),
            DataColumn(label: Text('Actions')),
          ],
          rows: events.map((e) {
            return DataRow(
              cells: [
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(e.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text('${e.category} • ID: #REQ-${e.id}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(e.date, style: const TextStyle(fontSize: 13)),
                      Text(e.location, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                DataCell(Text('₹${(e.budget/1000).toStringAsFixed(0)}K')),
                DataCell(_StatusBadge(status: e.status)),
                DataCell(
                   Text('2 days ago', style: TextStyle(color: Colors.grey[600], fontSize: 13)), // Mock data
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_red_eye, color: AppTheme.primary600, size: 20),
                        tooltip: 'View Details',
                        onPressed: () {
                           context.go('/admin/events/${e.id}');
                        },
                      ),
                      if (e.status == 'Planning' || e.status == 'Pending')
                        IconButton(
                          icon: const Icon(Icons.gavel_rounded, color: Colors.orange, size: 20),
                          tooltip: 'Curate Bids',
                          onPressed: () {
                             context.push('/admin/bidding/curate/${e.id}');
                          },
                        ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;
    
    switch (status) {
      case 'Pending': color = Colors.orange[700]!; bg = Colors.orange[50]!; break;
      case 'Planning': color = Colors.blue[700]!; bg = Colors.blue[50]!; break;
      case 'Confirmed': color = Colors.green[700]!; bg = Colors.green[50]!; break;
      case 'Completed': color = Colors.grey[700]!; bg = Colors.grey[50]!; break;
      case 'Cancelled': color = Colors.red[700]!; bg = Colors.red[50]!; break;
      default: color = Colors.grey[700]!; bg = Colors.grey[50]!; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
