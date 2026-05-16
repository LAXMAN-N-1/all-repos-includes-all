import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/bid_model.dart';
import '../../data/models/bidding_event_model.dart';
import '../../data/models/customer_view_model.dart';
import '../../data/services/bid_service.dart';

final customerViewProvider = FutureProvider.family<CustomerViewResponse, int>((ref, eventId) async {
  final service = ref.read(bidServiceProvider);
  return service.getCustomerView(eventId);
});

final dashboardEventsProvider = FutureProvider<List<BiddingEvent>>((ref) async {
  final service = ref.read(bidServiceProvider);
  return service.getDashboardEvents();
});

final eventBiddingDetailProvider = FutureProvider.family<BiddingEventDetail, int>((ref, id) async {
  final service = ref.read(bidServiceProvider);
  return service.getEventDetails(id);
});

final eventBidsProvider = FutureProvider.family<List<Bid>, int>((ref, eventId) async {
  final service = ref.watch(bidServiceProvider);
  return service.getEventBids(eventId);
});

final bidDetailProvider = FutureProvider.family<Bid, int>((ref, bidId) async {
  final service = ref.watch(bidServiceProvider);
  return service.getBidDetails(bidId);
});

final bidsProvider = AsyncNotifierProvider<BidsNotifier, List<Bid>>(() {
  return BidsNotifier();
});

class BidsNotifier extends AsyncNotifier<List<Bid>> {
  @override
  Future<List<Bid>> build() async {
    final bidService = ref.watch(bidServiceProvider);
    return bidService.getBids();
  }

  Future<void> approveBid(int id, String? notes) async {
    final service = ref.read(bidServiceProvider);
    await service.approveBid(id, notes);
    ref.invalidateSelf();
  }

  Future<void> rejectBid(int id, String? notes) async {
    final service = ref.read(bidServiceProvider);
    await service.rejectBid(id, notes);
    ref.invalidateSelf();
  }
  
  Future<Bid> getBidDetails(int id) async {
    final service = ref.read(bidServiceProvider);
    return service.getBidDetails(id);
  }

  Future<void> pushBidsToCustomer(int eventId, List<int> bidIds) async {
    final service = ref.read(bidServiceProvider);
    await service.pushBidsToCustomer(eventId, bidIds);
    ref.invalidate(eventBidsProvider(eventId));
  }
}
