import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../presentation/providers/app/app_provider.dart';

final bidServiceProvider = Provider<BidService>((ref) {
  return BidService(ref.read(apiClientProvider));
});

class BidService {
  final ApiClient _apiClient;

  BidService(this._apiClient);

  Future<Map<String, dynamic>> getShortlistedBids(int eventId) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.customerBidding(eventId));
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load bids: $e');
    }
  }

  Future<void> acceptBid(int bidId) async {
    try {
      await _apiClient.dio.post(ApiEndpoints.customerAcceptBid(bidId), data: {});
    } catch (e) {
      throw Exception('Failed to accept bid: $e');
    }
  }
}
