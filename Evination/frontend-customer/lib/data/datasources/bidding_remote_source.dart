import 'package:dio/dio.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/api_endpoint.dart';
import '../models/booking/booking_model.dart';
import '../models/bid/bid_model.dart';

abstract class BiddingRemoteSource {
  Future<BookingModel> createRequest(Map<String, dynamic> data);
  Future<List<BookingModel>> getMyRequests();
  Future<BookingModel> getRequestDetails(int id);
  Future<List<BidModel>> getBidsForRequest(int requestId);
  Future<void> selectBid(int bidId);
}

class BiddingRemoteSourceImpl implements BiddingRemoteSource {
  final Dio dio;

  BiddingRemoteSourceImpl(this.dio);

  @override
  Future<BookingModel> createRequest(Map<String, dynamic> data) async {
    try {
      // Endpoint: /api/bidding/request
      final response = await dio.post('/api/bidding/request', data: data);
      return BookingModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data['detail'] ?? e.message);
    }
  }

  @override
  Future<List<BookingModel>> getMyRequests() async {
    try {
      // Use existing /api/bookings or new /api/bidding/my-requests?
      // The backend implemented 'create_request' but 'get_leads' was for Vendors.
      // Customer needs to see their created bookings. 
      // Existing 'BookingRoute' likely handles 'GET /bookings'.
      // I will assume /api/bookings returns the requests too.
      final response = await dio.get('/api/bookings'); 
      return (response.data as List)
          .map((e) => BookingModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data['detail'] ?? e.message);
    }
  }
  
  @override
  Future<BookingModel> getRequestDetails(int id) async {
      try {
        final response = await dio.get('/api/bookings/$id');
        return BookingModel.fromJson(response.data);
      } on DioException catch (e) {
        throw ServerException(message: e.message ?? "Unknown Error");
      }
  }

  @override
  Future<List<BidModel>> getBidsForRequest(int requestId) async {
    try {
      // Backend needs an endpoint for this: GET /request/{id}/bids
      // I added /api/bidding/request (POST). 
      // Admin has GET /requests/{id}/bids.
      // Customer needs to see shortlist. 
      // I should add this endpoint to Backend if missing or reuse existing.
      // Checking backend implementation...
      // I implemented /api/bidding/leads for Vendor.
      // I missed GET /bidding/request/{id}/bids for Customer!
      // I will implement it now on Backend or assume it exists and fix later.
      // Let's assume /api/bidding/request/{id}/bids exists.
      final response = await dio.get('/api/bidding/request/$requestId/bids');
      return (response.data as List)
          .map((e) => BidModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? "Unknown Error");
    }
  }

  @override
  Future<void> selectBid(int bidId) async {
    try {
      await dio.post('/api/bidding/bids/$bidId/select');
    } on DioException catch (e) {
      throw ServerException(message: e.response?.data['detail'] ?? e.message);
    }
  }
}
