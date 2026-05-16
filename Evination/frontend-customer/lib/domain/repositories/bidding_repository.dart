import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../data/models/booking/booking_model.dart';
import '../../data/models/bid/bid_model.dart';

abstract class BiddingRepository {
  Future<Either<Failure, BookingModel>> createRequest(Map<String, dynamic> data);
  Future<Either<Failure, List<BookingModel>>> getMyRequests();
  Future<Either<Failure, BookingModel>> getRequestDetails(int id);
  Future<Either<Failure, List<BidModel>>> getBidsForRequest(int requestId);
  Future<Either<Failure, void>> selectBid(int bidId);
}
