import '../../data/models/review/review_model.dart';

abstract class IReviewRepository {
  Future<List<ReviewModel>> getVendorReviews(String vendorId);
  Future<void> addReview(ReviewModel review);
}
