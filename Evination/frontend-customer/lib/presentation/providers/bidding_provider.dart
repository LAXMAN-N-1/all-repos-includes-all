import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/bidding_repository.dart';
import '../../data/repositories/bidding_repository_impl.dart';
import '../../data/datasources/bidding_remote_source.dart';
import '../../core/network/dio_client.dart'; // Assuming this exists or getting dio from provider
import '../providers/dio_provider.dart'; // Assuming generic dio provider

// Repository Provider
final biddingRepositoryProvider = Provider<BiddingRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return BiddingRepositoryImpl(remoteDataSource: BiddingRemoteSourceImpl(dio));
});

// Logic Provider (StateNotifier or generic Provider?)
// Let's use FutureProviders for lists and StateNotifier for interactions.

final myRequestsProvider = FutureProvider((ref) async {
  final repo = ref.watch(biddingRepositoryProvider);
  final result = await repo.getMyRequests();
  return result.fold(
    (l) => throw l.message, 
    (r) => r
  );
});

final requestBidsProvider = FutureProvider.family((ref, int requestId) async {
  final repo = ref.watch(biddingRepositoryProvider);
  final result = await repo.getBidsForRequest(requestId);
  return result.fold(
    (l) => throw l.message, 
    (r) => r
  );
});

// Mutation Provider (Create Request / Select Bid)
class BiddingController extends StateNotifier<AsyncValue<void>> {
  final BiddingRepository _repo;
  BiddingController(this._repo) : super(const AsyncValue.data(null));

  Future<void> createRequest(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    final result = await _repo.createRequest(data);
    state = result.fold(
      (l) => AsyncValue.error(l.message, StackTrace.current), 
      (r) => const AsyncValue.data(null)
    );
  }

  Future<void> selectBid(int bidId) async {
    state = const AsyncValue.loading();
    final result = await _repo.selectBid(bidId);
    state = result.fold(
      (l) => AsyncValue.error(l.message, StackTrace.current), 
      (r) => const AsyncValue.data(null)
    );
  }
}

final biddingControllerProvider = StateNotifierProvider<BiddingController, AsyncValue<void>>((ref) {
  return BiddingController(ref.watch(biddingRepositoryProvider));
});
