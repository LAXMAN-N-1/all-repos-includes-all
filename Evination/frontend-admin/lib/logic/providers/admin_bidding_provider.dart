import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/admin_bidding_source.dart';
import '../../data/models/bidding/admin_bid_model.dart';

import 'package:admin_panel/core/api_client.dart';

final adminBiddingSourceProvider = Provider<AdminBiddingSource>((ref) {
  return AdminBiddingSource(ref.watch(apiClientProvider));
});

final requestBidsProvider = StreamProvider.family<List<AdminBidModel>, int>((ref, eventId) async* {
  final source = ref.watch(adminBiddingSourceProvider);
  while (true) {
    try {
      final bids = await source.getBidsForRequest(eventId);
      yield bids;
    } catch (e) {
      yield [];
    }
    await Future.delayed(const Duration(seconds: 5));
  }
});

class CurationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    return;
  }

  Future<void> curate(int bidId, String action) async {
    state = const AsyncValue.loading();
    try {
      final source = ref.read(adminBiddingSourceProvider);
      await source.curateBid(bidId, action);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> pushToCustomer(int eventId, List<int> bidIds) async {
    state = const AsyncValue.loading();
    try {
      final source = ref.read(adminBiddingSourceProvider);
      await source.pushToCustomer(eventId, bidIds);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> finalizeSelection(int bidId) async {
    state = const AsyncValue.loading();
    try {
      final source = ref.read(adminBiddingSourceProvider);
      await source.finalizeSelection(bidId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateBidPricing(int bidId, double finalPrice, {double? commission, String? notes}) async {
    state = const AsyncValue.loading();
    try {
      final source = ref.read(adminBiddingSourceProvider);
      await source.updateBidPricing(bidId, finalPrice, commission: commission, notes: notes);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final curationProvider = AsyncNotifierProvider<CurationController, void>(() {
  return CurationController();
});
