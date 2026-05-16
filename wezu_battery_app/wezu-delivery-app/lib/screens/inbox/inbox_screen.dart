import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../repositories/notification_repository.dart';
import '../../models/notification_model.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  int _selectedTab = 0; // 0=All, 1=Messages, 2=Alerts, 3=Updates

  static const _tabs = ['All', 'Messages', 'Alerts', 'Updates'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Inbox',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Consumer<NotificationRepository>(
                    builder: (ctx, repo, _) => IconButton(
                      icon: const Icon(Icons.archive_outlined, color: Colors.black),
                      onPressed: repo.markAllAsRead,
                      tooltip: 'Mark all as read',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Filter tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final isSelected = _selectedTab == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTab = i),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        _tabs[i],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0xFFE5E5E5)),

            // Content
            Expanded(
              child: Consumer<NotificationRepository>(
                builder: (ctx, repo, _) {
                  final all = repo.notifications;
                  final filtered = _filterNotifications(all);

                  if (filtered.isEmpty) {
                    return _EmptyInbox();
                  }

                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFFE5E5E5)),
                    itemBuilder: (ctx, i) {
                      final n = filtered[i];
                      return _NotificationTile(
                        notification: n,
                        onTap: () => repo.markAsRead(n.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<NotificationItem> _filterNotifications(List<NotificationItem> all) {
    switch (_selectedTab) {
      case 0:
        return all;
      case 1: // Messages → order notifications
        return all
            .where((n) => n.type == NotificationType.order)
            .toList();
      case 2: // Alerts → system notifications
        return all
            .where((n) => n.type == NotificationType.system)
            .toList();
      case 3: // Updates → promotions
        return all
            .where((n) => n.type == NotificationType.promotion)
            .toList();
      default:
        return all;
    }
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────

class _EmptyInbox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.mail_outline_rounded,
              size: 40,
              color: Color(0xFF4285F4),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "You're up to date",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Here is where you can find updates,\nalerts, messages and more',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B6B6B),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Notification Tile ─────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final NotificationItem notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isUnread ? const Color(0xFFF8F8F8) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: _iconBg(notification.type),
              child: Icon(
                _icon(notification.type),
                color: _iconColor(notification.type),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight:
                          isUnread ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.body,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B6B6B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeAgo(notification.timestamp),
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFFAAAAAA)),
                  ),
                ],
              ),
            ),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _icon(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return Icons.local_shipping_rounded;
      case NotificationType.promotion:
        return Icons.card_giftcard_rounded;
      case NotificationType.system:
        return Icons.info_rounded;
    }
  }

  Color _iconBg(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return const Color(0xFFF0F0F0);
      case NotificationType.promotion:
        return const Color(0xFFFFF3E0);
      case NotificationType.system:
        return const Color(0xFFE3F2FD);
    }
  }

  Color _iconColor(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return Colors.black;
      case NotificationType.promotion:
        return const Color(0xFFFD802E);
      case NotificationType.system:
        return const Color(0xFF2196F3);
    }
  }

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
