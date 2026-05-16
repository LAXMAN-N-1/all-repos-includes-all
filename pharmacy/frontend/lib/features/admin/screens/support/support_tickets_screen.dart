import 'package:flutter/material.dart';

import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/admin/data/mock_support.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SupportTicketsScreen extends StatelessWidget {
  const SupportTicketsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AuraColors.glassBorder))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Support Tickets", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    const Text("Helpdesk & Issue Resolution", style: TextStyle(color: Colors.white60)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {}, 
                  icon: const Icon(Icons.add), 
                  label: const Text("Create Ticket"),
                  style: ElevatedButton.styleFrom(backgroundColor: AuraColors.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                _buildMetricCard("Open Tickets", "3", Colors.orange),
                const SizedBox(width: 20),
                _buildMetricCard("Avg Response", "2h 15m", Colors.blue),
                const SizedBox(width: 20),
                _buildMetricCard("Resolved Today", "12", Colors.green),
              ],
            ),
          ),

          // Tickets List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: mockTickets.length,
              separatorBuilder: (c, i) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final ticket = mockTickets[index];
                return _buildTicketCard(ticket);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AuraColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AuraColors.glassBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.analytics, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(SupportTicket ticket) {
    return Container(
      decoration: BoxDecoration(
        color: AuraColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AuraColors.glassBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getPriorityColor(ticket.priority).withOpacity(0.2),
          child: Text(
            ticket.orgName[0], 
            style: TextStyle(color: _getPriorityColor(ticket.priority), fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Text(ticket.subject, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            _buildStatusBadge(ticket.status),
            const SizedBox(width: 8),
            _buildPriorityBadge(ticket.priority),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text("${ticket.orgName} • ${DateFormat('MMM dd, hh:mm a').format(ticket.created)}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 4),
            Text(ticket.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70)),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white30),
        onTap: () {},
      ),
    );
  }

  Color _getPriorityColor(TicketPriority p) {
    switch (p) {
      case TicketPriority.urgent: return Colors.red;
      case TicketPriority.high: return Colors.orange;
      case TicketPriority.medium: return Colors.amber;
      case TicketPriority.low: return Colors.blue;
    }
  }

  Widget _buildStatusBadge(TicketStatus status) {
    Color color;
    switch (status) {
      case TicketStatus.open: color = Colors.green; break;
      case TicketStatus.pending: color = Colors.orange; break;
      case TicketStatus.resolved: color = Colors.blue; break;
      case TicketStatus.closed: color = Colors.grey; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
      child: Text(status.name.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPriorityBadge(TicketPriority p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(4)),
      child: Text(p.name.toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 10)),
    );
  }
}
