import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:vendor_app/data/datasources/vendor_bidding_source.dart';
import 'package:vendor_app/data/models/bidding/lead_model.dart';
import 'package:vendor_app/data/models/notification_model.dart';

// Assume a generic dio provider exists, similar to customer app. 
// If not, we'll access it from main/core.
// For now, creating a local one or assuming global.
// Checking file structure... we have 'core'.

import 'package:vendor_app/core/api_client.dart';

final vendorBiddingSourceProvider = Provider<VendorBiddingSource>((ref) {
  return VendorBiddingSource(ref.watch(apiClientProvider));
});

final leadsProvider = StreamProvider<List<LeadModel>>((ref) async* {
  final source = ref.watch(vendorBiddingSourceProvider);
  while (true) {
    try {
      final leads = await source.getLeads();
      yield leads;
    } catch (e) {
      // Yield empty list on error, keep polling
      yield [];
    }
    await Future.delayed(const Duration(seconds: 5));
  }
});

final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) async* {
  final source = ref.watch(vendorBiddingSourceProvider);
  while (true) {
    final notifs = await source.getNotifications();
    yield notifs;
    await Future.delayed(const Duration(seconds: 10)); // Poll every 10s
  }
});

class BidSubmissionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    return;
  }

  Future<void> submitBid(int eventId, double amount, String proposal) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(vendorBiddingSourceProvider).submitBid(eventId, amount, proposal);
      state = const AsyncValue.data(null);
      // Refresh leads after submission
      ref.invalidate(leadsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final bidSubmissionProvider = AsyncNotifierProvider<BidSubmissionController, void>(() {
  return BidSubmissionController();
});

