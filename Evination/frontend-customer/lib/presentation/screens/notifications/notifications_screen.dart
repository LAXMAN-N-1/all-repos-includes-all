import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers/notification/notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Hero Section
            Container(
              color: AppColors.sunflowerYellow,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 60),
              child: Column(
                children: [
                   Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: AppColors.crimsonSilk,
                       borderRadius: BorderRadius.circular(16),
                     ),
                     child: Stack(
                       alignment: Alignment.center,
                       children: [
                         const Icon(Icons.notifications_outlined, size: 32, color: AppColors.primaryBlack),
                         // Badge showing unread count
                         if (notificationsAsync.value != null)
                           Positioned(
                             top: 0,
                             right: 0,
                             child: Container(
                               padding: const EdgeInsets.all(4),
                               decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                               child: Text(
                                 '${notificationsAsync.value!.where((n) => !n.isRead).length}',
                                 style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                               ),
                             ),
                           ),
                       ],
                     ),
                   ),
                   const SizedBox(height: 24),
                  Text(
                    'Notifications',
                    style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Stay updated with your bookings and bids',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // 2. Stats & Filters
             Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      _buildStat(
                        notificationsAsync.when(
                          data: (data) => data.length.toString(), 
                          error: (_, __) => '-', 
                          loading: () => '-'
                        ), 
                        'Total', color: AppColors.primaryBlack
                      ),
                      const VerticalDivider(width: 48, thickness: 1, color: Colors.grey),
                      _buildStat(
                        notificationsAsync.when(
                          data: (data) => data.where((n) => !n.isRead).length.toString(), 
                          error: (_, __) => '-', 
                          loading: () => '-'
                        ), 
                        'Unread', color: Colors.red
                      ),
                      
                      const Spacer(),
                      if (MediaQuery.of(context).size.width > 600) ...[
                        _buildFilterBtn('All', true),
                        const SizedBox(width: 12),
                        _buildFilterBtn('Unread', false),
                        const SizedBox(width: 12),
                         ElevatedButton.icon(
                           onPressed: () {},
                           icon: const Icon(Icons.done_all, size: 16),
                           label: const Text('Mark All Read'),
                           style: ElevatedButton.styleFrom(
                             backgroundColor: AppColors.success,
                             foregroundColor: Colors.white,
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                           ),
                         ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // 3. Notification List
            Padding(
               padding: const EdgeInsets.symmetric(horizontal: 24),
               child: notificationsAsync.when(
                 data: (notifications) => Column(
                   children: notifications.map((n) => _buildNotificationCard(n, context)).toList(),
                 ),
                 error: (e, st) => Center(child: Text('Error: $e')),
                 loading: () => const Center(child: CircularProgressIndicator(color: AppColors.crimsonSilk)),
               ),
            ),
             
             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStat(String value, String label, {Color? color}) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color ?? AppColors.crimsonSilk)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildFilterBtn(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.crimsonSilk : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? AppColors.primaryBlack : Colors.grey[600])),
    );
  }

  Widget _buildNotificationCard(dynamic n, BuildContext context) {
    // n is NotificationModel
    Color iconBg;
    Color iconColor;
    IconData icon;

    switch (n.type) {
      case 'success':
        iconBg = const Color(0xFFE8F5E9);
        iconColor = AppColors.success;
        icon = Icons.check_circle_outline;
        break;
      case 'info':
        iconBg = const Color(0xFFE3F2FD);
        iconColor = AppColors.info;
        icon = Icons.assignment_outlined;
        break;
      case 'warning':
        iconBg = const Color(0xFFFFF8E1);
        iconColor = AppColors.warning;
        icon = Icons.payment;
        break;
      case 'error':
        iconBg = const Color(0xFFFFEBEE);
        iconColor = AppColors.error;
        icon = Icons.cancel_outlined;
        break;
      default:
        iconBg = Colors.grey[100]!;
        iconColor = Colors.grey[700]!;
        icon = Icons.notifications_none;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: !n.isRead ? Border.all(color: AppColors.crimsonSilk, width: 2) : null,
        boxShadow: [BoxShadow(color: AppColors.primaryBlack.withOpacity(0.05), blurRadius: 10)],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Expanded(child: Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                         if (!n.isRead) 
                           Container(
                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                             decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                             child: const Text('NEW', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                           ),
                       ],
                     ),
                     const SizedBox(height: 8),
                     Text(n.message, style: GoogleFonts.inter(color: Colors.grey[800], height: 1.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              // Format time simply for now
              Text('${DateTime.now().difference(n.timestamp).inHours} hours ago', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              const Spacer(),
              if (n.type == 'success' || n.type == 'warning')
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_forward, size: 16, color: AppColors.primaryBlack),
                  label: const Text('View Details', style: TextStyle(color: AppColors.primaryBlack, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
