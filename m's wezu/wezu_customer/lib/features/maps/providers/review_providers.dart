import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_provider.dart';
import '../models/review.dart';

class ReviewState {
  final List<Review> reviews;
  final bool isLoading;
  final String? error;
  final double averageRating;
  final int totalCount;

  ReviewState({
    this.reviews = const [],
    this.isLoading = false,
    this.error,
    this.averageRating = 0.0,
    this.totalCount = 0,
  });

  ReviewState copyWith({
    List<Review>? reviews,
    bool? isLoading,
    String? error,
    double? averageRating,
    int? totalCount,
  }) {
    return ReviewState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      averageRating: averageRating ?? this.averageRating,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

class ReviewNotifier extends StateNotifier<ReviewState> {
  final Dio _dio;
  ReviewNotifier(this._dio) : super(ReviewState());

  Future<void> loadReviews(int stationId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get('/stations/$stationId/reviews');
      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> data = response.data as List<dynamic>;
        final reviews = data
            .whereType<Map>()
            .map((json) => Review.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        final avg = reviews.isEmpty
            ? 0.0
            : reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                reviews.length;

        state = state.copyWith(
          reviews: reviews,
          isLoading: false,
          averageRating: avg,
          totalCount: reviews.length,
        );
        return;
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Unexpected review response from server.',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> submitReview(
      int stationId, double rating, String comment) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post('/stations/$stationId/reviews', data: {
        'rating': rating,
        'comment': comment,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final payload = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};
        final newReview = Review.fromJson(payload);
        state = state.copyWith(
          reviews: [newReview, ...state.reviews],
          isLoading: false,
          totalCount: state.totalCount + 1,
        );
        return;
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to submit review right now.',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final reviewProvider =
    StateNotifierProvider<ReviewNotifier, ReviewState>((ref) {
  return ReviewNotifier(ref.watch(authenticatedDioProvider));
});
