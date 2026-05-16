import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/i_review_repository.dart';
import '../models/review/review_model.dart';

class ReviewRepositoryImpl implements IReviewRepository {
  final List<ReviewModel> _mockReviews = [
    ReviewModel(
      id: '1',
      vendorId: 'v1',
      userId: 'u1',
      userName: 'John Doe',
      rating: 4.5,
      comment: 'Great service, highly recommended!',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  @override
  Future<List<ReviewModel>> getVendorReviews(String vendorId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockReviews; // Return same mocks for now
  }

  @override
  Future<void> addReview(ReviewModel review) async {
    _mockReviews.add(review);
  }
}

final reviewRepositoryProvider = Provider<IReviewRepository>((ref) {
  return ReviewRepositoryImpl();
});
