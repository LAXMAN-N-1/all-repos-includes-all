import 'package:dartz/dartz.dart';
import 'package:vendor_app/core/error/failures.dart';
import 'package:vendor_app/data/datasources/onboarding_remote_source.dart';
import 'package:vendor_app/data/models/onboarding/onboarding_models.dart';

abstract class OnboardingRepository {
  Future<Either<Failure, Map<String, dynamic>>> initiateOnboarding(InitiateRequest data);
  Future<Either<Failure, void>> saveBusinessDetails(BusinessDetailsRequest data);
  Future<Either<Failure, void>> saveDocuments(DocumentUploadRequest data);
  Future<Either<Failure, void>> submitApplication();
}

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingRemoteSource remoteDataSource;

  OnboardingRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Map<String, dynamic>>> initiateOnboarding(InitiateRequest data) async {
    try {
      final result = await remoteDataSource.initiateOnboarding(data);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveBusinessDetails(BusinessDetailsRequest data) async {
    try {
      await remoteDataSource.saveBusinessDetails(data);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveDocuments(DocumentUploadRequest data) async {
    try {
      await remoteDataSource.saveDocuments(data);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitApplication() async {
    try {
      await remoteDataSource.submitApplication();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
