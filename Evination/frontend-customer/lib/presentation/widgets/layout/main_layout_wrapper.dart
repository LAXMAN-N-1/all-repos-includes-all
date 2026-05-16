import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../navigation/sidebar_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../providers/booking_provider.dart';
import '../../providers/bid_provider.dart';
import 'package:go_router/go_router.dart';

class MainLayoutWrapper extends ConsumerWidget {
  final Widget child;

  const MainLayoutWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    
    // Listen for pushed bids on the latest booking
    final bookings = ref.watch(bookingProvider);
    if (bookings.isNotEmpty) {
      final latestBooking = bookings.last;
      // We assume booking ID can be parsed to int for the demo backend
      final eventId = int.tryParse(latestBooking.id) ?? 1; 
      
      ref.listen(pushedBidsStreamProvider(eventId), (previous, next) {
        if (next.hasValue) {
          final data = next.value!;
          final topBids = data['top_bids'] as List;
          if (topBids.isNotEmpty) {
            // Show notification
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🎉 Admin pushed ${topBids.length} bids for your event: ${data['event_name']}'),
                backgroundColor: AppColors.crimsonSilk,
                duration: const Duration(seconds: 10),
                action: SnackBarAction(
                  label: 'VIEW BIDS',
                  textColor: Colors.black,
                  onPressed: () => context.push('/bid_selection/${latestBooking.id}'),
                ),
              ),
            );
          }
        }
      });
    }

    final horizontalPadding = ResponsiveHelper.valueByDevice<double>(
      context,
      mobile: 16,
      tablet: 24,
      desktop: 48,
    );

    return Scaffold(
      appBar: !isDesktop
          ? AppBar(
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(color: AppColors.darkCharcoal),
              title: Text('EVE NATION',
                  style: TextStyle(color: AppColors.sunflowerYellow, fontWeight: FontWeight.bold, fontSize: 16)),
              elevation: 0,
              surfaceTintColor: Colors.transparent,
            )
          : null,
      drawer: !isDesktop ? const Drawer(child: SidebarWidget()) : null,
      body: Row(
        children: [
          if (isDesktop) const SidebarWidget(),
          Expanded(
            child: Container(
              // Content - handling its own scrolling and padding
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
