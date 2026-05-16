import 'package:dio/dio.dart';
import 'package:vendor_app/core/api_client.dart';
import 'package:vendor_app/data/models/bidding/lead_model.dart';
import 'package:vendor_app/data/models/bidding/vendor_bid_model.dart';
import 'package:vendor_app/data/models/notification_model.dart';

class VendorBiddingSource {
  final ApiClient apiClient;

  VendorBiddingSource(this.apiClient);

  Future<List<LeadModel>> getLeads() async {
    try {
      final response = await apiClient.get('/vendor/bids/marketplace');
      return (response.data as List).map((e) => LeadModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch leads: $e');
    }
  }

  Future<LeadModel?> getLeadDetails(int eventId) async {
    try {
      final response = await apiClient.get('/vendor/bids/lead/$eventId');
      return LeadModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getLeadDetailsAsEvent(int eventId) async {
    try {
      final response = await apiClient.get('/vendor/bids/lead/$eventId');
      return response.data;
    } catch (e) {
      return null;
    }
  }

  Future<void> submitBid(int eventId, double amount, String proposal) async {
    try {
      await apiClient.post(
        '/vendor/bids/',
        data: {
          "event_id": eventId,
          "amount": amount,
          "notes": proposal
        }
      );
    } catch (e) {
      if (e is DioException) {
         throw Exception(e.response?.data['detail'] ?? e.message);
      }
      throw Exception('Failed to submit bid');
    }
  }

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await apiClient.get('/notifications/my');
      return (response.data as List).map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }
}
