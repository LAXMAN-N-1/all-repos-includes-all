import 'package:flutter/material.dart';
import '../../widgets/common_button.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String filter = 'all'; // all, unread, read, bid, event, vendor...
  
  List<Map<String, dynamic>> notifications = [
    {
      'id': 1,
      'type': 'bid',
      'title': 'New Bid Received',
      'message': 'Elegant Caterers Inc. submitted a bid for Annual Tech Summit 2025 - ₹45,00,000',
      'time': '5 minutes ago',
      'read': false,
      'priority': 'high',
    },
    {
      'id': 2,
      'type': 'event',
      'title': 'Event Deadline Approaching',
      'message': 'Smith & Jones Wedding - Final payment due in 3 days.',
      'time': '1 hour ago',
      'read': false,
      'priority': 'medium',
    },
    {
      'id': 3,
      'type': 'vendor',
      'title': 'Vendor Approved',
      'message': 'Royal Events Co. has been approved.',
      'time': '2 hours ago',
      'read': true,
      'priority': 'low',
    },
    // Add more mock data if needed to scroll
  ];

  @override
  Widget build(BuildContext context) {
    int unreadCount = notifications.where((n) => !n['read']).length;

    List<Map<String, dynamic>> filteredList = notifications.where((n) {
      if (filter == 'all') return true;
      if (filter == 'unread') return !n['read'];
      if (filter == 'read') return n['read'];
      return n['type'] == filter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Notifications', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    Text(
                      unreadCount == 0 ? "You're all caught up!" : "$unreadCount unread notifications",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                Row(
                  children: [
                     CommonButton(
                      text: 'Mark All Read',
                      icon: Icons.done_all,
                      variant: ButtonVariant.outline,
                      onPressed: () {
                        setState(() {
                          for (var n in notifications) {
                            n['read'] = true;
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    CommonButton(
                      text: 'Clear All',
                      icon: Icons.delete_outline,
                      variant: ButtonVariant.destructive, // Red in practice via variant or style override,
                      // assuming destuctive styling or similar
                      onPressed: () {
                         setState(() {
                           notifications.clear();
                         });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Top Stats (Simplified for Flutter)
            Row(
              children: [
                _buildStatCard('Total', '${notifications.length}', Colors.grey),
                const SizedBox(width: 16),
                _buildStatCard('Unread', '$unreadCount', Colors.amber),
                const SizedBox(width: 16),
                _buildStatCard('High Priority', '${notifications.where((n) => n['priority'] == 'high').length}', Colors.red),
              ],
            ),
            const SizedBox(height: 24),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                   _buildFilterChip('All', 'all'),
                   _buildFilterChip('Unread', 'unread'),
                   _buildFilterChip('Read', 'read'),
                   _buildFilterChip('Bids', 'bid'),
                   _buildFilterChip('Events', 'event'),
                   _buildFilterChip('Vendors', 'vendor'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // List
            if (filteredList.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: Column(
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No notifications', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
              ...filteredList.map((n) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: n['read'] ? Colors.white : const Color(0xFFF3E8FF), // Purple tint for unread
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: n['read'] ? Colors.grey[100]! : Colors.amber[100]!),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getTypeColor(n['type']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_getTypeIcon(n['type']), color: _getTypeColor(n['type']), size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(n['title'], style: const TextStyle(fontWeight: FontWeight.bold))),
                                if (!n['read'])
                                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(n['message'], style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(n['time'], style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getPriorityColor(n['priority']).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(n['priority'], style: TextStyle(color: _getPriorityColor(n['priority']), fontSize: 10)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(n['read'] ? Icons.check_circle_outline : Icons.circle_outlined, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                n['read'] = !n['read'];
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                notifications.remove(n);
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    bool isSelected = filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () => setState(() => filter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFfdb913) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? const Color(0xFFfdb913) : Colors.grey[300]!),
          ),
          child: Text(
            label,
            style: TextStyle(color: isSelected ? Colors.white : Colors.grey[700], fontSize: 13),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch(type) {
      case 'bid': return Colors.orange;
      case 'event': return Colors.amber;
      case 'vendor': return Colors.blue;
      case 'order': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch(type) {
      case 'bid': return Icons.gavel;
      case 'event': return Icons.calendar_today;
      case 'vendor': return Icons.store;
      case 'order': return Icons.shopping_cart;
      default: return Icons.notifications;
    }
  }

  Color _getPriorityColor(String priority) {
    switch(priority) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      case 'low': return Colors.blue;
      default: return Colors.grey;
    }
  }
}
