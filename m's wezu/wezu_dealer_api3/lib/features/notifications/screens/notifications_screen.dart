import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';
import '../../../core/utils/time_utils.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});
  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  String _filter = 'All';

  @override
  void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward(); }
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  Widget _stagger(int i, {required Widget child}) {
    final begin = i * 0.12; final end = (begin + 0.4).clamp(0.0, 1.0);
    return AnimatedBuilder(animation: _c, builder: (c, _) {
      final t = Curves.easeOut.transform(((_c.value - begin) / (end - begin)).clamp(0.0, 1.0));
      return Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 16 * (1 - t)), child: child));
    });
  }

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'alert': return LucideIcons.alertTriangle;
      case 'promo': return LucideIcons.gift;
      case 'info': return LucideIcons.info;
      default: return LucideIcons.bell;
    }
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'alert': return AppColors.red;
      case 'promo': return AppColors.purple;
      case 'info': return AppColors.cyan;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);
    final all = state.notifications;
    final unread = state.unreadCount;

    // Filter
    final filtered = _filter == 'All'
        ? all
        : _filter == 'Unread'
            ? all.where((n) => !n.isRead).toList()
            : all.where((n) => n.type.toLowerCase() == _filter.toLowerCase()).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        _stagger(0, child: Row(children: [
          const Icon(LucideIcons.bell, size: 22, color: AppColors.primary),
          const SizedBox(width: 10),
          const Text('Notifications', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(width: 12),
          if (unread > 0) Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.red.withValues(alpha: 0.3))),
            child: Text('$unread unread', style: const TextStyle(fontSize: 11, color: AppColors.red, fontWeight: FontWeight.w700)),
          ),
          const Spacer(),
          if (unread > 0)
            TextButton.icon(icon: const Icon(LucideIcons.checkCheck, size: 14), label: const Text('Mark All Read', style: TextStyle(fontSize: 12)),
              onPressed: () => ref.read(notificationsProvider.notifier).markAllAsRead()),
          const SizedBox(width: 8),
          TextButton.icon(icon: const Icon(LucideIcons.refreshCw, size: 14), label: const Text('Refresh', style: TextStyle(fontSize: 12)),
            onPressed: () => ref.read(notificationsProvider.notifier).refresh()),
        ])),
        const SizedBox(height: 16),

        // Filter Pills
        _stagger(1, child: Wrap(spacing: 6, children: [
          ...['All', 'Unread', 'alert', 'info', 'promo'].map((f) {
            final sel = _filter == f;
            final label = f == 'All' || f == 'Unread' ? f : f[0].toUpperCase() + f.substring(1);
            final c = f == 'Unread' ? AppColors.red : f == 'All' ? AppColors.primary : _typeColor(f);
            return GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? c.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: sel ? c.withValues(alpha: 0.3) : AppColors.border),
                ),
                child: Text(label, style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? c : AppColors.textSecondary)),
              ),
            );
          }),
        ])),
        const SizedBox(height: 16),

        // Notification List
        _stagger(2, child: state.isLoading
          ? const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
          : state.error != null
            ? Center(child: Padding(padding: const EdgeInsets.all(40), child: Text('Error: ${state.error}', style: const TextStyle(color: AppColors.red))))
            : filtered.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No notifications', style: TextStyle(color: AppColors.textSecondary))))
              : Column(children: filtered.map((n) {
                  final iconColor = _typeColor(n.type);
                  final timeAgo = _timeAgo(n.createdAt);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        if (!n.isRead) ref.read(notificationsProvider.notifier).markAsRead(n.id);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: n.isRead ? AppColors.cardBg : AppColors.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: n.isRead ? AppColors.border : iconColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                            child: Icon(_typeIcon(n.type), size: 18, color: iconColor),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Expanded(child: Text(n.title, style: TextStyle(fontSize: 14, fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700, color: AppColors.textPrimary))),
                              if (!n.isRead) Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: iconColor, boxShadow: [BoxShadow(color: iconColor.withValues(alpha: 0.4), blurRadius: 4)])),
                            ]),
                            const SizedBox(height: 4),
                            Text(n.message, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Text(timeAgo, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                          ])),
                        ]),
                      ),
                    ),
                  );
                }).toList()),
        ),
      ]),
    );
  }

  String _timeAgo(String dateStr) => TimeUtils.timeAgo(dateStr);
}
