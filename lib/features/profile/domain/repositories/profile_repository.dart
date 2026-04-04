import 'package:dartz/dartz.dart';
import 'package:modern_learner_production/core/errors/failures.dart';
import 'package:modern_learner_production/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  /// Get the current user's profile
  Future<Either<Failure, ProfileEntity>> getProfile();

  /// Update the current user's profile
  Future<Either<Failure, ProfileEntity>> updateProfile({
    required String name,
    String? avatarUrl,
  });
}
