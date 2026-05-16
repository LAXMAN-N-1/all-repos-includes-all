import 'package:dartz/dartz.dart';
import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/data/datasources/vendor_remote_source.dart';
import 'package:admin_panel/data/models/vendor/vendor_admin_model.dart';
import 'package:admin_panel/data/models/vendor/vendor_registration_model.dart';

abstract class VendorRepository {
  Future<Either<Failure, List<AdminVendorModel>>> getPendingVendors();
  Future<Either<Failure, List<AdminVendorModel>>> getVendors(String status, {int? categoryId});
  Future<Either<Failure, void>> approveVendor(int id);
  Future<Either<Failure, void>> verifyDocument(int vendorId, int docId, String status, {String? reason});
  Future<Either<Failure, void>> createVendor(VendorRegistrationModel data);
}

class VendorRepositoryImpl implements VendorRepository {
  final VendorRemoteSource remoteSource;

  VendorRepositoryImpl(this.remoteSource);

  @override
  Future<Either<Failure, List<AdminVendorModel>>> getPendingVendors() async {
    return getVendors('pending');
  }

  @override
  Future<Either<Failure, List<AdminVendorModel>>> getVendors(String status, {int? categoryId}) async {
    try {
      final result = await remoteSource.getVendors(status, categoryId: categoryId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> approveVendor(int id) async {
    try {
      await remoteSource.approveVendor(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyDocument(int vendorId, int docId, String status, {String? reason}) async {
    try {
      await remoteSource.verifyDocument(vendorId, docId, status, reason);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createVendor(VendorRegistrationModel data) async {
    try {
      await remoteSource.createVendor(data);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
