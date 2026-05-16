import 'package:dio/dio.dart';
import 'package:admin_panel/core/api_client.dart';
import '../models/bidding/admin_bid_model.dart';

class AdminBiddingSource {
  final ApiClient apiClient;

  AdminBiddingSource(this.apiClient);

  Future<List<AdminBidModel>> getBidsForRequest(int eventId) async {
    try {
      final response = await apiClient.get('/api/admin/bidding/event-bids/$eventId');
      return (response.data as List).map((e) => AdminBidModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch bids for admin: $e');
    }
  }

  Future<void> curateBid(int bidId, String action) async {
    try {
      // action: 'accept' (shortlist) or 'reject'
      await apiClient.post(
        '/api/admin/bidding/$bidId/$action',
        data: {"notes": "Processed by Admin"}
      );
    } catch (e) {
       if (e is DioException) {
         throw Exception(e.response?.data['detail'] ?? e.message);
      }
      throw Exception('Failed to curate bid');
    }
  }

  Future<void> pushToCustomer(int eventId, List<int> bidIds) async {
    try {
      await apiClient.post(
        '/api/admin/bidding/push-to-customer',
        data: {
          "event_id": eventId,
          "bid_ids": bidIds
        }
      );
    } catch (e) {
       if (e is DioException) {
         throw Exception(e.response?.data['detail'] ?? e.message);
      }
      throw Exception('Failed to push bids to customer');
    }
  }

  Future<void> finalizeSelection(int bidId) async {
    try {
      await apiClient.post('/api/admin/bidding/finalize-selection/$bidId');
    } catch (e) {
       if (e is DioException) {
         throw Exception(e.response?.data['detail'] ?? e.message);
      }
      throw Exception('Failed to finalize selection');
    }
  }

  Future<void> updateBidPricing(int bidId, double finalPrice, {double? commission, String? notes}) async {
    try {
      await apiClient.put(
        '/api/admin/bidding/$bidId/pricing',
        data: {
          "final_price": finalPrice,
          "platform_commission": commission,
          "notes": notes
        }
      );
    } catch (e) {
      if (e is DioException) {
         throw Exception(e.response?.data['detail'] ?? e.message);
      }
      throw Exception('Failed to update bid pricing');
    }
  }
}
