import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:modern_learner_production/core/errors/failures.dart';
import 'package:modern_learner_production/features/profile/domain/entities/profile_entity.dart';
import 'package:modern_learner_production/features/profile/domain/repositories/profile_repository.dart';

@injectable
class GetProfileUseCase {
  const GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, ProfileEntity>> call() async {
    return _repository.getProfile();
  }
}
