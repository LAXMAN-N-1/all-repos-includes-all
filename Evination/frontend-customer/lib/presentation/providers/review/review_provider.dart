import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/review/review_model.dart';
import '../../../data/repositories/review_repository_impl.dart';

final vendorReviewsProvider = FutureProvider.family<List<ReviewModel>, String>((ref, vendorId) async {
  final repository = ref.watch(reviewRepositoryProvider);
  return repository.getVendorReviews(vendorId);
});

class ReviewNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  ReviewNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> addReview(ReviewModel review) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(reviewRepositoryProvider);
      await repository.addReview(review);
      // Invalidate the list provider to refetch
      ref.invalidate(vendorReviewsProvider(review.vendorId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final reviewActionProvider = StateNotifierProvider<ReviewNotifier, AsyncValue<void>>((ref) {
  return ReviewNotifier(ref);
});
