import 'package:postapramim/core/error/result.dart';
import 'package:postapramim/domain/auth/entities/user_entity.dart';
import 'package:postapramim/domain/auth/repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository _repository;
  LoginUsecase(this._repository);

  Future<Result<UserEntity>> call({
    required String email,
    required String senha,
  }) {
    return _repository.login(email: email, senha: senha);
  }
}
