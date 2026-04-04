import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:modern_learner_production/core/errors/exceptions.dart';
import 'package:modern_learner_production/core/errors/failures.dart';
import 'package:modern_learner_production/core/network/network_info.dart';
import 'package:modern_learner_production/features/profile/domain/entities/profile_entity.dart';
import 'package:modern_learner_production/features/profile/domain/repositories/profile_repository.dart';
import 'package:modern_learner_production/features/profile/service/data/profile_remote_data_source.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(
    this._remote,
    this._networkInfo,
  );

  final ProfileRemoteDataSource _remote;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection.'));
    }

    try {
      final profile = await _remote.getProfile();
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile({
    required String name,
    String? avatarUrl,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection.'));
    }

    try {
      final profile = await _remote.updateProfile(
        name: name,
        avatarUrl: avatarUrl,
      );
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    }
  }
}
