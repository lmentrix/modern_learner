import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:modern_learner_production/core/errors/failures.dart';
import 'package:modern_learner_production/features/auth/domain/entities/user_entity.dart';
import 'package:modern_learner_production/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity?>> call() => _repository.getCurrentUser();
}
