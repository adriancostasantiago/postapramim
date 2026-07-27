import 'package:postapramim/core/error/result.dart';
import 'package:postapramim/features/auth/domain/entities/user_entity.dart';
import 'package:postapramim/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUsecase {
  final AuthRepository _repository;
  GetCurrentUserUsecase(this._repository);

  Future<Result<UserEntity?>> call() => _repository.usuarioAtual();
}
