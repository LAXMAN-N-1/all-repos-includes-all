import 'package:dartz/dartz.dart';
import 'package:evination_customer_app/core/error/failures.dart';
import 'package:evination_customer_app/core/error/exceptions.dart';
import 'package:evination_customer_app/core/network/network_info.dart';
import 'package:evination_customer_app/domain/repositories/bidding_repository.dart';
import 'package:evination_customer_app/data/datasources/bidding_remote_source.dart';
import 'package:evination_customer_app/data/models/booking/booking_model.dart';
import 'package:evination_customer_app/data/models/bid/bid_model.dart';

class BiddingRepositoryImpl implements BiddingRepository {
  final BiddingRemoteSource remoteDataSource;

  BiddingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, BookingModel>> createRequest(Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.createRequest(data);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookingModel>>> getMyRequests() async {
    try {
      final result = await remoteDataSource.getMyRequests();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    }
  }
  
    @override
  Future<Either<Failure, BookingModel>> getRequestDetails(int id) async {
    try {
      final result = await remoteDataSource.getRequestDetails(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    }
  }

  @override
  Future<Either<Failure, List<BidModel>>> getBidsForRequest(int requestId) async {
    try {
      final result = await remoteDataSource.getBidsForRequest(requestId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    }
  }

  @override
  Future<Either<Failure, void>> selectBid(int bidId) async {
    try {
      await remoteDataSource.selectBid(bidId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    }
  }
}
