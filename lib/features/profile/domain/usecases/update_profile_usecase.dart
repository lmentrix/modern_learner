import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:modern_learner_production/core/errors/failures.dart';
import 'package:modern_learner_production/features/profile/domain/entities/profile_entity.dart';
import 'package:modern_learner_production/features/profile/domain/repositories/profile_repository.dart';

@injectable
class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, ProfileEntity>> call({
    required String name,
    String? avatarUrl,
  }) async {
    return _repository.updateProfile(
      name: name,
      avatarUrl: avatarUrl,
    );
  }
}
