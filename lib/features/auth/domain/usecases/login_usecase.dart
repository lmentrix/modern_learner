import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'package:modern_learner_production/core/errors/failures.dart';
import 'package:modern_learner_production/features/auth/domain/entities/user_entity.dart';
import 'package:modern_learner_production/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call(LoginParams params) {
    return _repository.login(email: params.email, password: params.password);
  }
}

class LoginParams extends Equatable {
  const LoginParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
