import 'package:postapramim/core/error/result.dart';
import 'package:postapramim/features/auth/domain/repositories/auth_repository.dart';

class RecoverPasswordUsecase {
  final AuthRepository _repository;
  RecoverPasswordUsecase(this._repository);

  Future<Result<void>> call(String email) => _repository.recuperarSenha(email);
}
