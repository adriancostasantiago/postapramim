import 'package:postapramim/core/error/result.dart';
import 'package:postapramim/domain/auth/repositories/auth_repository.dart';

class LogoutUsecase {
  final AuthRepository _repository;
  LogoutUsecase(this._repository);

  Future<Result<void>> call() => _repository.logout();
}
