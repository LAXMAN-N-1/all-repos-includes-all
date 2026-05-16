import 'package:flutter/material.dart';

import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/admin/data/mock_final_modules.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Notification Center", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                TextButton(onPressed: () {}, child: const Text("Mark all as read")),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AuraColors.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AuraColors.glassBorder),
                ),
                child: ListView.separated(
                  itemCount: mockNotifications.length,
                  separatorBuilder: (c, i) => const Divider(color: Colors.white12, height: 1),
                  itemBuilder: (context, index) {
                    final notif = mockNotifications[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getColor(notif.type).withOpacity(0.2),
                        child: Icon(_getIcon(notif.type), color: _getColor(notif.type), size: 20),
                      ),
                      title: Text(notif.title, style: TextStyle(color: Colors.white, fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold)),
                      subtitle: Text(notif.message, style: const TextStyle(color: Colors.white70)),
                      trailing: Text(notif.time, style: const TextStyle(color: Colors.white30, fontSize: 12)),
                      tileColor: notif.isRead ? null : AuraColors.primary.withOpacity(0.05),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(String type) {
    switch (type) {
      case "Alert": return Colors.red;
      case "Success": return Colors.green;
      default: return Colors.blue;
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case "Alert": return Icons.warning;
      case "Success": return Icons.check_circle;
      default: return Icons.info;
    }
  }
}
