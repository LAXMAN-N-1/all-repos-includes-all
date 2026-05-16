import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/bid_service.dart';
import 'dart:async';

final shortlistedBidsProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, eventId) async {
  final service = ref.read(bidServiceProvider);
  return service.getShortlistedBids(eventId);
});

final bidPollingProvider = StateProvider.family<bool, int>((ref, eventId) {
  // Simple state to trigger UI updates when new bids are detected
  return false;
});

// A provider that polls for new bids every 5 seconds
final pushedBidsStreamProvider = StreamProvider.family<Map<String, dynamic>, int>((ref, eventId) async* {
  final service = ref.read(bidServiceProvider);
  
  while (true) {
    try {
      final data = await service.getShortlistedBids(eventId);
      yield data;
    } catch (e) {
      // Ignore errors during polling
    }
    await Future.delayed(const Duration(seconds: 5));
  }
});
