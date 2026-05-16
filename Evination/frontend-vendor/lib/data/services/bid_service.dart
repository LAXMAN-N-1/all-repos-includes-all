import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../models/bid_model.dart';
import 'package:dio/dio.dart';
import '../models/bidding_event_model.dart';
import '../models/customer_view_model.dart';

final bidServiceProvider = Provider<BidService>((ref) {
  return BidService(ref.read(apiClientProvider));
});

class BidService {
  final ApiClient _apiClient;

  BidService(this._apiClient);

  Future<CustomerViewResponse> getCustomerView(int eventId) async {
    final response = await _apiClient.get('/admin/bidding/customer-view/$eventId');
    return CustomerViewResponse.fromJson(response.data);
  }

  Future<List<BiddingEvent>> getDashboardEvents() async {
    final response = await _apiClient.get('/vendor/bids/marketplace');
    return (response.data as List).map((json) => BiddingEvent.fromJson(json)).toList();
  }

  Future<BiddingEventDetail> getEventDetails(int eventId) async {
    final response = await _apiClient.get('/admin/bidding/events/$eventId');
    return BiddingEventDetail.fromJson(response.data);
  }

  Future<List<Bid>> getEventBids(int eventId) async {
    final response = await _apiClient.get('/admin/bidding/event-bids/$eventId');
    return (response.data as List).map((json) => Bid.fromJson(json)).toList();
  }

  Future<List<Bid>> getBids() async {
    try {
      final response = await _apiClient.get('/admin/bidding/');
      final List<dynamic> data = response.data;
      return data.map((json) => Bid.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load bids: $e');
    }
  }
  
  Future<Bid> getBidDetails(int id) async {
    try {
      final response = await _apiClient.get('/admin/bidding/$id');
      return Bid.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load bid details: $e');
    }
  }

  Future<void> approveBid(int id, String? notes) async {
    try {
      await _apiClient.post('/admin/bidding/$id/accept', data: {'notes': notes});
    } catch (e) {
      throw Exception('Failed to approve bid: $e');
    }
  }

  Future<void> rejectBid(int id, String? notes) async {
    try {
      await _apiClient.post('/admin/bidding/$id/reject', data: {'notes': notes});
    } catch (e) {
      throw Exception('Failed to reject bid: $e');
    }
  }

  Future<List<Bid>> getVendorBids() async {
    try {
      final response = await _apiClient.get('/vendor/bids/my-bids');
      final List<dynamic> data = response.data;
      return data.map((json) => Bid.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load my bids: $e');
    }
  }

  Future<void> submitBid(Map<String, dynamic> bidData) async {
    try {
      await _apiClient.post('/vendor/bids/', data: bidData);
    } catch (e) {
      throw Exception('Failed to submit bid: $e');
    }
  }
}
